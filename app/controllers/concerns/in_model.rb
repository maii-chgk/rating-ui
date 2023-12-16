# frozen_string_literal: true

module InModel
  DEFAULT_MODEL = "b"
  MISSING_MODEL_ERROR = "Модели с таким именем нет"

  def current_model
    Model.find_by(name: params[:model] || DEFAULT_MODEL)
  end

  def show_missing_model_error(_exception)
    render plain: MISSING_MODEL_ERROR, status: :bad_request
  end
end
