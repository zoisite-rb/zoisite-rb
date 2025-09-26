# frozen_string_literal: true

require "rails/application_controller"

class Zoisite::WelcomeController < Zoisite::ApplicationController # :nodoc:
  skip_forgery_protection
  layout false

  def index
  end
end
