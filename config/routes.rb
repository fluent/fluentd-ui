Rails.application.routes.draw do
  root "fluentd#index" # TODO: change to dashboard

  resources :fluentd do
    resource :agent, only: [:show], module: :fluentd do
      put "start"
      put "stop"
      put "restart"
      get "log"
      get "log_tail"
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

  resource :user, only: [:show, :edit, :update]

  get "misc" => "misc#show"
  get "misc/information"

  namespace :polling do
    get "alerts"
  end

  namespace :tutorials do
    get "/" => :index
    get "chapter1"
    get "chapter2"
    get "chapter3"
    get "chapter4"
    get "chapter5"
    get "log_tail"
    post "request_fluentd"
  end
end
