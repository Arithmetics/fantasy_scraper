require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'pp'
require 'googlecharts'
require 'csv'
require 'gruff'

class QBSeason
  attr_accessor :games, :passing_completions, :passing_attempts, :completion_percentage, :passing_yards, :passing_touchdowns, :interceptions, :passing_attempts, :rushing_attempts, :rushing_yards, :rushing_touchdowns
  def initialize(games, passing_completions, passing_attempts, completion_percentage, passing_yards, passing_touchdowns, interceptions, rushing_attempts, rushing_yards, rushing_touchdowns)
    @games = games
    @passing_completions = passing_completions
    @passing_attempts = passing_attempts
    @completion_percentage = completion_percentage
    @passing_yards = passing_yards
    @passing_touchdowns = passing_touchdowns
    @interceptions = interceptions
    @rushing_attempts = rushing_attempts
    @rushing_yards = rushing_yards
    @rushing_touchdowns = rushing_touchdowns
  end 
end

class RBSeason
  attr_accessor :games, :rushing_attempts, :rushing_yards, :rushing_average, :rushing_touchdowns, :targets, :receptions, :receiving_yards, :receiving_average, :receiving_touchdowns
  def initialize(games, rushing_attempts, rushing_yards, rushing_average, rushing_touchdowns, targets, receptions, receiving_yards, receiving_average, receiving_touchdowns)
    @games = games
    @rushing_attempts = rushing_attempts
    @rushing_yards = rushing_yards
    @rushing_average = rushing_average
    @rushing_touchdowns = rushing_touchdowns
    @targets = targets
    @receptions = receptions
    @receiving_yards = receiving_yards
    @receiving_average = receiving_average
    @receiving_touchdowns = receiving_touchdowns
  end
end 

class WRSeason
  attr_accessor :games, :targets, :receptions, :receiving_yards, :receiving_average, :receiving_touchdowns, :rushing_attempts, :rushing_yards, :rushing_average, :rushing_touchdowns
  def initialize(games, targets, receptions, receiving_yards, receiving_average, receiving_touchdowns, rushing_attempts, rushing_yards, rushing_average, rushing_touchdowns)
    @games = games
    @targets = targets
    @receptions = receptions
    @receiving_yards = receiving_yards
    @receiving_average = receiving_average
    @receiving_touchdowns = receiving_touchdowns
    @rushing_attempts = rushing_attempts
    @rushing_yards = rushing_yards
    @rushing_average = rushing_average
    @rushing_touchdowns = rushing_touchdowns
  end
end

class TESeason
  attr_accessor :games, :targets, :receptions, :receiving_yards, :receiving_average, :receiving_touchdowns
  def initialize(games, targets, receptions, receiving_yards, receiving_average, receiving_touchdowns)
    @games = games
    @targets = targets
    @receptions = receptions
    @receiving_yards = receiving_yards
    @receiving_average = receiving_average
    @receiving_touchdowns = receiving_touchdowns
  end
end 

#class to create QB objects. each instance variable is an array of that stat by year. Coeresponding years are in the @year variable.
class Quarterback
  attr_accessor :name, :years, :games, :passing_completions, :passing_attempts, :completion_percentage, :passing_yards, :passing_touchdowns, :interceptions, :passing_attempts, :rushing_attempts, :rushing_yards, :rushing_touchdowns
  def initialize(name, years, games, passing_completions, passing_attempts, completion_percentage, passing_yards, passing_touchdowns, interceptions, rushing_attempts, rushing_yards, rushing_touchdowns)
    @name = name
    @years = years
    @games = games
    @passing_completions = passing_completions
    @passing_attempts = passing_attempts
    @completion_percentage = completion_percentage
    @passing_yards = passing_yards
    @passing_touchdowns = passing_touchdowns
    @interceptions = interceptions
    @rushing_attempts = rushing_attempts
    @rushing_yards = rushing_yards
    @rushing_touchdowns = rushing_touchdowns
  end 
end

#class to create RB objects. each instance variable is an array of that stat by year. Coeresponding years are in the @year variable.
class Runningback
  attr_accessor :name, :years, :games, :rushing_attempts, :rushing_yards, :rushing_average, :rushing_touchdowns, :targets, :receptions, :receiving_yards, :receiving_average, :receiving_touchdowns
  def initialize(name, years, games, rushing_attempts, rushing_yards, rushing_average, rushing_touchdowns, targets, receptions, receiving_yards, receiving_average, receiving_touchdowns)
    @name = name
    @years = years
    @games = games
    @rushing_attempts = rushing_attempts
    @rushing_yards = rushing_yards
    @rushing_average = rushing_average
    @rushing_touchdowns = rushing_touchdowns
    @targets = targets
    @receptions = receptions
    @receiving_yards = receiving_yards
    @receiving_average = receiving_average
    @receiving_touchdowns = receiving_touchdowns
  end
end

#class to create WR objects. each instance variable is an array of that stat by year. Coeresponding years are in the @year variable.
class Widereceiver
  attr_accessor :name, :years, :games, :targets, :receptions, :receiving_yards, :receiving_average, :receiving_touchdowns, :rushing_attempts, :rushing_yards, :rushing_average, :rushing_touchdowns
  def initialize(name, years, games, targets, receptions, receiving_yards, receiving_average, receiving_touchdowns, rushing_attempts, rushing_yards, rushing_average, rushing_touchdowns)
    @name = name
    @years = years
    @games = games
    @targets = targets
    @receptions = receptions
    @receiving_yards = receiving_yards
    @receiving_average = receiving_average
    @receiving_touchdowns = receiving_touchdowns
    @rushing_attempts = rushing_attempts
    @rushing_yards = rushing_yards
    @rushing_average = rushing_average
    @rushing_touchdowns = rushing_touchdowns
  end
end



#finds the first player with that name in one of the positional arrays containing each player object
def find_player(name, target_arr)
  found = target_arr.find do |x| 
   x.name == name
  end
  match_index = target_arr.index(found)
  match_index
end

#queries the player_ids csv file, which has the player names and their id, to generate an array of link to the player page for each player in the document that coeresponds to that position
def generate_link(position)
  links = CSV.foreach("player_ids/player_ids_#{position}.csv").map do |row|
            "http://www.fftoday.com/stats/players/" + row[0].scan(/\d+/).join("") + "/" + row[0].scan(/[a-zA-Z,_]/).join("")
          end
  return links
end 

def gather_player_info(link, target_arr)
  page = Nokogiri::HTML(open(link))
  rows = page.xpath("//table[@width='100%']//td[@class='bodycontent']").text
  date_of_birth = rows[/(?<=DOB: )(.+)(?= Age)/]
  college = rows[/(?<=College: )(.+)(?=DOB)/]
  draft = rows[/(?<=Draft: )(.+)(?=College:)/]
end

def gather_qb_stats(link, target_arr)
  page = Nokogiri::HTML(open(link))
  rows = page.xpath("//table[@width='100%' and .//td/b[contains(., 'FPts/G')]]//td").text
  if rows != nil
    x = rows.split("\n")
    if x.length != 0
      x = x[24..-4].map do |r|
        r.strip
      end
      
      end_val = x.index do |cell|
                  cell.include? ("Projected")
      end
                
                
      if end_val.class == Fixnum
        puts end_val
        x = x[0...(end_val-1)]
        
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
    
      passing_completions = []
      x.each_with_index do |y,i|
        if (i+14) % 17 == 0
          passing_completions.push(y.to_i)
        end
      end
    
      passing_attempts = []
      x.each_with_index do |y,i|
        if (i+13) % 17 == 0
          passing_attempts.push(y.to_i)
        end
      end
    
      completion_percentage = []
      x.each_with_index do |y,i|
        if (i+12) % 17 == 0
          completion_percentage.push(y.to_f)
        end
      end
    
      passing_yards = []
      x.each_with_index do |y,i|
        if (i+11) % 17 == 0
          passing_yards.push(y.gsub(",","").to_f)
        end
      end
    
      passing_touchdowns = []
      x.each_with_index do |y,i|
        if (i+10) % 17 == 0
          passing_touchdowns.push(y.to_i)
        end
      end
    
      interceptions = []
      x.each_with_index do |y,i|
        if (i+9) % 17 == 0
          interceptions.push(y.to_i)
        end
      end
    
      rushing_attempts = []
      x.each_with_index do |y,i|
        if (i+8) % 17 == 0
          rushing_attempts.push(y.to_i)
        end
      end
    
      rushing_yards = []
      x.each_with_index do |y,i|
        if (i+7) % 17 == 0
          rushing_yards.push(y.gsub(",","").to_f)
        end
      end
    
      rushing_average = []
      x.each_with_index do |y,i|
        if (i+6) % 17 == 0
          rushing_average.push(y.to_f)
        end
      end
    
      rushing_touchdowns = []
      x.each_with_index do |y,i|
        if (i+5) % 17 == 0
          rushing_touchdowns.push(y.to_i)
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
    
      name = link.scan(/(?<=\d\/)(.*)(?=)/).join("")
    
    
      x = Quarterback.new(name, years, games, passing_completions, passing_attempts, completion_percentage, passing_yards, passing_touchdowns, interceptions, rushing_attempts, rushing_yards, rushing_touchdowns)
    
      target_arr << x
    
    end
  end
end 

def gather_rb_stats(link, target_arr)
  page = Nokogiri::HTML(open(link))
  rows = page.xpath("//table[@width='100%' and .//td/b[contains(., 'FPts/G')]]//td").text
  if rows != nil
    x = rows.split("\n")
    if x.length != 0
      x = x[23..-4].map do |r|
        r.strip
      end
      
      end_val = x.index do |cell|
                  cell.include? ("Projected")
      end
                
                
      if end_val.class == Fixnum
        puts end_val
        x = x[0...(end_val-1)]
        
      end
    
      years = []
      x.each_with_index do |y,i|
        if i % 16 == 0
          years.push(y.to_i)
        end
      end
      
      games = []
      x.each_with_index do |y,i|
        if (i+14) % 16 == 0
          games.push(y.to_i)
        end
      end
    
      rushing_attempts = []
      x.each_with_index do |y,i|
        if (i+13) % 16 == 0
          rushing_attempts.push(y.to_i)
        end
      end
    
      rushing_yards = []
      x.each_with_index do |y,i|
        if (i+12) % 16 == 0
          rushing_yards.push(y.gsub(",","").to_f)
        end
      end
    
      rushing_average = []
      x.each_with_index do |y,i|
        if (i+11) % 16 == 0
          rushing_average.push(y.to_f)
        end
      end
    
      rushing_touchdowns = []
      x.each_with_index do |y,i|
        if (i+10) % 16 == 0
          rushing_touchdowns.push(y.to_i)
        end
      end
    
      targets = []
      x.each_with_index do |y,i|
        if (i+9) % 16 == 0
          targets.push(y.to_i)
        end
      end
    
      receptions = []
      x.each_with_index do |y,i|
        if (i+8) % 16 == 0
          receptions.push(y.to_i)
        end
      end
    
      receiving_yards = []
      x.each_with_index do |y,i|
        if (i+7) % 16 == 0
          receiving_yards.push(y.gsub(",","").to_f)
        end
      end
      
      receiving_average = []
      x.each_with_index do |y,i|
        if (i+6) % 16 == 0
          receiving_average.push(y.to_f)
        end
      end
      
      receiving_touchdowns = []
      x.each_with_index do |y,i|
        if (i+5) % 16 == 0
          receiving_touchdowns.push(y.to_i)
        end
      end
    
      name = link.scan(/(?<=\d\/)(.*)(?=)/).join("")
    
    
      x = Runningback.new(name, years, games, rushing_attempts, rushing_yards, rushing_average, rushing_touchdowns, targets, receptions, receiving_yards, receiving_average, receiving_touchdowns)
    
      target_arr << x
    
    end
  end
end 

def gather_wr_stats(link, target_arr)
  page = Nokogiri::HTML(open(link))
  rows = page.xpath("//table[@width='100%' and .//td/b[contains(., 'FPts/G')]]//td").text
  if rows != nil
    x = rows.split("\n")
    if x.length != 0
      x = x[23..-4].map do |r|
        r.strip
      end
      
      end_val = x.index do |cell|
                  cell.include? ("Projected")
      end
                
                
      if end_val.class == Fixnum
        puts end_val
        x = x[0...(end_val-1)]
        
      end
    
      years = []
      x.each_with_index do |y,i|
        if i % 16 == 0
          years.push(y.to_i)
        end
      end
      
      games = []
      x.each_with_index do |y,i|
        if (i+14) % 16 == 0
          games.push(y.to_i)
        end
      end
    
      targets = []
      x.each_with_index do |y,i|
        if (i+13) % 16 == 0
          targets.push(y.to_i)
        end
      end
    
      receptions = []
      x.each_with_index do |y,i|
        if (i+12) % 16 == 0
          receptions.push(y.to_i)
        end
      end
    
      receiving_yards = []
      x.each_with_index do |y,i|
        if (i+11) % 16 == 0
          receiving_yards.push(y.gsub(",","").to_f)
        end
      end
    
      receiving_average = []
      x.each_with_index do |y,i|
        if (i+10) % 16 == 0
          receiving_average.push(y.to_f)
        end
      end
    
      receiving_touchdowns = []
      x.each_with_index do |y,i|
        if (i+9) % 16 == 0
          receiving_touchdowns.push(y.to_i)
        end
      end
    
      rushing_attempts = []
      x.each_with_index do |y,i|
        if (i+8) % 16 == 0
          rushing_attempts.push(y.to_i)
        end
      end
    
      rushing_yards = []
      x.each_with_index do |y,i|
        if (i+7) % 16 == 0
          rushing_yards.push(y.gsub(",","").to_f)
        end
      end
      
      rushing_average = []
      x.each_with_index do |y,i|
        if (i+6) % 16 == 0
          rushing_average.push(y.to_f)
        end
      end
      
      rushing_touchdowns = []
      x.each_with_index do |y,i|
        if (i+5) % 16 == 0
          rushing_touchdowns.push(y.to_i)
        end 
      end
    
      name = link.scan(/(?<=\d\/)(.*)(?=)/).join("")
    
    
      x = Widereceiver.new(name, years, games, targets, receptions, receiving_yards, receiving_average, receiving_touchdowns, rushing_attempts, rushing_yards, rushing_average, rushing_touchdowns)
    
      target_arr << x
    
    end
  end
end 





def find_max_completion_percentage(qb_obj_array, min_games=0, min_percentage=0, max_percentage=100)
  qb_obj_array.each do |qb|
    if qb.completion_percentage.max != nil
      if qb.completion_percentage.max > min_percentage && qb.completion_percentage.max < max_percentage
        index = qb.completion_percentage.each_with_index.max[1]
        if qb.games[index] > min_games
          puts "#{qb.name}'s career best was #{qb.completion_percentage.max} in #{qb.years[index]}. He played #{qb.games[index]} games that year"
        end
      end
    end 
  end
end


qbs = []
rbs = []
wrs = []


def create_qbs
  generate_link("QB").each do |link|
    gather_qb_stats(link, qbs)
  end
end

def create_rbs
  generate_link("RB").each do |link|
    gather_rb_stats(link, rbs)
  end
end

def create_wrs
  generate_link("WR").each do |link|
    gather_wr_stats(link, wrs)
  end
end



gather_wr_stats("http://www.fftoday.com/stats/players/12692/Josh_Gordon", wrs)
gather_wr_stats("http://www.fftoday.com/stats/players/13144/Cobi_Hamilton", wrs)

p wrs[0].name
p wrs[0].games
p wrs[0].years
p wrs[0].targets
p wrs[0].receptions
p wrs[0].receiving_yards
p wrs[0].receiving_average
p wrs[0].receiving_touchdowns
p wrs[0].rushing_attempts
p wrs[0].rushing_yards
p wrs[0].rushing_average
p wrs[0].rushing_touchdowns

p wrs[1].name
p wrs[1].games
p wrs[1].years
p wrs[1].targets
p wrs[1].receptions
p wrs[1].receiving_yards
p wrs[1].receiving_average
p wrs[1].receiving_touchdowns
p wrs[1].rushing_attempts
p wrs[1].rushing_yards
p wrs[1].rushing_average
p wrs[1].rushing_touchdowns






