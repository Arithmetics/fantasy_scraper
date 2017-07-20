require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'pp'
require 'googlecharts'
require 'csv'

link1 = "http://www.fftoday.com/stats/players/14131/Teddy_Bridgewater"
doc = Nokogiri::HTML(open(link1))

 stats = doc.xpath("//table[@width='100%' and .//td/b[contains(., 'FPts/G')]]//td").text
 
 another = doc.xpath("//table[@width='100%']//td").text

puts stats