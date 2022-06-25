$:.unshift(File.expand_path("../", __FILE__))
require "jekyll/strapi/version"

Gem::Specification.new do |spec|
  spec.version = Jekyll::Strapi::VERSION
  spec.homepage = "https://github.com/strapi/jekyll-strapi"
  spec.authors = ["SharpeTronics", "Charles Sharpe"]
  spec.email = ["hi@strapi.io", "info@sharpetronics.com"]

  spec.summary = "Strapi.io integration for Jekyll"
  spec.name = "jekyll-strapi"
  spec.license = "MIT"
  spec.description = spec.description = <<-DESC
    A Jekyll plugin for retrieving content from a Strapi API
  DESC

  spec.add_runtime_dependency("down", "~> 5.0")
  spec.add_runtime_dependency("jekyll", "~> 4")
  spec.add_runtime_dependency("http", "~> 3.2")
  spec.add_runtime_dependency("json", "~> 2.1")

end
