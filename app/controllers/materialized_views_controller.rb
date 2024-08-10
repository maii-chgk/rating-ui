# frozen_string_literal: true

class MaterializedViewsController < ApplicationController
  def recreate_views
    MaterializedViews.recreate_all(model: params_model)
    redirect_to :root
  end

  def params_model
    Model.find_sole_by(name: params.require(:model))&.name
  end
end
