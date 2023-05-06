RSpec.describe 'LaTeXish Kramdown.', type: :document do
  example 'Automatically numbered sections and theorems' do
    source = <<~'MD'
      # Title

      Another Title
      =============

      ## Alpha *one*

      Theorem (Alpha)

      \Theorem

      Lemma (First)

      \Lemma

      Theorem (Beta)

      \Theorem

      ### Bravo

      #### 137 Charlie

      Lemma (Second)

      \Lemma

      Theorem (Gamma)

      \Theorem

      ### Delta

      ## Echo **thirty**

      ### 1.2.8 Foxtrot

      ### Golf

      Hotel
      -----
    MD
    expected = <<~'HTML_'
      <h1>Title</h1>

      <h1>Another Title</h1>

      <h2>1 Alpha <em>one</em></h2>

      <section class="theorem-like">
        <h5><strong>Theorem 1</strong> (Alpha)</h5>

      </section>

      <section class="theorem-like">
        <h5><strong>Lemma 1</strong> (First)</h5>

      </section>
      
      <section class="theorem-like">
        <h5><strong>Theorem 2</strong> (Beta)</h5>

      </section>
      
      <h3>1.1 Bravo</h3>

      <h4>1.1.1 Charlie</h4>

      <section class="theorem-like">
        <h5><strong>Lemma 2</strong> (Second)</h5>

      </section>
      
      <section class="theorem-like">
        <h5><strong>Theorem 3</strong> (Gamma)</h5>

      </section>
      
      <h3>1.2 Delta</h3>

      <h2>2 Echo <strong>thirty</strong></h2>

      <h3>2.1 Foxtrot</h3>

      <h3>2.2 Golf</h3>

      <h2>3 Hotel</h2>
    HTML_
    expect(to_html(source)).to eq(expected)
  end
end