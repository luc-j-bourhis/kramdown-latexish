RSpec.describe 'LaTeXish Kramdown.', type: :document do
  example 'Citations and References' do
    bib = BibTeX::Bibliography.parse(<<~'BIB'
      @article{Lee:SR:derivation,
        author = {Lee, A. R. and Kalotas, T. M.},
        journal = {American Journal of Physics},
        pages = {434--437},
        title = {Lorentz transformations from the first postulate},
        volume = {43},
        year = {1975}}
      @article{Einstein:SR,
        author = {Einstein, Albert},
        journal = {Annalen der Physik},
        pages = {891},
        title = {Zur {E}lektrodynamik bewegter {K}örper},
        volume = {17},
        year = {1905}}
      @article{lammerzahl:SR:test:theories,
        author = {Lämmerzahl, Claus and Braxmaier, Claus and Dittus, Hansjörg and Müller, Holger and Peters, Achim and Schiller, Stephan},
        journal = {International Journal of Modern Physics D},
        number = {07},
        pages = {1109--1136},
        title = {Kinematical Test Theories for Special Relativity: a Comparison},
        volume = {11},
        year = {2002}}
    BIB
    )
    source = <<~'MD'
      As explained in [citep: Einstein:SR]

      As explained by [citet: Einstein:SR]

      As demonstrated by [citet: Lee:SR:derivation, Einstein:SR]

      [citet: Lee:SR:derivation, Einstein:SR, *lammerzahl:SR:test:theories]

      [citep: lammerzahl:SR:test:theories]
    MD
    expected = <<~'HTML_'
      <p>As explained in <a href="#Einstein:SR">(Einstein, 1905)</a></p>

      <p>As explained by <a href="#Einstein:SR">Einstein (1905)</a></p>

      <p>As demonstrated by <a href="#Lee:SR:derivation">Lee and Kalotas (1975)</a> and <a href="#Einstein:SR">Einstein (1905)</a></p>

      <p><a href="#Lee:SR:derivation">Lee and Kalotas (1975)</a>, <a href="#Einstein:SR">Einstein (1905)</a>, and <a href="#lammerzahl:SR:test:theories">Lämmerzahl et al (2002)</a></p>

      <p><a href="#lammerzahl:SR:test:theories">(Lämmerzahl, Braxmaier, Dittus, Müller, Peters, and Schiller, 2002)</a></p>

      <h2>References</h2>

      <p class="bibliography-item" id="Einstein:SR">Einstein, A. (1905). Zur Elektrodynamik bewegter Körper. <i>Annalen Der Physik</i>, <i>17</i>, 891.</p>

      <p class="bibliography-item" id="Lee:SR:derivation">Lee, A. R., &amp; Kalotas, T. M. (1975). Lorentz transformations from the first postulate. <i>American Journal of Physics</i>, <i>43</i>, 434–437.</p>

      <p class="bibliography-item" id="lammerzahl:SR:test:theories">Lämmerzahl, C., Braxmaier, C., Dittus, H., Müller, H., Peters, A., &amp; Schiller, S. (2002). Kinematical Test Theories for Special Relativity: a Comparison. <i>International Journal of Modern Physics D</i>, <i>11</i>(07), 1109–1136.</p>
    HTML_
    expect(to_html(source, :bibliography => bib)).to eq(expected)
  end

  example 'Citations and References containing equations' do
    bib = BibTeX::Bibliography.parse(<<~'BIB'
      @article{Ohanian:2012,
        author = {Ohanian, Hans C.},
        journal = {American Journal of Physics},
        number = {12},
        pages = {1067-1072},
        title = {Klein's theorem and the proof of {$E_0=mc^2$}},
        volume = {80},
        year = {2012}}
      @article{Fischer:2019,
        author = {Fischer, Tobias P. and Arellano, Santiago and Carn, Simon and Aiuppa, Alessandro and Galle, Bo and Allard, Patrick and Lopez, Taryn and Shinohara, Hiroshi and Kelly, Peter and Werner, Cynthia and Cardellini, Carlo and Chiodini, Giovanni},
        journal = {Scientific Reports},
        month = {dec},
        number = {1},
        title = {The emissions of \ce{CO_2} and other volatiles from the world's subaerial volcanoes},
        volume = {9},
        year = 2019}
    BIB
    )
    source = <<~'MD'
      [citep: *Ohanian:2012]

      [citet: *Fischer:2019]
    MD
    expected = <<~'HTML_'
      <p><a href="#Ohanian:2012">(Ohanian, 2012)</a></p>

      <p><a href="#Fischer:2019">Fischer et al (2019)</a></p>

      <h2>References</h2>

      <p class="bibliography-item" id="Ohanian:2012">Ohanian, H. C. (2012). Klein’s theorem and the proof of \(E_0=mc^2\). <i>American Journal of Physics</i>, <i>80</i>(12), 1067–1072.</p>

      <p class="bibliography-item" id="Fischer:2019">Fischer, T. P., Arellano, S., Carn, S., Aiuppa, A., Galle, B., Allard, P., Lopez, T., Shinohara, H., Kelly, P., Werner, C., Cardellini, C., &amp; Chiodini, G. (2019). The emissions of \(\ce{CO_2}\) and other volatiles from the world’s subaerial volcanoes. <i>Scientific Reports</i>, <i>9</i>(1).</p>
    HTML_
    expect(to_html(source, :bibliography => bib)).to eq(expected)
  end

  example 'Citations without a bibliography provided' do
    source = '[citep: Weinberg1989]'
    expected = "<p>[citep: Weinberg1989]</p>\n"
    expect(to_html(source)).to eq(expected)
  end
end
