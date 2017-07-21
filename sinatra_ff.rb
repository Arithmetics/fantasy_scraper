require 'sinatra'
require 'sinatra/reloader'
require './scripts/player_stats.rb'

tes = []
create_tes(tes)

get '/' do
   player_name = "Rob Gronk"
   erb :index, :locals => {:player_name => player_name}

end