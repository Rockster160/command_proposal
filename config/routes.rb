CommandProposal::Engine.routes.draw do
  root to: "tasks#index"

  resources :tasks, path: "/" do
    get :error, on: :collection

    resources :runner, only: [:create, :show]
    resources :iterations, shallow: true
  end
end
