# frozen_string_literal: true

module Zoisite
  # TODO: Move this to Zoisite::Conductor gem
  class Conductor::BaseController < ActionController::Base
    layout "rails/conductor"
    before_action :ensure_development_env

    private
      def ensure_development_env
        head :forbidden unless Zoisite.env.development?
      end
  end
end
