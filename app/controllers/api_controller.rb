class ApiController < ActionController::Base
  PER_PAGE = 500

  def page
    (params[:page] || 1).to_i
  end

  def offset
    (page - 1) * PER_PAGE
  end

  def render_json(metadata:, items:)
    render json: metadata.merge({ items: items }), status: 200
  end
end
