# frozen_string_literal: true

require_relative '../lib/truedl_calculator'

class TrueDlsController < ApplicationController
  def recalculate
    TrueDLCalculator.calculate_for_all_maii_tournaments(model_name: params_model)
    redirect_to :root
  end

  def params_model
    params.require(:model)
  end
end
