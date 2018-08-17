Rails.application.routes.draw do
  root "welcome#home"

  resource :daemon, controller: :fluentd do
    get "log"
    get "raw_log"
    get "errors"

    scope module: :fluentd do
      resource :agent, only: [] do
        put "start"
        put "stop"
        put "restart"
        put "reload"
        get "log_tail"
      end

      resource :setting, only: [:show, :edit, :update] do
        get "source_and_output"

        resource :in_tail, only: [:show], module: :settings, controller: :in_tail do
          post "after_file_choose"
          post "after_format"
          post "confirm"
          post "finish"
        end

        resource :in_syslog, only: [:show], module: :settings, controller: :in_syslog do
          post "finish"
        end

        resource :in_monitor_agent, only: [:show], module: :settings, controller: :in_monitor_agent do
          post "finish"
        end

        resource :in_http, only: [:show], module: :settings, controller: :in_http do
          post "finish"
        end

        resource :in_forward, only: [:show], module: :settings, controller: :in_forward do
          post "finish"
        end

        resource :out_stdout, only: [:show], module: :settings, controller: :out_stdout do
          post "finish"
        end

        resource :out_mongo, only: [:show], module: :settings, controller: :out_mongo do
          post "finish"
        end

        resource :out_tdlog, only: [:show], module: :settings, controller: :out_tdlog do
          post "finish"
        end

        resource :out_s3, only: [:show], module: :settings, controller: :out_s3 do
          post "finish"
        end

        resource :out_forward, only: [:show], module: :settings, controller: :out_forward do
          post "finish"
        end

        resource :out_elasticsearch, only: [:show], module: :settings, controller: :out_elasticsearch do
          post "finish"
        end

        resources :histories, only: [:index, :show], module: :settings, controller: :histories do
          post "reuse", action: 'reuse', on: :member, as: 'reuse'
          post "configtest" , action: "configtest", on: :member, as: "configtest"
        end

        resources :notes, only: [:update], module: :settings, controller: :notes

        resource :running_backup, only: [:show], module: :settings, controller: :running_backup do
          post "reuse", action: 'reuse', on: :member, as: 'reuse'
          post "configtest" , action: "configtest", on: :member, as: "configtest"
        end
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
      patch :bulk_upgrade
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

    resources :settings, only: [:index, :show, :update, :destroy], defaults: { format: "json" }
    resources :config_definitions, only: [:index], defaults: { format: "json" }
  end
end
