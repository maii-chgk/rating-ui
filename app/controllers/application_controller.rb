class ApplicationController < ActionController::Base
  before_action :validate_model_name

  private

  def validate_model_name
    unless params[:model].blank? || params[:model] =~ /\A[a-zA-Z_]+\z/
      render plain: "Такой модели нет", status: :bad_request
    end
  end
end
