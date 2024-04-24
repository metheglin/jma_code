lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jma_code/version"

Gem::Specification.new do |s|
  s.name         = "jma_code"
  s.version      = JMACode::VERSION
  s.summary      = "JMA Code"
  s.description  = "JMA Code"
  s.authors      = ["metheglin"]
  s.email        = "pigmybank@gmail.com"
  s.files        = Dir["{lib}/**/*.rb", "{lib}/**/*.rake", "bin/*", "LICENSE", "*.md", "data/**/*"]
  s.homepage     = "https://rubygems.org/gems/jma_code"
  # s.executables  = %w(jma_code)
  s.require_path = 'lib'
  s.license      = "MIT"

  s.required_ruby_version = ">= 2.7"
  s.add_dependency "rake", "~> 13.0"
  # s.add_dependency "tty-prompt"
end