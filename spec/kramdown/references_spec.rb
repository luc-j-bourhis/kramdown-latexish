RSpec.describe 'LaTeXish Kramdown.', type: :document do
  example 'Internal references to a section' do
    source = <<~'MD'
      ## Alpha

      ## Bravo {#mark}

      As discussed earlier, [cref:mark] is dedicated to ...

      Check that a vanilla reference link still works: [CERN].

      [CERN]: https://cern.ch "The Home of LHC"
    MD
    expected = <<~'HTML_'
      <h2>1 Alpha</h2>

      <h2 id="mark">2 Bravo</h2>

      <p>As discussed earlier, section&nbsp;<a href="#mark" title="Section 2">2</a> is dedicated to …</p>

      <p>Check that a vanilla reference link still works: <a href="https://cern.ch" title="The Home of LHC">CERN</a>.</p>

    HTML_
    expect(to_html(source)).to eq(expected)
  end

  example 'Internal reference to a theorem-like environment' do
    source = <<~'MD'
      Theorem
      {: #ref1}
      \Theorem

      Lemma
      {: #ref2}
      \Lemma

      Theorem
      {: #ref4}
      \Theorem

      ## Section {#ref3}

      Capitalised. [Cref: ref1]

      Not capitalised: [cref:ref2]

      Capitalised again. [Cref:ref3]

      And again. [Cref:ref4]
    MD
    expected = <<~'HTML_'
      <section id="ref1" class="theorem-like">
        <h5><strong>Theorem 1</strong></h5>
      </section>

      <section id="ref2" class="theorem-like">
        <h5><strong>Lemma 1</strong></h5>
      </section>

      <section id="ref4" class="theorem-like">
        <h5><strong>Theorem 2</strong></h5>
      </section>

      <h2 id="ref3">1 Section</h2>

      <p>Capitalised. Theorem&nbsp;<a href="#ref1" title="Theorem 1">1</a></p>

      <p>Not capitalised: lemma&nbsp;<a href="#ref2" title="Lemma 1">1</a></p>

      <p>Capitalised again. Section&nbsp;<a href="#ref3" title="Section 1">1</a></p>

      <p>And again. Theorem&nbsp;<a href="#ref4" title="Theorem 2">2</a></p>
    HTML_
    expect(to_html(source)).to eq(expected)
  end

  example 'Internal references should work before what they refer to' do
    source = <<~'MD'
      Referring to [cref:ref1]

      ## One {#ref1}

      ## Two {#ref2}

      Referring again to [cref:ref1] as well as to [cref:ref2]
    MD
    expected = <<~'HTML_'
      <p>Referring to section&nbsp;<a href="#ref1" title="Section 1">1</a></p>

      <h2 id="ref1">1 One</h2>

      <h2 id="ref2">2 Two</h2>

      <p>Referring again to section&nbsp;<a href="#ref1" title="Section 1">1</a> as well as to section&nbsp;<a href="#ref2" title="Section 2">2</a></p>
    HTML_
    expect(to_html(source)).to eq(expected)
  end

  example 'References to multiple targets of the same type' do
    source = <<~'MD'
      ## One {#ref1}

      ## Two {#ref2}

      Referring to [cref: ref1, ref2]
    MD
    expected = <<~'HTML_'
      <h2 id="ref1">1 One</h2>

      <h2 id="ref2">2 Two</h2>

      <p>Referring to sections&nbsp;<a href="#ref1" title="Section 1">1</a> and&nbsp;<a href="#ref2" title="Section 2">2</a></p>
    HTML_
    expect(to_html(source)).to eq(expected)
  end

  example 'References to multiple targets of different types' do
    source = <<~'MD'
      ## One {#ref1}

      ## Two {#ref2}

      Referring to [cref:ref1,ref2,ref5,ref4,ref6,ref3,ref7,ref8]

      Theorem
      {: #ref4}

      \Theorem

      Lemma
      {: #ref5}

      \Lemma

      Lemma
      {: #ref6}

      \Lemma

      Theorem
      {: #ref7}

      \Theorem

      Property
      {: #ref8}

      \Property

      ## Three {#ref3}
    MD
    expected = <<~'HTML_'
      <h2 id="ref1">1 One</h2>

      <h2 id="ref2">2 Two</h2>

      <p>Referring to sections&nbsp;<a href="#ref1" title="Section 1">1</a>, <a href="#ref2" title="Section 2">2</a>, and&nbsp;<a href="#ref3" title="Section 3">3</a>, lemmas&nbsp;<a href="#ref5" title="Lemma 1">1</a> and&nbsp;<a href="#ref6" title="Lemma 2">2</a>, theorems&nbsp;<a href="#ref4" title="Theorem 1">1</a> and&nbsp;<a href="#ref7" title="Theorem 2">2</a>, and property&nbsp;<a href="#ref8" title="Property 1">1</a></p>

      <section id="ref4" class="theorem-like">
        <h5><strong>Theorem 1</strong></h5>

      </section>

      <section id="ref5" class="theorem-like">
        <h5><strong>Lemma 1</strong></h5>

      </section>

      <section id="ref6" class="theorem-like">
        <h5><strong>Lemma 2</strong></h5>

      </section>

      <section id="ref7" class="theorem-like">
        <h5><strong>Theorem 2</strong></h5>

      </section>

      <section id="ref8" class="theorem-like">
        <h5><strong>Property 1</strong></h5>

      </section>

      <h2 id="ref3">3 Three</h2>
    HTML_
    expect(to_html(source)).to eq(expected)
  end

  example 'Reference to one equation' do
    source = <<~'MD'
      This display equation is [cref:eq1]

      $$ e^x = \sum_{n=0}^{+\infty} \frac{x^n}{n!} \label{eq1} $$

      and we refer to it again capitalised. [Cref:eq1]
    MD
    expected = <<~'HTML_'
      <p>This display equation is eqn&nbsp;\eqref{eq1}</p>

      \[e^x = \sum_{n=0}^{+\infty} \frac{x^n}{n!} \label{eq1}\]

      <p>and we refer to it again capitalised. Eqn&nbsp;\eqref{eq1}</p>
    HTML_
    expect(to_html(source)).to eq(expected)
  end

  example 'Reference to several equations' do
    source = <<~'MD'
      The Taylor series of the exponential is given by [cref:eq1]

      $$ \begin{aligned}
      e^x &= \sum_{n=0}^{+\infty} \frac{x^n}{n!} \label{eq1} \\
      \log x &= \sum_{n=0}^{+\infty} (-1)^2\frac{x^n}{n} \label{eq2}
      $$

      whereas [cref:eq1] is that of the logarithm. Both [cref:eq1,eq2] ...
    MD
    expected = <<~'HTML_'
      <p>The Taylor series of the exponential is given by eqn&nbsp;\eqref{eq1}</p>

      \[\begin{aligned}
      e^x &amp;= \sum_{n=0}^{+\infty} \frac{x^n}{n!} \label{eq1} \\
      \log x &amp;= \sum_{n=0}^{+\infty} (-1)^2\frac{x^n}{n} \label{eq2}\]

      <p>whereas eqn&nbsp;\eqref{eq1} is that of the logarithm. Both eqns&nbsp;\eqref{eq1} and&nbsp;\eqref{eq2} …</p>
    HTML_
    expect(to_html(source)).to eq(expected)
  end

  example 'Undefined reference' do
    source = <<~'MD'
      [Cref:ref] is nowhere to be seen
    MD
    expected = <<~'HTML_'
      <p>¿ref? is nowhere to be seen</p>
    HTML_
    expect(to_html(source)).to eq(expected)
  end
end
