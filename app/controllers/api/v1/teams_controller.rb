# frozen_string_literal: true

module Api
  module V1
    class TeamsController < ApiController
      include InModel

      def release
        return render_error_json(error: MISSING_MODEL_ERROR) if current_model.nil?

        teams = current_model.teams_for_release_api(release_id:, limit: page_size, offset:)
        Places.add_top_and_bottom_places!(teams)
        Places.add_previous_top_and_bottom_places!(teams)

        tournaments = current_model.tournaments_in_release_by_team(release_id:)
        teams.each do |team|
          team['tournaments'] = tournaments.fetch(team['team_id'], [])
        end

        metadata = {
          model: current_model.name,
          release_id:
        }

        render_paged_json(metadata:, items: teams, all_items_count: teams_in_release_count)
      end

      def show
        return render_error_json(error: MISSING_MODEL_ERROR) if current_model.nil?

        releases = current_model.team_releases(team_id:).map(&:to_h)
        tournaments = current_model.team_tournaments(team_id:)

        tournaments_hash = tournaments.each_with_object({}) do |tournament, hash|
          next unless tournament.in_rating

          (hash[tournament['release_id']] ||= []) << tournament.to_h.except(:release_id)
        end

        releases.each do |release|
          release['tournaments'] = tournaments_hash[release[:id]]
        end

        metadata = {
          model: current_model.name,
          team_id:
        }

        render_json(metadata:, items: releases)
      end

      private

      def teams_in_release_count
        current_model.count_all_teams_in_release(release_id:)
      end

      def release_id
        @release_id ||= if params[:release_id] == 'latest'
                          current_model.latest_release_id
                        else
                          params[:release_id]
                        end
      end

      def team_id
        @team_id ||= params[:team_id].to_i
      end
    end
  end
end
