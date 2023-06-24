# coding: utf-8

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "metanorma/gb/version"

Gem::Specification.new do |spec|
  spec.name          = "metanorma-gb"
  spec.version       = Metanorma::Gb::VERSION
  spec.authors       = ["Ribose Inc. Zhangxin"]
  spec.email         = ["open.source@ribose.com;460212@qq.com"]

  spec.summary       = "metanorma-gb lets you write GB standards in AsciiDoc."
  spec.description   = <<~DESCRIPTION
    metanorma-gb lets you write GB standards (Chinese national standards)
    in AsciiDoc syntax.

    This gem is in active development.

    Formerly known as asciidoctor-gb.
  DESCRIPTION

  spec.homepage      = "https://github.com/metanorma/metanorma-gb"
  spec.license       = "BSD-2-Clause"

  spec.bindir        = "bin"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.add_dependency "metanorma-iso", "~> 2.4.5"
  spec.add_dependency "isodoc"
  spec.add_dependency "twitter_cldr"
  spec.add_dependency "gb-agencies"
  spec.add_dependency "htmlentities"
  spec.add_dependency "asciidoctor"

  spec.add_development_dependency "debug"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "sassc"
  spec.add_development_dependency "equivalent-xml"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "metanorma"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "materialize"
  spec.add_development_dependency "ruby-debug-ide"
  spec.add_development_dependency "debase", "=0.2.5.beta2"
end
