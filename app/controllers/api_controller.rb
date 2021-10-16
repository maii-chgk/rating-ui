class ApiController < ActionController::Base
  PER_PAGE = 500

  def page
    (params[:page] || 1).to_i
  end

  def offset
    (page - 1) * PER_PAGE
  end

  def page_metadata(all_items_count)
    {
      current_page: page,
      pages: (all_items_count.to_f / PER_PAGE).ceil,
      all_items_count: all_items_count
    }
  end

  def render_paged_json(metadata:, items:, all_items_count:)
    render json: metadata.merge(page_metadata(all_items_count)).merge({ items: items }), status: 200
  end

  def render_json(metadata:, items:)
    render json: metadata.merge({ items: items }), status: 200
  end
end
