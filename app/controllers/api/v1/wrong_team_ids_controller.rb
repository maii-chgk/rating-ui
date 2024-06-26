# frozen_string_literal: true

module Api
  module V1
    class WrongTeamIdsController < ApiController
      def index
        render json: {items: WrongTeamId.all}, status: :ok
      end
    end
  end
end
