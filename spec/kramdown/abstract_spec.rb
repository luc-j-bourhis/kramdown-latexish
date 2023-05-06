RSpec.describe 'LaTeXish Kramdown.', type: :document do
  example 'Abstract' do
    source = <<~'MD'
      Some text before.

      Abstract

      The text of the abstract would go here.

      \Abstract

      Some text after.
    MD
    expected = <<~'HTML_'
      <p>Some text before.</p>

      <div class="abstract">

        <p>The text of the abstract would go here.</p>

      </div>

      <p>Some text after.</p>
    HTML_
    expect(to_html(source)).to eq(expected)
  end
end