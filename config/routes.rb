Rails.application.routes.draw do
  get 'reindex', to: 'reindex#reindex'
  get ':model', to: 'releases#latest'
  get ':model/:release_id', to: 'releases#show'
end
