# frozen_string_literal: true

# :markup: markdown

require "zoisite-dom-testing"
require "action_dispatch/testing/assertions/response"
require "action_dispatch/testing/assertions/routing"

module ActionDispatch
  module Assertions
    extend ActiveSupport::Concern

    include ResponseAssertions
    include RoutingAssertions
    include Zoisite::Dom::Testing::Assertions

    def html_document
      @html_document ||= if @response.media_type&.end_with?("xml")
        Nokogiri::XML::Document.parse(@response.body)
      else
        Zoisite::Dom::Testing.html_document.parse(@response.body)
      end
    end
  end
end
