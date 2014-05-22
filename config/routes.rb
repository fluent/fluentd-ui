Rails.application.routes.draw do
  root "fluentd#index" # TODO: change to dashboard

  resources :fluentd, only: [:index] do
    resource :daemon, only: [:show], module: :fluentd do
      put "start"
      put "stop"
      put "reload"
      get "log"
    end
    resource :setting, only: [:show, :edit, :update], module: :fluentd do
    end
  end

  resource :sessions

  resources :plugins do
    collection do
      get :installed
      get :recommended
      get :updated
      patch :install
      patch :uninstall
      patch :upgrade
    end
  end


  resource :misc do
    get "information"
    resource :user, only: [:show, :edit, :update]
  end
end
