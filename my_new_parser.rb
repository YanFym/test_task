require 'nokogiri'
require 'csv'
require 'open-uri'
require 'pry'

URL_TO_PARSE = ARGV.first

#binding pry
first_page = Nokogiri::HTML(open(URL_TO_PARSE))
pages_count = first_page.css('.heading-counter').last.content.match(/\d+/)[0].to_i / 20 + 1
product_urls = []

binding pry

