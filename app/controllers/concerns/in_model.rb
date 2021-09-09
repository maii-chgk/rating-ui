module InModel
  DEFAULT_MODEL = "b".freeze

  def current_model
    Model.find_by(name: params[:model] || DEFAULT_MODEL)
  end
end
