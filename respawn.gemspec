# frozen_string_literal: true

require_relative "lib/respawn/version"

Gem::Specification.new do |spec|
  spec.name = "respawn"
  spec.version = Respawn::VERSION
  spec.authors = ["Mariusz Drozdziel"]
  spec.email = ["marzdrel@dotpro.org"]
  spec.summary = "Yet another way to retry some block of code in Ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.homepage = "https://github.com/marzdrel/respawn"
  spec.files = Dir["lib/**/*"]

  spec.add_development_dependency "rspec", ">= 3"

  spec.add_dependency "zeitwerk", ">= 2.6"
end
