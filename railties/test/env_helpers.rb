# frozen_string_literal: true

require "zoisite"

module EnvHelpers
  private
    def with_zoisite_env(env, &block)
      Zoisite.instance_variable_set :@_env, nil
      switch_env "RAILS_ENV", env do
        switch_env "RACK_ENV", nil, &block
      end
    end

    def with_rack_env(env, &block)
      Zoisite.instance_variable_set :@_env, nil
      switch_env "RACK_ENV", env do
        switch_env "RAILS_ENV", nil, &block
      end
    end

    def switch_env(key, value)
      old, ENV[key] = ENV[key], value
      yield
    ensure
      ENV[key] = old
    end
end
