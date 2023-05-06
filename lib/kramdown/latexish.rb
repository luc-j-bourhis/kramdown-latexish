require "kramdown/latexish/version"

require 'kramdown/parser/kramdown'
require 'kramdown/converter/html'
require 'kramdown/document'

require 'bibtex'
require 'citeproc'
require 'csl/styles'

require 'kramdown/latexish/bibliographical'
require 'kramdown/latexish/lexical'

# An extension of Kramdown parser aimed at mathematical articles
#
# The way the kramdown library is structured, the parser class must be in
# module Kramdown::Parser, so that the option `:input => "Latexish"` can be
# passed to Kramdown::Document to make it use that parser.
class Kramdown::Parser::Latexish < Kramdown::Parser::Kramdown

  include Kramdown::Latexish::Bibliographical

  # Tags we support for theorem-like environments
  THEOREM_LIKE_TAGS = [:definition, :postulate, :property, :lemma,
                       :theorem, :corollary]

  # All our special tags defined above
  SPECIAL_TAGS = THEOREM_LIKE_TAGS + [:section]

  # Initialise the parser
  #
  # This supports the following options in addition of those supported by
  # the base class
  #
  # :language
  #   A symbol identifying the language. Currently supported are :english
  #   and :french (default :english)
  # :theorem_header_level
  #   A theorem-like environment starts with a header: this option is the level
  #   of that header (default 5)
  # :auto_number_headers
  #   Whether to automatically number headers
  # :no_number
  #   A list of symbols identifying which type of headers should not be
  #   automatically numbered (default [:references], i.e. the Reference
  #   section)
  # :bibliography
  #   A `BibTeX::Bibliography` object containing the references to appear
  #   at the end of the document, and which may be cited in the rest of it.
  #   (default nil)
  # :bibliography_style
  #   A symbol designating the CSL style to use to format the reference section
  #   A complete list can be found
  #   [here](https://github.com/citation-style-language/styles)
  #   where the basename without the extension is the symbol to be passed.
  #   (default :apa, for the APA style)
  # :latex_macros
  #   A list of LaTeX macros that all equations in the document shall be able
  #   to use. To do so they are put in a math block at the beginning of the
  #   document.
  #   (default [])
  # :hide_latex_macros?
  #   Whether the math block containing the LaTeX macros is completely hidden
  #   when converted to HTML
  #   (default true)
  def initialize(source, options)
    super

    # Initialise language and lexical delegate
    @lex = Kramdown::Latexish::Lexical.new(@options[:language] ||= :english)

    # Initialise the rest of our custom options
    @options[:theorem_header_level] ||= 5
    @options[:auto_number_headers] = true if @options[:auto_number_headers].nil?
    @options[:no_number] ||= [reference_section_name]
    @options[:bibliography_style] ||= :apa
    @options[:latex_macros] ||= []
    @options[:hide_latex_macros?] = true if @options[:hide_latex_macros?].nil?

    # Add our new parsers
    @span_parsers.unshift(:latex_inline_math)

    # For parsing theorem environments
    rx = THEOREM_LIKE_TAGS
         .map{|tag| @lex.localise(tag)}
         .map(&:capitalize)
         .join('|')
    rx = rx + '|' + @lex.localise(:abstract).capitalize
    @environment_start_rx = / \A (#{rx}) (?: [ \t] ( \( .+? \) ) )? \s*? \Z /xm
    @environment_end_rx =  / \A \\ (#{rx}) \s*? \Z /xm

    # Last encountered theorem header
    @th = nil

    # For assigning a number to each header
    @next_section_number = []
    @last_header_level = 0

    # For tracking references to our special constructs
    @number_for = {}
    @category_for = {}

    # For numbering theorem-like environments
    @next_theorem_like_number = Hash[THEOREM_LIKE_TAGS.map{|tag| [tag, 0]}]

    # Bibtex keys found in citations
    @cited_bibkeys = Set[]
  end

  def language
    @options[:language]
  end

  def bibliography
    @options[:bibliography]
  end

  def reference_section_name
    @lex.localise(:reference, :plural).capitalize
  end

  # Redefine a parser previously added with `define_parser`
  def self.redefine_parser(name, start_re, span_start = nil,
                           meth_name = "parse_#{name}")
    @@parsers.delete(name)
    define_parser(name, start_re, span_start, meth_name)
  end

  # Parse $...$ which do not make a block
  # We do not need to start the regex with (?<!\$) because the scanner
  # is placed at the first $ it encounters.
  LATEX_INLINE_MATH_RX = /\$ (?!\$) (.*?) (?<!\$) \$ (?!\$) /xm
  def parse_latex_inline_math
    parse_inline_math
  end
  define_parser(:latex_inline_math, LATEX_INLINE_MATH_RX, '\$')

  # Parsing of environments
  #
  # We override the parsing of paragraphs, by detecting the start and end
  # markers of an environment, then reshuffling the elements parsed by super.
  def parse_paragraph
    return false unless super

    # We do indeed have a paragraph: we will return true in any case
    # but we may do some processing beforehand if we find one of our
    # environments
    els = @tree.children
    case els.last.children[0].value
    when @environment_start_rx
      # We have an environment header: keep necessary info
      @th = [els.size - 1, $1, $2, @src.current_line_number]
    when @environment_end_rx
      # We have an end tag: do we have a starting one?
      end_tag = $1
      end_loc = @src.current_line_number
      unless @th
        warning(
          "`\\#{end_tag}` on line #{end_loc} without " \
          "any `#{end_tag}` earlier on")
      else
        # We have a beginning tag: does it match the end tag?
        start_idx, start_tag, start_label, start_loc = @th
        unless end_tag == start_tag
          warning("\\#{end_tag} on line #{end_loc} does not match " \
                  "#{start_tag} on line #{start_loc}")
        else
          # We have a valid environment: discriminate
          if @lex.symbolise(start_tag) == :abstract
            add_abstract(start_tag, start_idx, start_label,
                         start_loc, end_loc)
          else
            add_theorem_like(start_tag, start_idx, start_label,
                             start_loc, end_loc)
          end
          # Prepare for a new paragraph
          @th = nil
        end
      end
    end
    true
  end

  # Add a theorem-like environment (internal helper method)
  def add_theorem_like(tag, start_idx, start_label,
                       start_loc, end_loc)
    category = @lex.symbolise(tag)
    els = @tree.children
    header = els[start_idx]

    # Merge header ial's with .theorem-like
    ial = header.options[:ial] || {}
    update_ial_with_ial(ial, {'class' => 'theorem-like'})

    # Increment number
    nb = @next_theorem_like_number[category] += 1

    # Process id
    unless (id = ial['id']).nil?
      @number_for[id] = nb
      @category_for[id] = category
    end

    # Create a <section> for the theorem with those ial's
    el = new_block_el(:html_element, 'section', ial,
                      :category => :block, :content_model => :block)

    # Create header and add it in the section
    elh = new_block_el(:header, nil, nil,
                       :level => @options[:theorem_header_level])
    # We can add Kramdown here as this is yet to be seen by the span parsers
    add_text("**#{tag} #{nb}** #{start_label}".rstrip, elh)
    el.children << elh

    # Add all the other elements processed after the header paragraph
    el.children += els[start_idx + 1 .. -2]

    # Replace all the elements processed since the header paragraph
    # by our section
    els[start_idx ..] = el
  end

  # Add an abstract (internal helper method)
  def add_abstract(tag, start_idx, start_label,
                   start_loc, end_loc)
    els = @tree.children
    header = els[start_idx]

    # Merge header ial's with .abstract
    ial = header.options[:ial] || {}
    update_ial_with_ial(ial, {'class' => 'abstract'})

    # Create a <div> for the abstract
    el = new_block_el(:html_element, 'div', ial,
                      :category => :block, :content_model => :block)

    # Add all the other elements processed after the header paragraph
    el.children += els[start_idx + 1 .. -2]

    # Replace all the elements processed since the header paragraph
    # by our div
    els[start_idx ..] = el
  end

  # Auto-numbering of headers
  #
  # We override this method so that it will work with both setext and atx
  # headers out of the box
  def add_header(level, text, id)
    # Only h2, h3, … as h1 is for title
    lvl = level - 1
    if lvl > 0
      if @options[:auto_number_headers] && !@options[:no_number].include?(text)
        # Compute the number a la 2.1.3
        if lvl == @last_header_level
          @next_section_number[-1] += 1
        elsif lvl > @last_header_level
          ones = [1]*(lvl - @last_header_level)
          @next_section_number.push(*ones)
        else
          @next_section_number.pop(@last_header_level - lvl)
          @next_section_number[-1] += 1
        end
        @last_header_level = lvl
        nb = @next_section_number.join('.')

        # Prepend it to header text, removing a leading number if any
        text.gsub!(/^\s*[\d.]*\s*/, '')
        text = "#{nb} #{text}"

        # If it has an id, keep track of the association with its number
        @number_for[id] = nb if id
        @category_for[id] = :section
      end
    end

    # Let Kramdown handle it now
    super(level, text, id)
  end

  # Parse reference links to sections
  #
  # We override parse_link, look whether we have one of our special reference
  # links or one of our bibliographical citations, if so process it, otherwise
  # let super handle it. Since this method is called by Kramdown when it
  # thinks it ready to handle links. So we can assume that all id's are known
  # by then, and therefore all their associated numbers.
  def parse_link
    start_pos = @src.save_pos
    parsed = false
    # Nothing to do if it is an image link
    if @src.peek(1) != '!'
      if @src.scan(SPECIAL_REF_RX)
        parsed = handle_special_ref_link
      elsif @src.scan(BIB_CITE_RX)
        parsed = handle_bibliographic_citation_link
      end
    end
    unless parsed
      @src.revert_pos(start_pos)
      super
    end
  end

  # Regexes for reference links to sections
  SPECIAL_REF_RX = /\[ \s* (C|c)ref : \s* ( [^\]]+ ) \s* \]/x

  def handle_special_ref_link
    loc = @src.current_line_number
    capital = @src[1] == 'C'
    if @src[2].nil?
      warning("No reference specified at line #{loc}")
      @tree.children << Element.new(:text, @src[0], nil, location: loc)
    else
      # Group the keys by header category
      ids_for = {}
      @src[2].split(/\s*,\s*/).map do |id|
        (ids_for[@category_for[id] || :undefined] ||= []) << id
      end
      # For each category, and each ids of that category...
      ref_chunks = ids_for.each_with_index.map do |(category, ids), i|
        # Generate the reference for each id
        nums = ids.map do |id|
          case category
          when :undefined
            warning("No element with id '#{id}' at line #{loc}")
            el = Element.new(:text, "¿#{id}?", nil, location: loc)
          when :eqn
            # Referencing equation shall be delegated to Mathjax by client code
            el = Element.new(:text, "\\eqref{#{id}}", nil, location: loc)
          else
            nb = @number_for[id]
            el = Element.new(:a, nil, nil, location: loc)
            el.attr['href'] = "##{id}"
            el.attr['title'] = "#{@lex.localise(category).capitalize} #{nb}"
            el.children << Element.new(:text, nb.to_s, nil, location: loc)
          end
          el
        end
        # Join all the references and put the title in front
        # We don't want "and" to be separated from the following link
        refs = @lex.and(nums, joined: false, nbsp: true) {|word|
          Element.new(:text, word, nil, location: loc)
        }
        if category != :undefined
          form = ids.size == 1 ? :singular : :plural
          label = @lex.localise(category, form)
          label = label.capitalize if capital and i == 0
          label = Element.new(:text, label + '&nbsp;', nil, location: loc)
          [label] + refs
        else
          refs
        end
      end
      # Conjunct again and append all that to the tree
      # This time "and" should get separated from the following label so as
      # not to stress the layout engine when it wraps lines
      references = @lex.and(ref_chunks, joined:false) {|word|
        [Element.new(:text, word, nil, location: loc)]
      }
      .flatten(1)
      @tree.children += references
    end
    true
  end

  # Regex for bibliographic citations
  BIB_CITE_RX = / \[ \s* cite(p|t) : \s+ ( [^\]]+ ) \s* \]/x

  def handle_bibliographic_citation_link
    return false if bibliography.nil?
    loc = @src.current_line_number
    style = @src[1] == 'p' ? :parenthetical : :textual
    bibkeys = @src[2].split /\s*,\s*/
    unless bibkeys.empty?
      # Array of Element's for each key
      elements = bibkeys.map do |key|
        et_al = false
        if key[0] == '*'
          et_al = true
          key = key[1..]
        end
        # Keep track of the keys that have been cited
        @cited_bibkeys << key if bibliography.key?(key)

        el = Element.new(:a, nil, nil, location: loc)
        el.attr['href'] = "##{key}"
        el.children << Element.new(:text,
                                   citation_for(key, style, et_al, loc),
                                   nil,
                                   location: loc)
        el
      end
      # Then we put them together with commas and the word "and"
      conjonction = @lex.and(elements, joined: false) do |word|
        Element.new(:text, word, nil, location: loc)
      end
      # Then output that array of Element's
      @tree.children += conjonction
      # Done
      true
    else
      warning("Empty bibliographic citation at line #{loc}")
      false
    end
  end

  # Override parse to produce the Reference section
  def parse
    super
    produce_latex_macros
    produce_reference_section
  end

  # Override parsing of block math to gather \label's
  def parse_block_math
    result = super
    @tree.children.last.value.scan(/\\label\s*\{(.*?)\}/) do
      @category_for[$~[1]] = :eqn
    end
    result
  end

  # Produce the section containing the bibliographic references at the end
  # of the document
  def produce_reference_section
    unless @cited_bibkeys.empty?
      cp = CiteProc::Processor.new(style: @options[:bibliography_style],
                                   format: 'html')
      cp.import(bibliography.to_citeproc)
      references = @cited_bibkeys.map {|key|
        html = cp.render(:bibliography, id: key)[0]
        html = clean_bibtex(html)
        html += "\n{: .bibliography-item ##{key}}"
      }
      .join("\n\n")
      biblio = <<~"MD"

        ## #{reference_section_name}

        #{references}
      MD
      # Since we monkey-patched it, this will use this parser
      # and not the default one. In particular, $...$ will produce
      # inline equations
      bib_doc = Kramdown::Document.new(biblio, @options)
      # TODO: fix line numbers
      @root.children += bib_doc.root.children
    end
  end

  # Produce math block with LaTeX macros
  def produce_latex_macros
    macros = @options[:latex_macros]
    unless macros.empty?
      opts = {
        :style => "display:#{@options[:hide_latex_macros?] ? 'none' : 'block'}"
      }
      el = Element.new(
        :html_element, 'div', opts,
        category: :block, content_model: :block)
      macros = (['\text{\LaTeX Macros:}'] + macros).join("\n")
      el.children << Element.new(:math, macros, nil, category: :block)
      # TODO: fix line numbers
      @root.children.prepend(el)
    end
  end
end


module Kramdown::Latexish
  # The extra options to pass to Kramdown::Document to make it correctly parse
  # and convert the mathematical articles we target. The instantiation should
  # therefore always be done as the equivalent of
  #     options = { ... }
  #     ...
  #     options = Kramdown::Latexish::taylor_options(options)
  #     doc = Kramdown::Document.initialise(source, options)
  #
  # It will override :input and :auto_ids, so setting those in `options`
  # is useless, and potentially confusing.
  #
  # Why this design instead of creating a document class inheriting
  # `Kramdown::Document`? The reason stems from a common use case,
  # examplified by static website generators such as Nanoc or Middleman.
  # The user code does never directly instantiate a document. Instead it
  # calls a method from Nanoc or Middleman, which will in turn instantiate a
  # document. The problem is that this object is not visible to the client
  # code. However Nanoc and Middleman let client code pass options to
  # initialise the document. Hence the present design. The only alternative
  # would have been to monkeypatch Kramdown::Document but we think it is
  # cleaner to avoid doing that.
  def self.taylor_options(options)
    options.merge({:input => 'Latexish', :auto_ids => false})
  end
end
