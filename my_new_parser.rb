require 'nokogiri'
require 'csv'
require 'open-uri'
require 'pry'
require 'curb'

ALL_INFORMATION = ARGV.first
END_CSV_FILE = ARGV.last

def parse_product(product_url)
  page = Nokogiri::HTML(Curl.get(product_url).body_str)
  image_src = page.xpath('//div/div/div/div/div/span/img/@src').text
  product_name = page.xpath('//h1').text
  page.css('.attribute_labels_lists').map do |line|
    [
      "#{product_name} -- #{line.css('.attribute_name').last.content.strip}",
      line.css('.attribute_price').last.content.strip,
      image_src
    ]
  end
end

first_page = Nokogiri::HTML(Curl.get(ALL_INFORMATION).body_str)
pages_count = first_page.xpath('//div[2]/div/div/div/div[1]/div[2]/span').text.match(/\d+/)[0].to_i / 20 + 1
product_urls = []

pages_count.times do |page_number|
  page = Nokogiri::HTML(Curl.get("#{ALL_INFORMATION}?p=#{page_number + 1}").body_str)
  product_urls += page.css('.product_img_link').map { |link| link['href'] }
end

product_lines = product_urls.inject([]) do |product_lines, product_url|
  product_lines + parse_product(product_url)
end

CSV.open("tmp/#{END_CSV_FILE}", 'wb') do |csv|
  csv << %w(Names Prices Images)
  product_lines.each do |line|
    csv << line
  end
end
