module CommandProposal
  class EngineController < ::ApplicationController
    include ::CommandProposal::ApplicationHelper
    helper Rails.application.routes.url_helpers

    skip_before_action :verify_authenticity_token, raise: false
  end
end
