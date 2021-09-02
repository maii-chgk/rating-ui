class ApplicationController < ActionController::Base
  before_action :validate_model_name

  protected

  def force_trailing_slash
    redirect_to request.original_url + '/' unless request.original_url.match(/\/$/)
  end

  private

  def validate_model_name
    unless params[:model].blank? || params[:model] =~ /\A[a-zA-Z_]+\z/
      render plain: "Такой модели нет", status: :bad_request
    end
  end
end
