# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "jekyll-theme-mutter"
  spec.version       = "0.3.0"
  spec.authors       = ["Gary Wang"]
  spec.email         = ["wzc782970009@gmail.com"]

  spec.summary       = "A theme for jekyll."
  spec.homepage      = "https://github.com/BLumia/jekyll-theme-mutter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r!^(assets|_(includes|layouts|sass)/|(LICENSE|README)((\.(txt|md|markdown)|$)))!i)
  end

  spec.add_runtime_dependency "jekyll", "~> 3.8"
  spec.add_runtime_dependency "jekyll-feed", "~> 0.9"
  spec.add_runtime_dependency "jekyll-seo-tag", "~> 2.1"
  spec.add_development_dependency "bundler", ">= 2.1.0"
  spec.add_development_dependency "rake", "~> 12.0"
end
