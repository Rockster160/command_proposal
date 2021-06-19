CommandProposal::Engine.routes.draw do
  root to: "tasks#index"

  resources :tasks, path: "/" do
    get :error, on: :collection
  end
  resources :iterations
end
