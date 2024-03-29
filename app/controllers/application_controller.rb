# frozen_string_literal: true

class ApplicationController < ActionController::Base
  unless Rails.env.local?
    rescue_from NoMethodError, with: :show_missing_model_error
    rescue_from ActiveRecord::StatementInvalid, with: :show_model_errors
  end

  before_action :validate_model_name

  protected

  def force_trailing_slash
    redirect_to "#{request.original_url}/" unless request.original_url.match(%r{/$})
  end

  def render_404
    render file: Rails.root.join("public/404.html"), status: :not_found
  end

  private

  def validate_model_name
    return if params[:model].blank? || params[:model] =~ /\A[a-zA-Z_]+\z/

    render plain: InModel::MISSING_MODEL_ERROR, status: :bad_request
  end

  def show_model_errors(exception)
    @exception = exception
    render template: "errors/model_error", status: :internal_server_error
  end

  def show_missing_model_error(_exception)
    raise unless current_model.nil?

    render plain: "Такой модели нет", status: :bad_request
  end
end
