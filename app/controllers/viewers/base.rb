# frozen_string_literal: true

module Viewers
  class Base < ApplicationController
    before_action :authenticate_viewer!
    layout 'viewers'
  end
end
