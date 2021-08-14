require 'sinatra'
require "sinatra/reloader" if development?

get '/' do
  'Рейтинги МАИИ'
end

get "/:model/" do |model|
  "Showing teams for #{model}"
end
