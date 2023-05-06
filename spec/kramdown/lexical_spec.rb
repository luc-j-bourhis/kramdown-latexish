require 'kramdown/latexish/lexical'

require 'rspec/parameterized'

[:english, :french].each do |lang|
  RSpec.describe "Localisation in #{lang}." do
    using RSpec::Parameterized::TableSyntax

    let(:lex) { Kramdown::Latexish::Lexical.new(lang) }

    where(:symbol, :form, :word) do
      case lang
      when :english
        :definition | :singular  | 'definition'
        :definition | :plural    | 'definitions'
        :property   | :singular  | 'property'
        :property   | :plural    | 'properties'
        :lemma      | :singular  | 'lemma'
        :lemma      | :plural    | 'lemmas'
        :theorem    | :singular  | 'theorem'
        :theorem    | :plural    | 'theorems'
        :corollary  | :singular  | 'corollary'
        :corollary  | :plural    | 'corollaries'
        :section    | :singular  | 'section'
        :section    | :plural    | 'sections'
        :reference  | :singular  | 'reference'
        :reference  | :plural    | 'references'
        :and        | :singular  | 'and'
        :and        | :plural    | 'and'
      when :french
        :definition | :singular  | 'définition'
        :definition | :plural    | 'définitions'
        :property   | :singular  | 'propriété'
        :property   | :plural    | 'propriétés'
        :lemma      | :singular  | 'lemme'
        :lemma      | :plural    | 'lemmes'
        :theorem    | :singular  | 'théorème'
        :theorem    | :plural    | 'théorèmes'
        :corollary  | :singular  | 'corollaire'
        :corollary  | :plural    | 'corollaires'
        :section    | :singular  | 'section'
        :section    | :plural    | 'sections'
        :reference  | :singular  | 'référence'
        :reference  | :plural    | 'références'
        :and        | :singular  | 'et'
        :and        | :plural    | 'et'
      end
    end

    with_them do
      it "should localise" do
        expect(lex.localise(symbol, form)).to eq(word)
      end

      it "should universalise" do
        expect(lex.symbolise(word)).to eq(symbol)
      end
    end
  end
end

[:english, :french].each do |lang|
  RSpec.describe "Conjonction in #{lang} (simple words)" do
    using RSpec::Parameterized::TableSyntax

    let(:lex) { Kramdown::Latexish::Lexical.new(lang) }

    where(:words, :conjonction) do
      case lang
      when :english
        %w(Zeus) | "Zeus"
        %w(Zeus Appolo) | "Zeus and Appolo"
        %w(Zeus Appolo Mars) | "Zeus, Appolo, and Mars"
        %w(Zeus Appolo Mars Hermes) | "Zeus, Appolo, Mars, and Hermes"
      when :french
        %w(Zeus) | "Zeus"
        %w(Zeus Appolo) | "Zeus et Appolo"
        %w(Zeus Appolo Mars) | "Zeus, Appolo et Mars"
        %w(Zeus Appolo Mars Hermes) | "Zeus, Appolo, Mars et Hermes"
      end
    end

    with_them do
      it "should match" do
        expect(lex.and(words)).to eq(conjonction)
      end
    end
  end
end

RSpec.describe 'Conjunction in English (complex objects)' do
  using RSpec::Parameterized::TableSyntax

  let(:lex) { Kramdown::Latexish::Lexical.new(:english) }

  E = Struct.new(:text)

  def e(text)
    E.new(text)
  end

  def lexand(strings)
    lex.and(strings.map{|s| e(s)}, joined: false) {|word| e(word)}
  end

  where(:words, :conjunction) do
    %w(Zeus) | [e("Zeus")]
    %w(Zeus Appolo) | [e("Zeus"), e(" and "), e("Appolo")]
    %w(Zeus Appolo Mars) | [e("Zeus"), e(", "), e("Appolo"),
                            e(", and "), e("Mars")]
    %w(Zeus Appolo Mars Hermes) | [e("Zeus"), e(", "), e("Appolo"), e(", "),
                                   e("Mars"), e(", and "), e("Hermes")]
  end

  with_them do
    it "should make a conjunction" do
      expect(lexand(words)).to eq(conjunction)
    end
  end
end
