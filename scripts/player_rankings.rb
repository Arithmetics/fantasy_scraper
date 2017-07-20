require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'pp'
require 'csv'
require 'fileutils'

#this creates csv files with player rankings and player names for each position group
#using ESPN preseason rankings

positions = ["QB", "RB", "WR", "TE"]
years = *(2010..2016)

def file_list(position,year)
  Dir["./ESPN_Rankings_HTML/#{position}/#{year}*.html"]
end


def create_ranking(position, link)

  page = Nokogiri::HTML(open(link))

  rows = page.xpath("//table[@class='playerTableTable tableBody']//td[@class = 'playertableData' or @class = 'playertablePlayerName' ]").text
  players = rows.split(position)
  players.map! do |x|
    x[/\d+/] + " | " + x[/(?<=\d)(\D*)(?=,)/].gsub(" ", "_")
  end
end

def create_file(position, year)
  file_list(position, year).each do |link|
    File.open("ESPN_PreSeason_Rankings/#{position}/#{year}_#{position}_rankings.csv", "a") do |csv|
      csv.puts(create_ranking(position, link))
    end
  end
end



positions.each do |position|
  years.each do |year|
    create_file(position,year)
  end
end
