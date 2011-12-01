#!/usr/bin/env ruby
require 'net/http'
require 'json'

def post(search)
  image = Array.new
  uri = URI('http://ajax.googleapis.com/ajax/services/search/images')
  params = {:v => '1.0', :rsz => '8', :q => search }
  uri.query = URI.encode_www_form(params)
  res = Net::HTTP.get_response(uri)
  data = res.body
  result = JSON.parse(data)
  first = result['responseData']['results']
  first.each do |second|
    second.each do |key, value| 
      if key == "unescapedUrl"
        image.push "#{value}"
      end
    end
  end
  image.sample
end
