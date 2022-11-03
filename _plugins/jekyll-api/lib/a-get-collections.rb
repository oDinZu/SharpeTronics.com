# This software gathers all collection types from an API or headless CMS, then saves that data into the Jekyll _data/ folder.
# Copyright (C) SharpeTronics, LLC, 2013-2023

# Author(s): Charles Sharpe(@odinzu_me) aka SharpeTronics, LLC,
# License: GPLv3
# Version: 1.3

# This is Free Software released under GPLv3. Any misuse of this software
# will be followed up with GPL enforcement via Software Freedom Law Center:
# https://www.softwarefreedom.org/

# If you incorporate or include any code from SharpeTronics, LLC,, your
# code must be licensed as GPLv3 (not GPLv2 or MIT)

# The GPLv3 software license applies to the code directly included in this source distribution.
# See the LICENSE & COPYING file for full information.

# Dependencies downloaded as part of the build process may be covered by other open-source licenses.

# We are open to granting a more permissive (such as MIT or Apache 2.0) license to SharpeTronics, LLC,
# software on a *case-by-case* basis, for an agreed upon price. Please email
# info@sharpetronics.com.

# If you would like to contribute to this code, please follow GPLv3 guidelines.
# as an example, after making changes to the software (Called a Fork) and credit the original copyright holder as the creator with your credit added to theirs.

require 'json' # https://ruby-doc.org/stdlib-3.0.2/libdoc/json/rdoc/JSON.html
require 'fileutils' # https://ruby-doc.org/stdlib-2.4.1/libdoc/fileutils/rdoc/FileUtils.html
require 'yaml' # load jekyll yaml config
require 'faraday' # https://lostisland.github.io/faraday/usage/
require 'httpx/adapters/faraday' # https://honeyryderchuck.gitlab.io/httpx/
require 'addressable/uri' # https://github.com/sporkmonger/addressable If you need to normalize URIs, e.g. http://www.詹姆斯.com/
require 'faraday/multipart' # https://github.com/lostisland/faraday-multipart
require 'active_support/core_ext/object/blank' # load only the specific extension for .blank? support

Jekyll.logger.debug "A SharpeTronics bot be building this...[*_-]\n".green.bold
# prepare uri & load _config.yml into config_yml object
config_yml = "_config.yml"
f = YAML.load(File.read(config_yml.to_s)) # r - read file
api_endpoint = f['api']['endpoint']
endpoint_param = f['api']['endpoint_param']
endpoint_ext = f['api']['endpoint_ext']
Jekyll.logger.debug "DEBUG: API_ENDPDOINT for GET COLLECTIONS: " "#{api_endpoint}".to_s.yellow.bold
media_dir = f['api']['local_media_dir']
Jekyll.logger.debug "CONFIG DEBUG: MEDIA_DIR: " "#{media_dir}".to_s.yellow.bold
# authenticated or public API data
# import API_TOKEN from the environment. e.g. export API_TOKEN=example
api_token = ENV['API_TOKEN']
# check if api_token is auth or unauth
if "#{api_token}".blank?
    # logs data to screen
    puts "TOKEN MISSING! Testing a public request without a bearer token... ".red
    options = {
      headers: ""
    }
  else
    # build the connection to the API
    api_builder = Faraday.new do |builder|
      # add the class directly instead of using lookups
      builder.use Faraday::Request::UrlEncoded
      builder.use Faraday::Response::RaiseError

      # add by symbol, lookup from Faraday::Request
      # Faraday::Response and Faraday::Adapter registries
      builder.request :authorization, 'Bearer Token', api_token # include bearer token "options" and authenticated header
      builder.request :json # encode req bodies as JSON and automatically set the Content-Type header
      builder.response :json # decode response bodies as JSON

      builder.adapter :httpx # must add adapter; default is Net:HTTP see README.md
    end
    Jekyll.logger.debug "HTTP DEBUG: BULIDING CONNECTION: #{api_builder}".to_s.yellow.bold
    # logs auth status to screen
    puts ""
    puts "API_DATABASE TOKEN SUCCESS! Getting the authenticated data...".cyan.bold
    puts ""
  end # close if/else

# parses through local Jekyll _config.yml file and gets collection `type`
posts_type = f['api']['collections']['posts']['type']
Jekyll.logger.debug "CONFIG DEBUG: JEKYLL CONFIG POSTS PATH: " "#{posts_type}".to_s.yellow.bold

products_type = f['api']['collections']['products']['type']
Jekyll.logger.debug "CONFIG DEBUG: JEKYLL CONFIG PRODUCTS PATH: " "#{products_type}".to_s.yellow

authors_type = f['api']['collections']['authors']['type']
Jekyll.logger.debug "CONFIG DEBUG: JEKYLL CONFIG AUTHORS PATH: " "#{authors_type}".to_s.yellow.bold

# store filepath config options
posts_filepath = f['api']['collections']['posts']['filepath']
Jekyll.logger.debug "CONFIG DEBUG: JEKYLL CONFIG POSTS FILEPATH: " "#{posts_filepath}".to_s.yellow.bold

products_filepath = f['api']['collections']['products']['filepath']
Jekyll.logger.debug "CONFIG DEBUG: JEKYLL CONFIG PRODUCTS FILEPATH: " "#{products_filepath}".to_s.yellow

authors_filepath = f['api']['collections']['authors']['filepath']
Jekyll.logger.debug "CONFIG DEBUG: JEKYLL CONFIG AUTHORS FILEPATH: " "#{authors_filepath}".to_s.yellow

puts Dir.pwd # where is local directory from plugins folder?
puts Dir.entries("./_data/") # gets contents of local web app dir

# Create posts directory only if they don't exist
if not Dir.exist?("./_data/""#{posts_type}")
  Jekyll.logger.info "the Jekyll posts directory does not exist, let's create one".to_s.red
  Dir.mkdir("./_data/""#{posts_type}")
  Jekyll.logger.info "DIR DEBUG: The local ./_data/posts directory is created at: " "#{posts_type}".to_s.yellow
end

# Create products directory only if they don't exist
if not Dir.exist?("./_data/""#{products_type}")
  Jekyll.logger.info "the Jekyll products directory does not exist, let's create one".to_s.red
  Dir.mkdir("./_data/""#{products_type}")
  Jekyll.logger.info "DIR DEBUG: The local ./_data/products directory is created at: " "#{products_type}".to_s.yellow
end

# Create author directory only if they don't exist
if not Dir.exist?("./_data/""#{authors_type}")
  Jekyll.logger.info "the Jekyll ./_data/authors directory does not exist, let's create one".to_s.red
  Dir.mkdir("./_data/""#{authors_type}")
  Jekyll.logger.info "DIR DEBUG: The local authors directory is created at: " "#{authors_type}".to_s.yellow
end

# build the resource link & populate posts json data
uri_posts = "#{api_endpoint}#{endpoint_ext}#{posts_type}#{endpoint_param}"
Jekyll.logger.debug "HTTP DEBUG: POSTS URI: " "#{uri_posts}".to_s.yellow.bold
# build the resource link & populate posts json data
uri_products = "#{api_endpoint}#{endpoint_ext}#{products_type}#{endpoint_param}"
Jekyll.logger.debug "HTTP DEBUG: PRODUCTS URI: " "#{uri_products}".to_s.yellow
# build the resource link & populate author json data
uri_authors = "#{api_endpoint}#{endpoint_ext}#{authors_type}#{endpoint_param}"
Jekyll.logger.debug "HTTP DEBUG: AUTHORS URI: " "#{uri_authors}".to_s.yellow.bold

# the actual GET with header data; retrieve all product and posts json data from API
posts_api_connect = api_builder.get(uri_posts)
Jekyll.logger.debug "HTTP DEBUG: THE COLLECTION is: #{posts_type} with STATUS CODE: #{posts_api_connect.status}".to_s.cyan.bold

products_api_connect = api_builder.get(uri_products)
Jekyll.logger.debug "HTTP DEBUG: THE COLLECTION is: #{products_type} with STATUS CODE: #{products_api_connect.status}".to_s.cyan.bold

authors_api_connect = api_builder.get(uri_authors)
Jekyll.logger.debug "HTTP DEBUG: THE COLLECTION is: #{authors_type} with STATUS CODE: #{authors_api_connect.status}".to_s.cyan.bold

# store all data into the body of the api
posts_json_data = posts_api_connect.body
Jekyll.logger.debug "HTTP DEBUG: IS POST JSON DATA EMPTY? #{posts_json_data.empty?}".to_s.yellow

products_json_data = products_api_connect.body
Jekyll.logger.debug "HTTP DEBUG: IS PRODUCT JSON DATA EMPTY? #{products_json_data.empty?}".to_s.yellow

authors_json_data = authors_api_connect.body
Jekyll.logger.debug "HTTP DEBUG: IS AUTHORS JSON DATA EMPTY? #{products_json_data.empty?}".to_s.yellow

# opens the posts file and writes the data to the file
Jekyll.logger.debug "WRITING RAW POSTS JSON DATA TO FILE...".yellow.bold
File.write(posts_filepath, JSON.dump(posts_json_data))
puts ""
Jekyll.logger.debug "SUCCESS! JSON POSTS FILE DOWNLOADED...".cyan.bold
puts ""

# opens the products file and writes the data to the file
Jekyll.logger.debug "WRITING RAW PRODUCTS JSON DATA TO FILE...".yellow.bold
File.write(products_filepath, JSON.dump(products_json_data))
puts ""
Jekyll.logger.debug "SUCCESS! JSON PRODUCTS FILE DOWNLOADED...".cyan.bold
puts ""

# opens the authors file and writes the data to the file
Jekyll.logger.debug "WRITING RAW PRODUCTS JSON DATA TO FILE...".yellow.bold
File.write(authors_filepath, JSON.dump(authors_json_data))
puts ""
Jekyll.logger.debug "SUCCESS! JSON AUTHORS FILE DOWNLOADED...".cyan.bold
puts ""
