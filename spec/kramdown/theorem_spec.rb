RSpec.describe 'LaTeXish Kramdown.', type: :document do
  example 'Theorem' do
    source = <<~'MD'
      Some text before.

      Theorem (Hölder inequality)

      For any real-valued functions $f$ and $g$ integrable on the interval $[a,b]$, and any real $p$ and $q$ such that

      $$ \frac{1}{p} + \frac{1}{q} = 1 $$

      the following inequality holds

      $$
      \left|\int_a^b f(x)g(x)dx\right| \leq
      \left(\int_a^b f(x)^p\right)^\frac{1}{p}
      \left(\int_a^b g(x)^q\right)^\frac{1}{q}
      $$

      \Theorem

      Some text after.
    MD
    expected = <<~'HTML_'
      <p>Some text before.</p>

      <section class="theorem-like">
        <h5><strong>Theorem 1</strong> (Hölder inequality)</h5>

        <p>For any real-valued functions \(f\) and \(g\) integrable on the interval \([a,b]\), and any real \(p\) and \(q\) such that</p>

      \[\frac{1}{p} + \frac{1}{q} = 1\]

        <p>the following inequality holds</p>

      \[\left|\int_a^b f(x)g(x)dx\right| \leq
      \left(\int_a^b f(x)^p\right)^\frac{1}{p}
      \left(\int_a^b g(x)^q\right)^\frac{1}{q}\]

      </section>

      <p>Some text after.</p>
    HTML_
    expect(to_html(source)).to eq(expected)
  end

  example 'Theorem start tag needs to be in his own paragraph' do
    source_1 = <<~'MD'
      Some text before.
      Lemma

      The text of the lemma would go here.

      \Lemma

      Some text after.
    MD
    expected_1 = <<~'HTML_'
      <p>Some text before.
      Lemma</p>

      <p>The text of the lemma would go here.</p>

      <p>\Lemma</p>

      <p>Some text after.</p>
    HTML_
    expect(to_html(source_1)).to eq(expected_1)

    source_2 = <<~'MD'
      Some text before.

      Lemma (some description)
      The text of the lemma would go here.

      \Lemma

      Some text after.
    MD
    expected_2 = <<~'HTML_'
      <p>Some text before.</p>

      <p>Lemma (some description)
      The text of the lemma would go here.</p>

      <p>\Lemma</p>

      <p>Some text after.</p>
    HTML_
    expect(to_html(source_2)).to eq(expected_2)

    source_3 = <<~'MD'
      Some text before.

      Lemma (some description) The text of the lemma would go here.

      \Lemma

      Some text after.
    MD
    expected_3 = <<~'HTML_'
      <p>Some text before.</p>

      <p>Lemma (some description) The text of the lemma would go here.</p>

      <p>\Lemma</p>

      <p>Some text after.</p>
    HTML_
    expect(to_html(source_3)).to eq(expected_3)

  end

  example 'Theorem end tag needs to start a separate paragraph.' do
    source_1 = <<~'MD'
      Some text before.

      Lemma

      The text of the lemma would go here.
      \Lemma

      Some text after.
    MD
    expected_1 = <<~'HTML_'
      <p>Some text before.</p>

      <p>Lemma</p>

      <p>The text of the lemma would go here.
      \Lemma</p>

      <p>Some text after.</p>
    HTML_
    expect(to_html(source_1)).to eq(expected_1)

    source_2 = <<~'MD'
      Some text before.

      Lemma

      The text of the lemma would go here. \Lemma

      Some text after.
    MD
    expected_2 = <<~'HTML_'
      <p>Some text before.</p>

      <p>Lemma</p>

      <p>The text of the lemma would go here. \Lemma</p>

      <p>Some text after.</p>
    HTML_
    expect(to_html(source_2)).to eq(expected_2)
  end

  example 'Theorem end tag needs to start a new paragraph after a list.' do
    source_1 = <<~'MD'
      Some text before.

      Lemma

      - item one
      - item two
      \Lemma

      Some text after.
    MD
    expected_1 = <<~'HTML_'
      <p>Some text before.</p>

      <p>Lemma</p>

      <ul>
        <li>item one</li>
        <li>item two
      \Lemma</li>
      </ul>

      <p>Some text after.</p>
    HTML_
    source_2 = <<~'MD'
      Some text before.

      Lemma

      - item one
      - item two

      \Lemma

      Some text after.
    MD
    expected_2 = <<~'HTML_'
      <p>Some text before.</p>

      <section class="theorem-like">
        <h5><strong>Lemma 1</strong></h5>

        <ul>
          <li>item one</li>
          <li>item two</li>
        </ul>

      </section>

      <p>Some text after.</p>
    HTML_
    expect(to_html(source_1)).to eq(expected_1)
    expect(to_html(source_2)).to eq(expected_2)
  end

  example 'Theorem end tag needs to be the end of a paragraph.' do
    source = <<~'MD'
      Some text before.

      Lemma

      The text of the lemma would go here.

      \Lemma
      Some text after.
    MD
    expected = <<~'HTML_'
      <p>Some text before.</p>

      <p>Lemma</p>

      <p>The text of the lemma would go here.</p>

      <p>\Lemma
      Some text after.</p>
    HTML_
    expect(to_html(source)).to eq(expected)
  end

  example 'Missing end tag does not generate theorem environment' do
    source = <<~'MD'
      Some text before.

      Lemma

      The text of the lemma would go here.

      Theorem

      The text of the theorem would go here.

      \Theorem

      Some text after.
    MD
    expected = <<~'HTML_'
      <p>Some text before.</p>

      <p>Lemma</p>

      <p>The text of the lemma would go here.</p>

      <section class="theorem-like">
        <h5><strong>Theorem 1</strong></h5>

        <p>The text of the theorem would go here.</p>

      </section>

      <p>Some text after.</p>
    HTML_
    expect(to_html(source)).to eq(expected)
  end

  example 'Theorem with attributes beforehand' do
    source = <<~'MD'
      Some text before.

      {: #lemma12 .important}
      Lemma

      The text of the lemma would go here.

      \Lemma

      Some text after.
    MD
    expected = <<~'HTML_'
      <p>Some text before.</p>

      <section id="lemma12" class="important theorem-like">
        <h5><strong>Lemma 1</strong></h5>

        <p>The text of the lemma would go here.</p>

      </section>

      <p>Some text after.</p>
    HTML_
    expect(to_html(source)).to eq(expected)
  end

  example 'Theorem with attributes afterward' do
    source = <<~'MD'
      Some text before.

      Lemma
      {: #lemma12 .important}

      The text of the lemma would go here.

      \Lemma

      Some text after.
    MD
    expected = <<~'HTML_'
      <p>Some text before.</p>

      <section id="lemma12" class="important theorem-like">
        <h5><strong>Lemma 1</strong></h5>

        <p>The text of the lemma would go here.</p>

      </section>

      <p>Some text after.</p>
    HTML_
    expect(to_html(source)).to eq(expected)
  end

  example 'Theorem in French' do
    source = <<~'MD'
      Du texte avant.

      {: #theorem12 .important}
      Théorème (Une description ici)

      Le texte du théorème irait ici.

      \Théorème

      Du texte après.
    MD
    expected = <<~'HTML_'
      <p>Du texte avant.</p>

      <section id="theorem12" class="important theorem-like">
        <h5><strong>Théorème 1</strong> (Une description ici)</h5>

        <p>Le texte du théorème irait ici.</p>

      </section>

      <p>Du texte après.</p>
    HTML_
    expect(to_html(source, :language => :french)).to eq(expected)
  end
end