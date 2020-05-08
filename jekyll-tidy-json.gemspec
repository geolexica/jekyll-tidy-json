require_relative 'lib/jekyll/tidy_json/version'

ALL_FILES_IN_GIT = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

Gem::Specification.new do |spec|
  spec.name          = "jekyll-tidy-json"
  spec.version       = Jekyll::TidyJSON::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "A Jekyll plugin that cleans JSONs up."
  spec.description   = spec.summary + " If you use Liquid templates to build " +
                       "JSONs for your site, then you probably really want it."
  spec.homepage      = "https://github.com/geolexica/jekyll-tidy-json"
  spec.license       = "MIT"

  spec.metadata = {
    "bug_tracker_uri"   => (spec.homepage + "/issues"),
    "homepage_uri"      => spec.homepage,
    "source_code_uri"   => spec.homepage,
  }

  spec.files         = ALL_FILES_IN_GIT.reject do |f|
    f.match(%r{^(test|spec|features|.github)/}) ||
    %w[.editorconfig .gitignore .rspec].include?(f)
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.add_runtime_dependency "jekyll", ">= 3.8", "< 5"

  spec.add_development_dependency "rspec", "~> 3.9"
end
