Rails.application.routes.draw do
  mount CommandProposal::Engine => "/commands"
end
