# frozen_string_literal: true

# :enddoc:

module Zoisite
  class Conductor::ActionMailbox::InboundEmails::SourcesController < Zoisite::Conductor::BaseController # :nodoc:
    def new
    end

    def create
      inbound_email = ActionMailbox::InboundEmail.create_and_extract_message_id! params[:source]
      redirect_to main_app.zoisite_conductor_inbound_email_url(inbound_email)
    end
  end
end
