RSpec.describe 'LaTeX macros', type: :document do
  it 'should have a math block with them' do
    source = <<~'MD'
      Title
      =====

      $$ \testmacro $$
    MD
    expected = <<~'HTML_'
      <div style="display:none">
      \[\text{\LaTeX Macros:}
      \newcommand{\testmacro}{1 + \frac{1}{x}}
      \newcommand{\testmacrobis}{1 - \frac{1}{x}}\]
      </div>
      <h1>Title</h1>

      \[\testmacro\]
    HTML_
    macros = ['\newcommand{\testmacro}{1 + \frac{1}{x}}',
              '\newcommand{\testmacrobis}{1 - \frac{1}{x}}']
    expect(to_html(source, :latex_macros => macros)).to eq(expected)
    expected.gsub!('display:none', 'display:block')
    expect(to_html(source,
                   :latex_macros => macros,
                   :hide_latex_macros? => false)).to eq(expected)
  end
end
