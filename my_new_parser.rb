require 'nokogiri'
require 'csv'
require 'open-uri'
require 'pry'

URL_TO_PARSE = ARGV.first
FILE_TO_SAVE= ARGV.last

def parse_product(product_url)
  page = Nokogiri::HTML(open(product_url))
  image_src = page.css('#bigpic').last['src']
  product_name = page.css('h1').last.content.strip
  page.css('.attribute_labels_lists').map do |line|
    [
      "#{product_name} -- #{line.css('.attribute_name').last.content.strip}",
      line.css('.attribute_price').last.content.strip,
      image_src
    ]
  end
end

#binding pry
first_page = Nokogiri::HTML(open(URL_TO_PARSE))
pages_count = first_page.css('.heading-counter').last.content.match(/\d+/)[0].to_i / 20 + 1
product_urls = []

pages_count.times do |page_number|
  page_with_product = Nokogiri::HTML(open("#{URL_TO_PARSE}?p=#{page_number + 1}"))
  product_urls += page_with_product.css('.product_img_link').map { |link| link['href'] }
end

product_lines = product_urls.inject([]) do |product_lines, product_url|
  product_lines + parse_product(product_url)
end

binding pry
