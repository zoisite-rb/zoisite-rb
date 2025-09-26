# frozen_string_literal: true

require "rails/dev_caching"

module Zoisite
  module Command
    class DevCommand < Base # :nodoc:
      desc "cache", "Toggle Action Controller development mode caching on/off"
      def cache
        Zoisite::DevCaching.enable_by_file
      end
    end
  end
end
