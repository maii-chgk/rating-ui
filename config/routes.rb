Rails.application.routes.draw do
  get "reindex", to: "reindex#reindex"
  get "ping", to: "healthcheck#ping"
  get "reset_cache", to: "cache#reset"
  get ":model", to: "releases#latest", as: "latest"
  get ":model/:release_id", to: "releases#show", as: "release"
  get ":model/team/:team_id", to: "teams#show", as: "team"
end
