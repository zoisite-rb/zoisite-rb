# frozen_string_literal: true

module Zoisite
  module Rack
    autoload :Logger, "rails/rack/logger"
    autoload :SilenceRequest, "rails/rack/silence_request"
  end
end
