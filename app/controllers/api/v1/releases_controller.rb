class Api::V1::ReleasesController < ApiController
  include InModel

  def index
    return render_error_json(error: MISSING_MODEL_ERROR) if current_model.nil?

    releases = current_model.all_releases
    render json: metadata.merge({ items: releases }), status: 200
  end

  def metadata
    {
      model: current_model.name
    }
  end
end
