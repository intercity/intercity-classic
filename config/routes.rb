require "sidekiq/web"
require 'sidekiq-status/web'

Intercity::Application.routes.draw do
  scope "setup", module: "onboarding" do
    root to: "apps#start", as: "setup"
    get "app" => "apps#new", as: "setup_app"
    post "app" => "apps#create"

    get "provider" => "providers#new", as: "setup_provider"
    post "provider" => "providers#create"

    get "droplet" => "droplets#new", as: "setup_droplet"
    post "summary/droplet" => "droplets#create", as: "setup_droplet_summary"
    get "summary/droplet" => redirect("/setup/droplet")

    get "custom_server" => "custom_servers#new", as: "setup_custom_server"
    post "custom_server/test_ip" => "custom_servers#test_ip", as: "setup_test_ip"
    post "custom_server/test_ssh" => "custom_servers#test_ssh", as: "setup_test_ssh"
    get "summary/custom_server" => "custom_servers#show", as: "setup_custom_server_summary"

    post "finalize" => "servers#create", as: "setup_finalize"
    get ":id/progress" => "servers#show", as: "setup_install_server"
    get ":id/poll" => "servers#poll", as: "setup_poll"

    get "deploy_key" => "deploy_keys#new", as: "setup_deploy_key"
    post "deploy_key" => "deploy_keys#create"
    get "deploy_key/apply" => "deploy_keys#show", as: "setup_apply_deploy_key"
  end

  get "/apps" => "apps_overview#index", as: :app_overview

  get "onboarding/add_key" => "onboarding#add_key"
  get "onboarding/key_progress" => "onboarding#key_progress"


  mount RailsAdmin::Engine => "/admin", as: "rails_admin"
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  authenticate :user, lambda { |u| u.admin? } do
    mount Flipper::UI.app(FeatureFlipper.new) => '/flipper'
  end

  devise_for :users, controllers: { registrations: "registrations"}

  devise_scope :user do
    get "login" => "devise/sessions#new"
    get "signup" => "devise/registrations#new"
  end

  root :to => "dashboard#index"
  get "/" => "dashboard#index", as: :dashboard

  post "trial/signup" => "trial#signup"
  get "trial/availability" => "trial#availability"

  scope "backups" do
    get "fetch" => "backups#fetch", as: "fetch_backups"
    root to: "backups#overview", as: "backups"
  end

  resources :servers, param: :server_id do
    member do
      post :bootstrap
      get :bootstrapping
      get  :setup
      get  :check_bootstrap_status
      get :poll
      get  :log
      get  :remove
      get  :error
    end
    collection do
      get :upgrade_plan
    end
  end

  scope "servers/:server_id" do
    resources :ssh_keys, only: [:index, :new, :create, :destroy]
    resources :applications, except: [:destroy], param: :app_id, path: "apps" do
      member do
        get :applying
        get :deploy
        delete :destroy
      end
    end

    scope "apps/:app_id" do
      resource :database, only: [:show, :update], controller: "application_databases"
      resource :ssl_certificates, only: [:new, :create] do
        collection do
          get :show
          delete :destroy
        end
      end
      resources :env_vars, only: [:index, :create, :destroy] do
        collection do
          post :apply
        end
      end

      resources :backups, only: [:none] do
        collection do
          get :index, as: :app
          patch :update
          post :force_backup, as: :force
        end
      end
    end
  end

  scope "account" do
    root to: "accounts#show", as: "account"
    patch "/" => "accounts#update"
  end

  if Rails.env.development?
    get "styleguide/(:category)" => "styleguides#index", defaults: { category: "typography" }, as: "styleguide"
  end
end
