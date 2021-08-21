class ApplicationController < ActionController::Base
  before_action :validate_model_name

  private

  def validate_model_name
    unless params[:model] =~ /\A[a-zA-Z_]+\z/
      render text: "Такой модели нет", content_type: 'text/plain', status_code: :bad_request
    end
  end
end
