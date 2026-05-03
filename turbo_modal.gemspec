# frozen_string_literal: true

require_relative "lib/turbo_modal/version"

Gem::Specification.new do |spec|
  spec.name        = "turbo_modal"
  spec.version     = TurboModal::VERSION
  spec.authors     = ["Christian Finck"]
  spec.email       = ["christian@finck.at"]
  spec.summary     = "ViewComponent + controller concern for the Turbo Modal pattern."
  spec.description = "Renders a CoreUI/Turbo-frame modal with form-action footer support, plus a controller concern for redirect-style turbo_stream responses."
  spec.license     = "MIT"
  spec.homepage    = "https://github.com/finchi/turbo-modal"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["source_code_uri"] = "https://github.com/finchi/turbo-modal"

  spec.files = Dir["{app,lib}/**/*", "LICENSE", "README.md"]

  spec.add_dependency "rails",          ">= 7.2"
  spec.add_dependency "turbo-rails",    ">= 2.0"
  spec.add_dependency "view_component", ">= 3.0"
end
