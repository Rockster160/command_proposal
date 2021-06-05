CommandProposal::Engine.routes.draw do
  root to: "commands#index"

  # resources :command_proposal, path: "/", only: [:index, :show, :update, :edit]
end
