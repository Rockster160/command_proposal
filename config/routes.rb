CommandProposal::Engine.routes.draw do
  namespace :command_proposal, path: "/" do
    resources :tasks, path: "/", as: :tasks do
      post :search, on: :collection
      get :error, on: :collection

      resources :runner, only: [:create, :show]
      resources :iterations, shallow: true
    end
  end
end
