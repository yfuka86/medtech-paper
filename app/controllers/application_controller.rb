class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    params["user"]['department'] = params["user"].try(:[], 'department').try(:to_i) if params["user"].try(:[], 'department').present?
    customized_params = [:username, :hospital_name, :department, :prefecture]
    devise_parameter_sanitizer.for(:sign_in).concat customized_params
    devise_parameter_sanitizer.for(:sign_up).concat customized_params
    devise_parameter_sanitizer.for(:account_update).concat customized_params
  end
end
