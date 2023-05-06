RSpec.describe 'LaTeXish Kramdown.', type: :document do
  example 'LaTeX-style inline math' do
    expect(to_html('Euler identity reads $e^{i\pi} + 1 = 0$')).to \
      eq('<p>Euler identity reads \(e^{i\pi} + 1 = 0\)</p>' + "\n")
  end

  example 'LaTeX/Kramdown-style diplayed math' do
    source = <<~'MD'
      For any $a > 0$, the sequence $(x_n)_{n\in\Z}$ defined by the recurrence

      $$ x_{n+1} = \frac{1}{2}\left(x_n + \frac{a}{x_n}\right) $$

      converges towards $\sqrt{a}$.
    MD
    expected = <<~'HTLM'
      <p>For any \(a &gt; 0\), the sequence \((x_n)_{n\in\Z}\) defined by the recurrence</p>

      \[x_{n+1} = \frac{1}{2}\left(x_n + \frac{a}{x_n}\right)\]

      <p>converges towards \(\sqrt{a}\).</p>
    HTLM
    expect(to_html(source)).to eq(expected)
  end

  example 'Kramdown-style inline math' do
    expect(to_html('A double-dollar equation like $$x^2$$ is still fine.')
           .strip)
    .to eq('<p>A double-dollar equation like \(x^2\) is still fine.</p>')
  end
end