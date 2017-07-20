require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'pp'
require 'googlecharts'


class Player
  attr_accessor :name, :position, :years, :games, :fantasy_points, :fantasy_points_per_game
  def initialize(name, position)
    @name = name
    @position = position
  end
  
  def stats(year)
    x = @years.find_index do |y|
      y == year 
    end
    puts "in #{year} #{name} had: \n #{games[x]} games \n with #{fantasy_points_per_game[x]} points/game "
  end
end


page = Nokogiri::HTML(open("http://www.fftoday.com/stats/players/11889/Andy_Dalton"))   

rows = page.css("table[width='100%']")[6]

label = rows.css('td').text

x = label.split("\n")
  
x = x[24..-23].map do |r|
  r.strip
end

years = []
x.each_with_index do |y,i|
  if i % 17 == 0
    years.push(y.to_i)
  end
end

games = []
x.each_with_index do |y,i|
  if (i+15) % 17 == 0
    games.push(y.to_i)
  end
end

fantasy_points = []
x.each_with_index do |y,i|
  if (i+4) % 17 == 0
    fantasy_points.push(y.to_f)
  end
end

fantasy_points_per_game = []
x.each_with_index do |y,i|
  if (i+3) % 17 == 0
    fantasy_points_per_game.push(y.to_f)
  end
end

andy_dalton = Player.new("Andy Dalton", :QB)

andy_dalton.years = years
andy_dalton.games = games
andy_dalton.fantasy_points = fantasy_points
andy_dalton.fantasy_points_per_game = fantasy_points_per_game

pp andy_dalton

axis = andy_dalton.years.join('|')
xx = [axis]

pp xx


bar_chart = Gchart.new(
            :type => 'bar',
            :size => '400x400',
            :bar_colors => "000000",
            :title => andy_dalton.name,
            :bg => 'EFEFEF',
            :data => andy_dalton.fantasy_points_per_game,
            :filename => './bar_chart.png'
            )

bar_chart.file