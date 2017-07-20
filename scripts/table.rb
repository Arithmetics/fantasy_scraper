require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'pp'
require 'googlecharts'
require 'csv'
require 'gruff'

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
          receptions.push(y.to_f)
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
          receiving_touchdowns.push(y.to_f)
        end
      end
    
      name = link.scan(/(?<=\d\/)(.*)(?=)/).join("")
    
    
      x = Runningback.new(name, years, games, rushing_attempts, rushing_yards, rushing_average, rushing_touchdowns, targets, receptions, receiving_yards, receiving_average, receiving_touchdowns)
    
      target_arr << x
    
    end
  end
end 


