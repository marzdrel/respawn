# frozen_string_literal: true

require "respawn"

ENV["RUBY_ENV"] ||= "test"

RSpec.configure do |config|
  config.order = :random
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Make sure to fail CI if someone leaves :focus tag in the specs by
  # mistake. Otherwise this might force CI to run only focused specs and pass
  # the build skiping majority of the tests.

  if ENV.fetch("CI", false)
    config.before(:example, :focus) do
      raise "You should not commit focused specs"
    end
  else
    config.filter_run focus: true
    config.run_all_when_everything_filtered = true
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
