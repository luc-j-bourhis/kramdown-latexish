require 'latex/decode'

module Kramdown::Latexish

  # An extension dealing with BibTeX
  #
  # Mostly so that we can test those methods independently of our Kramdown
  # parser and converter
  #
  # The class this is included into shall provide the following methods:
  #
  # bibliography:
  #   An instance of BibTeX::Bibliography holding the references
  #
  # lexical_and:
  #   The conjonction of a sequence of words with commas and the word "and"
  #   C.f. module Lexical for the requirements
  module Bibliographical
    # Clean BibTeX field (typically the title)
    #
    # 1. It converts accents, diacritics, etc to unicode.
    #    This is implemented withu bits and pieces of the latex-decode library.
    #    We cannot use its main function LaTeX::decode because it removes
    #    the dollars around equations, and all braces including in equations.
    # 2. It strips the braces outside formulae.
    #    Example: "{A} proof of $G_{\mu\nu} = 8\pi T_{\mu\nu}$ by {E}instein"
    #    must become "A proof of $G_{\mu\nu} = 8\pi T_{\mu\nu}$ by Einstein"
    # 3. It puts `\ce{...}` between dollars so that MathJax can eventually
    #    display it
    def clean_bibtex(txt)
      # Let latex-decode do the bulk of the work
      LaTeX::Decode::Base.normalize(txt)
      LaTeX::Decode::Accents.decode!(txt)
      LaTeX::Decode::Diacritics.decode!(txt)
      LaTeX::Decode::Punctuation.decode!(txt)
      LaTeX::Decode::Symbols.decode!(txt)
      LaTeX::Decode::Greek.decode!(txt)

      # Protect \ce
      txt.gsub!(/(\\ce\{.*?\})/, '$\1$')

      # Remove braces outside equations
      txt.chars.map do |c|
        if c == '$' ... c == '$'
          c
        elsif c != '{' and c != '}'
          c
        else
          next
        end
      end.compact.join
    end

    # Text of the citation for the given bibtex key
    def citation_for(key, style, et_al, loc)
      unless (e = bibliography[key]).nil?
        authors = e.authors.map(&:last)
        authors_s = authors.size == 1 ? authors[0]
                  : et_al             ? "#{authors[0]} et al"
                  :                     @lex.and(authors)
        case style
        when :parenthetical
          "(#{authors_s}, #{e.year})"
        when :textual
          "#{authors_s} (#{e.year})"
        else
          raise "Unknown citation style: #{style.to_s}"
        end
      else
        warning("Unknown bibliographic citation at line #{loc}")
        "??#{key}??"
      end
    end
  end
end
