require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'pp'
require 'csv'
require 'date'


#season classes. contain statistics for that season
class QBSeason
  attr_accessor :age, :games, :passing_completions, :passing_attempts, :completion_percentage, :passing_yards, :passing_touchdowns, :interceptions, :passing_attempts, :rushing_attempts, :rushing_yards, :rushing_average, :rushing_touchdowns
  def initialize(age, games, passing_completions, passing_attempts, completion_percentage, passing_yards, passing_touchdowns, interceptions, rushing_attempts, rushing_yards, rushing_average, rushing_touchdowns)
    @age = age
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
  
  def fantasy_points
    @passing_yards/25 + @passing_touchdowns*4 + @interceptions*-2 + @rushing_yards / 10 + @rushing_touchdowns*6 
  end
  
  def fantasy_points_ppr(ppr)
    @passing_yards/25 + @passing_touchdowns*4 + @interceptions*-2 + @rushing_yards / 10 + @rushing_touchdowns*6 
  end
end

class RBSeason
  attr_accessor :age, :games, :rushing_attempts, :rushing_yards, :rushing_average, :rushing_touchdowns, :targets, :receptions, :receiving_yards, :receiving_average, :receiving_touchdowns
  def initialize(age, games, rushing_attempts, rushing_yards, rushing_average, rushing_touchdowns, targets, receptions, receiving_yards, receiving_average, receiving_touchdowns)
    @age = age
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
  
  def fantasy_points
    @rushing_yards / 10 + @rushing_touchdowns*6 + @receiving_yards / 10 + @receiving_touchdowns * 6 
  end
  
  def fantasy_points_ppr(ppr)
    @passing_yards/25 + @passing_touchdowns*4 + @interceptions*-2 + @rushing_yards / 10 + @rushing_touchdowns*6 + @receptions * ppr
  end
end 

class WRSeason
  attr_accessor :age, :games, :targets, :receptions, :receiving_yards, :receiving_average, :receiving_touchdowns, :rushing_attempts, :rushing_yards, :rushing_average, :rushing_touchdowns
  def initialize(age, games, targets, receptions, receiving_yards, receiving_average, receiving_touchdowns, rushing_attempts, rushing_yards, rushing_average, rushing_touchdowns)
    @age = age
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
  
  def fantasy_points
    @rushing_yards / 10 + @rushing_touchdowns*6 + @receiving_yards / 10 + @receiving_touchdowns * 6 
  end
  
  def fantasy_points_ppr(ppr)
    @passing_yards/25 + @passing_touchdowns*4 + @interceptions*-2 + @rushing_yards / 10 + @rushing_touchdowns*6 + @receptions * ppr
  end
end

class TESeason
  attr_accessor :age, :games, :targets, :receptions, :receiving_yards, :receiving_average, :receiving_touchdowns
  def initialize(age, games, targets, receptions, receiving_yards, receiving_average, receiving_touchdowns)
    @age = age
    @games = games
    @targets = targets
    @receptions = receptions
    @receiving_yards = receiving_yards
    @receiving_average = receiving_average
    @receiving_touchdowns = receiving_touchdowns
  end
  
  def fantasy_points
    @receiving_yards / 10 + @receiving_touchdowns * 6 
  end
  
  def fantasy_points_ppr(ppr)
    @passing_yards/25 + @passing_touchdowns*4 + @interceptions*-2 + @rushing_yards / 10 + @rushing_touchdowns*6 + @receptions * ppr
  end
end 

#class to create Player objects
class Player
  attr_accessor :name, :date_of_birth, :college, :draft_pick, :seasons
  def initialize(name, date_of_birth, college, draft_pick)
    @name = name
    @date_of_birth = date_of_birth
    @college = college
    @draft_pick = draft_pick
    @seasons = {}
  end 
end

#calculate age at begining of season
def calc_age(dob, season_year)
  if dob != nil
    date1 = Date.strptime(dob, '%Y-%m-%d')
    date2 = Date.strptime("#{season_year}-09-07", '%Y-%m-%d')
    days = date2 - date1
    years = days/365.0
  else
    years = 0
  end
end


#queries the player_ids csv file, which has the player names and their id, to generate an array of link to the player page for each player in the document that coeresponds to that position
def generate_link(position)
  links = CSV.foreach("player_ids/player_ids_#{position}.csv").map do |row|
            "http://www.fftoday.com/stats/players/" + row[0].scan(/\d+/).join("") + "/" + row[0].scan(/[a-zA-Z,_]/).join("")
          end
  return links
end 

#creates a player object with seasons from a link and puts it in the target array
def gather_qb_stats(link, target_arr)
  page = Nokogiri::HTML(open(link))
  
  #gather info for the Player class
  rows = page.xpath("//table[@width='100%']//td[@class='bodycontent']").text
  rows = rows.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').gsub(/\\x\d+/, "")  
  name = link.scan(/(?<=\d\/)(.*)(?=)/).join("")
  date_of_birth = rows[/(?<=DOB: )(.+)(?= Age)/]
  college = rows[/(?<=College: )(.+)(?=DOB)/]
  draft_pick = rows[/(?<=Draft: )(.+)(?=College:)/]
  
  player = Player.new(name, date_of_birth, college, draft_pick)
  
  
  #now gather info for the QBSeason class. This only make a series of arrays
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
    
      #this next part populates the .seasons hash with keys from the years array and another hash with each stat
      
      years.each_with_index do |y, i|
        player.seasons[y] = QBSeason.new(calc_age(player.date_of_birth, y), games[i], passing_completions[i], passing_attempts[i], completion_percentage[i], passing_yards[i], passing_touchdowns[i], interceptions[i], rushing_attempts[i], rushing_yards[i], rushing_average[i], rushing_touchdowns[i])
      end

      target_arr << player
    
    end
  end
end 

#creates a player object with seasons from a link and puts it in the target array
def gather_rb_stats(link, target_arr)
  page = Nokogiri::HTML(open(link))
  
  #gather info for the Player class
  rows = page.xpath("//table[@width='100%']//td[@class='bodycontent']").text
  rows = rows.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').gsub(/\\x\d+/, "")  
  name = link.scan(/(?<=\d\/)(.*)(?=)/).join("")
  date_of_birth = rows[/(?<=DOB: )(.+)(?= Age)/]
  college = rows[/(?<=College: )(.+)(?=DOB)/]
  draft_pick = rows[/(?<=Draft: )(.+)(?=College:)/]
  
  player = Player.new(name, date_of_birth, college, draft_pick)
  
  
  #now gather info for the RBSeason class. This only make a series of arrays
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
    
      #this next part populates the .seasons hash with keys from the years array and another hash with each stat
      
      years.each_with_index do |y, i|
        player.seasons[y] = RBSeason.new(calc_age(player.date_of_birth, y), games[i], rushing_attempts[i], rushing_yards[i], rushing_average[i], rushing_touchdowns[i], targets[i], receptions[i], receiving_yards[i], receiving_average[i], receiving_touchdowns[i])
      end
    
      target_arr << player
    
    end
  end
end 

#creates a player object with seasons from a link and puts it in the target array
def gather_wr_stats(link, target_arr)
  page = Nokogiri::HTML(open(link))
  
  #gather info for the Player class
  rows = page.xpath("//table[@width='100%']//td[@class='bodycontent']").text
  rows = rows.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').gsub(/\\x\d+/, "")  
  name = link.scan(/(?<=\d\/)(.*)(?=)/).join("")
  date_of_birth = rows[/(?<=DOB: )(.+)(?= Age)/]
  college = rows[/(?<=College: )(.+)(?=DOB)/]
  draft_pick = rows[/(?<=Draft: )(.+)(?=College:)/]
  
  player = Player.new(name, date_of_birth, college, draft_pick)
  
  
  #now gather info for the WRSeason class. This only make a series of arrays
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
    
      #this next part populates the .seasons hash with keys from the years array and another hash with each stat
      
      years.each_with_index do |y, i|
        player.seasons[y] = WRSeason.new(calc_age(player.date_of_birth, y), games[i], targets[i], receptions[i], receiving_yards[i], receiving_average[i], receiving_touchdowns[i], rushing_attempts[i], rushing_yards[i], rushing_average[i], rushing_touchdowns[i])
      end

      target_arr << player
    
    end
  end
end 

#creates a player object with seasons from a link and puts it in the target array
def gather_te_stats(link, target_arr)
  page = Nokogiri::HTML(open(link))
  
  #gather info for the Player class
  rows = page.xpath("//table[@width='100%']//td[@class='bodycontent']").text
  rows = rows.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').gsub(/\\x\d+/, "")  
  name = link.scan(/(?<=\d\/)(.*)(?=)/).join("")
  date_of_birth = rows[/(?<=DOB: )(.+)(?= Age)/]
  college = rows[/(?<=College: )(.+)(?=DOB)/]
  draft_pick = rows[/(?<=Draft: )(.+)(?=College:)/]
  
  player = Player.new(name, date_of_birth, college, draft_pick)
  
  
  #now gather info for the TESeason class. This only make a series of arrays
  rows = page.xpath("//table[@width='100%' and .//td/b[contains(., 'FPts/G')]]//td").text
  if rows != nil
    x = rows.split("\n")
    if x.length != 0
      x = x[20..-4].map do |r|
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
        if i % 12 == 0
          years.push(y.to_i)
        end
      end
      
      games = []
      x.each_with_index do |y,i|
        if (i-2) % 12 == 0
          games.push(y.to_i)
        end
      end
    
      targets = []
      x.each_with_index do |y,i|
        if (i-3) % 12 == 0
          targets.push(y.to_i)
        end
      end
    
      receptions = []
      x.each_with_index do |y,i|
        if (i-4) % 12 == 0
          receptions.push(y.to_i)
        end
      end
    
      receiving_yards = []
      x.each_with_index do |y,i|
        if (i-5) % 12 == 0
          receiving_yards.push(y.gsub(",","").to_f)
        end
      end
    
      receiving_average = []
      x.each_with_index do |y,i|
        if (i-6) % 12 == 0
          receiving_average.push(y.to_f)
        end
      end
    
      receiving_touchdowns = []
      x.each_with_index do |y,i|
        if (i-7) % 12 == 0
          receiving_touchdowns.push(y.to_i)
        end
      end
    
      
    
      #this next part populates the .seasons hash with keys from the years array and another hash with each stat
      
      years.each_with_index do |y, i|
        player.seasons[y] = TESeason.new(calc_age(player.date_of_birth, y), games[i], targets[i], receptions[i], receiving_yards[i], receiving_average[i], receiving_touchdowns[i])
      end

      target_arr << player
      
    end
  end
end 

qbs = []
rbs = []
wrs = []
tes = []

def create_qbs(arr)
  generate_link("QB").each do |link|
    gather_qb_stats(link, arr)
  end
end

def create_rbs(arr)
  generate_link("RB").each do |link|
    gather_rb_stats(link, arr)
  end
end

def create_wrs(arr)
  generate_link("WR").each do |link|
    gather_wr_stats(link, arr)
  end
end

def create_tes(arr)
  generate_link("TE").each do |link|
    gather_te_stats(link, arr)
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

def display_player_ptds(player, year)
  unless player.seasons[year].class == NilClass
    player.seasons[year].passing_touchdowns
  end 
end

#finds the first player with that name in one of the positional arrays containing each player object
def find_player(name, target_arr)
  target_arr.find do |x| 
   x.name == name
  end
end



