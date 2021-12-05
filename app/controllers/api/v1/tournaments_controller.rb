class Api::V1::TournamentsController < ApiController
  include InModel

  def show
    return render_error_json(error: MISSING_MODEL_ERROR) if current_model.nil?

    @tournament_id = params[:tournament_id].to_i
    results = current_model.tournament_ratings(tournament_id: @tournament_id)
    render_json(metadata: metadata, items: results)
  end

  def metadata
    {
      model: current_model.name,
      tournament_id: @tournament_id,
    }
  end
end
