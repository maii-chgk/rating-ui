class Api::V1::ReleasesController < ApplicationController
  include InModel

  def index
    releases = current_model.all_releases
    render json: metadata.merge({ items: releases }), status: 200
  end

  def metadata
    {
      model: current_model.name
    }
  end
end
