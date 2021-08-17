module CommandProposal
  class EngineController < ::ApplicationController
    include ::CommandProposal::ApplicationHelper
    helper Rails.application.routes.url_helpers
  end
end
