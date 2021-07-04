CommandProposal::Engine.routes.draw do
  root to: "tasks#index"

  resources :tasks, path: "/" do
    get :error, on: :collection

    resource :runner, only: :create
    resources :iterations, shallow: true
  end
end
