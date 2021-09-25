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
end
