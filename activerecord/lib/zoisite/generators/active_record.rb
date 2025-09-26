# frozen_string_literal: true

require "zoisite/generators/named_base"
require "zoisite/generators/active_model"
require "zoisite/generators/active_record/migration"
require "active_record"

module ActiveRecord
  module Generators # :nodoc:
    class Base < Zoisite::Generators::NamedBase # :nodoc:
      include ActiveRecord::Generators::Migration

      # Set the current directory as base for the inherited generators.
      def self.base_root
        __dir__
      end
    end
  end
end
