class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # helper_method :current_member
  serialization_scope :current_member

  private

    def current_member
      User.first
    end
end
