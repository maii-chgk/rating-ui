Rails.application.routes.draw do
  get "reindex", to: "reindex#reindex"
  get "ping", to: "healthcheck#ping"
  get "reset_cache", to: "cache#reset"
  get ":model/tournaments/", to: "tournaments#index", as: "tournaments"
  get ":model/tournament/:tournament_id", to: "tournaments#show", as: "tournament"
  get ":model/team/:team_id", to: "teams#show", as: "team"
  get ":model/player/:player_id", to: "players#show", as: "player"
  get ":model/players(/:release_id)", to: "player_releases#show", as: "player_release"
  get ":model(/:release_id)", to: "releases#show", as: "release"

  namespace :api do
    namespace :v1 do
      get ":model/teams/:release_id", to: "teams#show"
      get ":model/players/:release_id", to: "players#show"
      get ":model/tournaments/:tournament_id", to: "tournaments#show"
      get ":model/releases", to: "releases#index"
    end
  end

  root to: "releases#show", model: InModel::DEFAULT_MODEL
end
