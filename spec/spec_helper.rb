# frozen_string_literal: true

require "respawn"

ENV["RUBY_ENV"] ||= "test"

module EnvHelper
  # Stub ENV.fetch for the given keys, honouring both the block and the
  # default-argument fallback forms. Keys not listed fall through to the
  # caller's own default/block.

  def stub_env(values)
    allow(ENV).to receive(:fetch) do |key, default = nil, &block|
      next values.fetch(key) if values.key?(key)

      block ? block.call : default
    end
  end
end

RSpec.configure do |config|
  config.include EnvHelper

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
