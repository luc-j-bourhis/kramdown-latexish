lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kramdown/latexish/version"

Gem::Specification.new do |spec|
  spec.name          = "kramdown-latexish"
  spec.version       = Kramdown::Latexish::VERSION
  spec.authors       = ["Luc J. Bourhis"]
  spec.email         = ["luc_j_bourhis@mac.com"]

  spec.summary       = %q{Kramdown extension for math-heavy document}
  spec.description   = %Q{#{spec.summary}. It provides theorem environments, and easy references to those environments as well as to equations and section headers. Moreover, a bibliography section can be generated from a BibTeX file, and an flexible and easy mean of citing bibliographical entries is provided. Sections and environments are
    automatically numbered.}
  spec.homepage      = "https://github.com/luc-j-bourhis/kramdown-latexish"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Tested with this version
  spec.required_ruby_version = '~> 3.0'

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-parameterized", "~> 1.0"

  # We extend this
  spec.add_runtime_dependency "kramdown", "~> 2.4"

  # BibTeX bibliography tools
  spec.add_runtime_dependency 'bibtex-ruby', "~> 6.0"

  # Render bibliography to HTML
  spec.add_runtime_dependency 'citeproc-ruby', "~> 2.0"

  # Bibliography styles
  spec.add_runtime_dependency 'csl-styles', "~> 2.0"
end
