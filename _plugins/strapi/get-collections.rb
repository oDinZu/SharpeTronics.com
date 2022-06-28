# Copyright SharpeTronics, LLC. 2013-2022
# Author: Charles Sharpe
# License: None

require 'httparty'
require 'json'
require 'down'

class Post
  include HTTParty

  def initialize
    # base url for remote server
    @api_url = "https://dash.sharpetronics.com/api"
  end

  def all
    # create directory & file if doesn't exist
    if not Dir.exist?('_data/posts/')
      puts "_data/posts/ directory does not exist, I am going to create one".yellow
      Dir.mkdir '_data/posts/'
    end

    if not File.exist?('./_data/posts/index.json')
      puts "_data/posts/index.json file does not exist, I am going to create one".yellow
      File.write('./_data/posts/index.json', 'amazing json data placeholder')
    end

    # import STRAPI_TOKEN from the environment. export STRAPI_TOKEN=example
    strapi_token = ENV['STRAPI_TOKEN']
    # check if strapi_token is auth or unauth
    if strapi_token==nil
        # logs data to screen
        puts "STRAPI_TOKEN FAILED, trying an unauthenticated request...".red
        options = {
          headers: ""
        }
      else
        options = {
          # pass authorization header token from ENV
          headers: {
            'Authorization' =>"Bearer #{strapi_token}",
            'Accept'        => 'application/json'
          },
          format: :json
        }
        # set response with all posts data
        response = self.class.get("#{@api_url}/posts?populate=*", options)
        # logs data to screen
        puts "STRAPI_TOKEN SUCCESS! Getting the authenticated data...".green
        # turn http data into a string for json
        res = response.to_s
        # stdout pretty json on jekyll build
        puts JSON.pretty_generate(JSON.parse(res))
        # write raw json data to file
        data_hash = JSON.parse(res)
        File.write('./_data/posts/index.json', JSON.dump(data_hash))

        # download image data to uploads/:year/:image-url
        #url = @api_url.res
        #Down.download(res, destination: "uploads/#{input['name']}")

        # not being used
        #file = File.read('./_data/posts/index.json')
    end
  end
end
# create new Post class
post = Post.new
# debug post.all from def all method
puts post.all
