# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # organization関連==================================================
  resources :organizations do
    collection do
      scope module: :organizations do
        resources :folders
      end
    end
    member do
      scope module: :organizations do
        resource :unsubscribe, only: %i[show update] ,as: :organizations_unsubscribe
      end
    end
  end
  # =================================================================

  # system_admin関連=========================================================
  devise_for :system_admins, controllers: {
    sessions: 'system_admins/sessions'
  }

  resources :system_admins, only: %i[show edit update] do
  end
  # =================================================================

  # viewer関連==========================================================
  devise_for :viewers, controllers: {
    sessions:      'viewers/sessions',
    passwords:     'viewers/passwords',
    confirmations: 'viewers/confirmations',
    registrations: 'viewers/registrations'
  }

  namespace :viewers do
    resources :dash_boards, only: [:index]
    resource :profile, except: %i[create new]
    resources :unsubscribe, only: %i[show update] 
  end

  resources :viewers do
    member do
      scope module: :viewers do
        resource :unsubscribe, only: %i[show update] ,as: :viewers_unsubscribe
      end
    end
  end
  # =================================================================

  # user関連=======================================================
  devise_for :users, controllers: {
    sessions:      'users/sessions',
    passwords:     'users/passwords',
    confirmations: 'users/confirmations',
    registrations: 'users/registrations'
  }

  resources :users do
    member do
      scope module: :users do
        resource :unsubscribe, only: %i[show update] ,as: :users_unsubscribe
      end
    end
  end

  post 'users_create', to: 'users#create'
  # =================================================================
  # loginless_viewer関連==============================================================
  resources :loginless_viewers, except: :edit do
  end
  # =================================================================

  # 共通==============================================================
  # 利用規約
  get 'use' => 'use#index'
  # トップページ
  root 'use#top'
  # =================================================================
end
