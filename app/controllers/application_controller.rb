class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::StatementInvalid, with: :show_errors
  before_action :validate_model_name

  protected

  def force_trailing_slash
    redirect_to request.original_url + '/' unless request.original_url.match(/\/$/)
  end

  def render_404
    render file: "#{Rails.root}/public/404.html", status: :not_found
  end

  private

  def validate_model_name
    unless params[:model].blank? || params[:model] =~ /\A[a-zA-Z_]+\z/
      render plain: "Такой модели нет", status: :bad_request
    end
  end

  def show_errors(exception)
    @exception = exception
    render template: "errors/model_error", status: :internal_server_error
  end
end
