class Api::Private::BaseController < ApplicationController

  before_filter :authenticate_user!

  skip_before_filter :verify_authenticity_token

  rescue_from Exception, with: :render_error
  rescue_from ActionView::MissingTemplate do
    render(
        json: {message: I18n.t(:not_found)},
        status: :not_found
    )
  end

  respond_to :json

  def render_success
    @_success = true
    render(
        json: {success: true},
        status: 200
    )
  end

  def render_error(error, options = {})
    message = ''
    if error.is_a?(Exception)
      message = error.message
    elsif error.is_a?(Hash)
      message = error[:message]
    elsif error.is_a?(String)
      message = error
    end

    status = options[:status] || :internal_server_error
    render(
        json: {message: message},
        status: status
    )
  end

  def authenticate_user!
    if valid_user.blank?
      render(
        json: {message: I18n.t(:unauthorized)},
        status: :unauthorized
      )
    end
  end

  private

  def valid_user
    return @_user if @_user
    if doorkeeper_token
      @_user = User.find(doorkeeper_token.resource_owner_id)
    else
      @_user = current_user
    end
  end
end
