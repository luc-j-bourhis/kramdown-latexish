require 'kramdown/latexish/bibliographical'

RSpec.describe 'Clean BibTeX field' do
  include Kramdown::Latexish::Bibliographical

  example "without equations" do
    cleaned = clean_bibtex('xxx {YY} xxx {ZZ} xxx')
    expect(cleaned).to eq('xxx YY xxx ZZ xxx')
  end

  example "with equations" do
    cleaned = clean_bibtex('xxx {Y} xxx $\bar{A}$ xxx {Z}')
    expect(cleaned).to eq('xxx Y xxx $\bar{A}$ xxx Z')
  end

  example "with mhchem in text mode" do
    cleaned = clean_bibtex('xxx \ce{CO_2} yyy')
    expect(cleaned).to eq('xxx $\ce{CO_2}$ yyy')
  end
end
