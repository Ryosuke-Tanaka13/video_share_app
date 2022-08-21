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
  end

  resources :viewers do
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
  end

  post 'users_create', to: 'users#create'
  # =================================================================

  # 共通==============================================================
  # 利用規約
  get 'use' => 'use#index'
  # トップページ
  root 'use#top'
  # =================================================================
end
