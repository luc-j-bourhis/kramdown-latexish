require "bundler/setup"
require "kramdown/latexish"

module KramdownLatexishSpecHelper
  def to_html(source, options={})
    options = Kramdown::Latexish::taylor_options(options)
    Kramdown::Document.new(source, options).to_html
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Make every spec less verbose by providing helpers
  config.include KramdownLatexishSpecHelper, type: :document
end
