require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'pp'
require 'googlecharts'

#this creates csv files with player ids and player names for each position group



positions = ['QB', 'RB', 'WR', 'TE']

def player_ids(position)
  page = Nokogiri::HTML(open("http://www.fftoday.com/stats/players/?Pos=#{position}")) 
  x = page.css('span[class="bodycontent"] a')
  a = x.map do |u|
    u.to_s
  end
  ids = a.map do |r|
    r.scan(/\d+/)
  end
  names = a.map do |r|
    r.scan(/(?<=\d\/)(.*)(?=")/)
  end
  ids = ids.map do |r|
    r[0].to_i
  end
  names = names.map do |r|
    r[0][0]
  end
  con = ids.each_with_index.map do |t,i|
    "#{t} | #{names[i]} \n"
    end
  File.open("player_ids/player_ids_#{position}.csv", "w+") do |f|
    f.puts(con)
  end
end

positions.each do |x|
  player_ids(x)
end
