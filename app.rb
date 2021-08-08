require 'sinatra'
require "sinatra/reloader" if development?

get '/' do
  'Hello world!'
end

get "/:model/teams" do |model|
  "Showing teams for #{model}"
end
