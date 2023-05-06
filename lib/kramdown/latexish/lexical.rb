module Kramdown::Latexish
  # Lexical tools, including localisation
  #
  # The class this is included into shall provide the method
  #
  # lang:
  #   The language in use, one of :english or :french
  class Lexical

    # The active language
    attr_reader :language

    # All supported languages
    attr_reader :languages

    def initialize(language)
      @language = language

      # The specifications from which everything else is derived
      @localisation = {
        :abstract => {
          :english => 'abstract(s)',
          :french  => 'abstract(s)',
        },
        :definition => {
          :english => 'definition(s)',
          :french  => 'définition(s)',
        },
        :postulate => {
          :english => 'postulate(s)',
          :french  => 'postulat(s)',
        },
        :property => {
          :english => 'property(<ies)',
          :french  => 'propriété(s)',
        },
        :lemma => {
          :english => 'lemma(s)',
          :french  => 'lemme(s)',
        },
        :theorem => {
          :english => 'theorem(s)',
          :french  => 'théorème(s)',
        },
        :corollary => {
          :english => 'corollary(<ies)',
          :french  => 'corollaire(s)',
        },
        :section => {
          :english => 'section(s)',
          :french  => 'section(s)',
        },
        :reference => {
          :english => 'reference(s)',
          :french  => 'référence(s)',
        },
        :eqn => {
          :english => 'eqn(s)',
          :french  => 'éqn(s)'
        },
        :and => {
          :english => 'and',
          :french  => 'et',
        },
      }

      # The list of languages, computed from @localisation
      @languages = @localisation.values.map(&:keys).reduce(:&)

      # Associate e.g. "property" and "properties" to :property
      @reverse_localisation = Hash[@languages.map {|lang|
        h = {}
        @localisation.keys.map do |category|
          h[localise(category, :singular)] = category
          h[localise(category, :plural)]   = category
        end
        [lang, h]
      }]
    end

    # The word in the current language and specified singular/plural form
    # corresponding to the given symbol.
    # E.g. :property => "propriété" for form=:singular in French
    def localise(symbol, form=:singular)
      %r{^ (?<singular> [[:alpha:]]+)
         (
           \(
             (?<back><+)?
             (?<plural_ending> [[:alpha:]]+)
           \)
         )?
      }x =~ @localisation[symbol][language]
      return singular if plural_ending.nil?
      stop = back.nil? ? -1 : -back.length - 1
      case form
      when :singular
        singular
      when :plural
        singular[..stop] + plural_ending
      else
        raise "Unknown form: #{form}"
      end
    end

    # The symbol corresponding to the given word,
    # i.e. the reverse of `localise`.
    # E.g. "properties" => :property in English
    def symbolise(word)
      @reverse_localisation[language][word.downcase]
    end

    # The lexical conjonction with commas and the word "and" of the given words
    #
    # This method is versatile as it can take an array of strings, or of more
    # complex objects, and return an array or a joined string.
    #
    # SYNOPSIS
    #
    # and(%w(apples pears)) is "apple and pears"
    #
    # and(%w(apples pears), joined:false) is ["apple", " and ", pears"]
    #
    # and([E("apples"), E("pears")], joined:false) is
    # [E("apples"), E(" and "), E("pears")]
    #
    # Passing `joined:true` in this case would most likely not make sense and
    # lead to an error, unless the objects returned by E(…) support enough of
    # the String API.
    #
    # Commas appear with three elements or more
    #
    # and(%w(apples bananas pears)) is "apples, bananas, and pears"
    #
    # The method knows that in some languages the equivalent of that final "and"
    # is not preceded by a comma. For example, in French
    #
    # and(%(pommes bananes poires)) is "pommes, bananes et poires"
    #
    def and(array, joined: true, nbsp: false)
      and_ = localise(:and, language)
      comma_sep = ', '
      and_sep_2 = ' ' + and_
      # Some languages put a comma before "and", others don't
      and_sep_n = ([:english].include?(language) ? ', ' : ' ') + and_
      space = nbsp ? '&nbsp;' : ' '
      and_sep_2 += space
      and_sep_n += space

      if block_given?
        comma_sep = yield(comma_sep)
        and_sep_2 = yield(and_sep_2)
        and_sep_n = yield(and_sep_n)
      end
      output = case array.size
      when 1
        array
      when 2
        [array[0], and_sep_2, array[1]]
      else
        seps = Array.new(array.size - 2).fill(comma_sep) + [and_sep_n]
        array.zip(seps).flatten.compact
      end
      if joined
        output.join
      else
        output
      end
    end
  end
end
