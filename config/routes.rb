Rails.application.routes.draw do
  root "welcome#home"

  resource :fluentd, controller: :fluentd do
    get "log"
    get "raw_log"

    resource :agent, only: [], module: :fluentd do
      put "start"
      put "stop"
      put "restart"
      get "log_tail"
    end

    resource :setting, only: [:show, :edit, :update], module: :fluentd do
      get "source_and_output"

      resource :in_tail, only: ["show"], module: :settings, controller: :in_tail do
        post "after_file_choose"
        post "after_format"
        post "confirm"
        post "finish"
      end

      resource :in_syslog, only: ["show"], module: :settings, controller: :in_syslog do
        post "finish"
      end

      resource :out_mongo, only: ["show"], module: :settings, controller: :out_mongo do
        post "finish"
      end

      resource :out_td, only: ["show"], module: :settings, controller: :out_td do
        post "finish"
      end

      resource :out_s3, only: ["show"], module: :settings, controller: :out_s3 do
        post "finish"
      end

      resource :out_forward, only: ["show"], module: :settings, controller: :out_forward do
        post "finish"
      end
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
  post "misc/update_fluentd_ui"
  get "misc/upgrading_status"
  get "misc/download_info"

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

  namespace :api do
    get "tree"
    get "file_preview"
    post "regexp_preview"
    post "grok_to_regexp"
  end
end
