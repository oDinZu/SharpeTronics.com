# This software gathers all collection types from an API and saves that data into Jekyll _data/ folder.
# Copyright (C) SharpeTronics, Inc. 2013-2023

# Author(s): Charles Sharpe(@odinzu_me)
# License: GPLv3
# Version: 1

# This is Free Software released under GPLv3. Any misuse of this software
# will be followed up with GPL enforcement via Software Freedom Law Center:
# https://www.softwarefreedom.org/

# If you incorporate or include any code from SharpeTronics, Inc., your
# code must be licensed as GPLv3 (not GPLv2 or MIT)

# The GPLv3 software license applies to the code directly included in this source distribution.
# See the LICENSE & COPYING file for full information.

# Dependencies downloaded as part of the build process may be covered by other open-source licenses.

# We are open to granting a more permissive (such as MIT or Apache 2.0) license to SharpeTronics, Inc.
# software on a *case-by-case* basis, for an agreed upon price. Please contact
# info@sharpetronics.com if you are interested.

# If you would like to contribute to this code, please follow GPLv3 guidelines.
# as an example, after making changes to the software (Called a Fork) and credit the original copyright holder as the creator with your credit added to theirs.

require 'json' # https://ruby-doc.org/stdlib-3.0.2/libdoc/json/rdoc/JSON.html
require 'fileutils' # https://ruby-doc.org/stdlib-2.4.1/libdoc/fileutils/rdoc/FileUtils.html
require 'yaml' # load jekyll yaml config
require 'faraday' # https://lostisland.github.io/faraday/usage/
require 'httpx/adapters/faraday' # https://honeyryderchuck.gitlab.io/httpx/
require 'addressable/uri' # https://github.com/sporkmonger/addressable If you need to normalize URIs, e.g. http://www.詹姆斯.com/
require 'faraday/multipart' # https://github.com/lostisland/faraday-multipart

Jekyll.logger.debug "A Ruby bot be building this...[*_-]\n".green.bold
# prepare uri & load _config.yml into config_yml object
config_yml = "_config.yml"
f = YAML.load(File.read(config_yml.to_s)) # r - read file
api_endpoint = f['api']['endpoint']
endpoint_query = f['api']['endpoint_query']
endpoint_ext = f['api']['endpoint_ext']
Jekyll.logger.debug "DEBUG: API_ENDPDOINT for GET COLLECTIONS: " "#{api_endpoint}".to_s.yellow.bold

# create directory _data/posts/ if doesn't exist
if not Dir.exist?(f['api']['collections']['posts']['type'].to_s)
  puts "folder does not exist, let's create a new folder in Jekyll called: _data/posts/ ".yellow
  Dir.mkdir (f['api']['collections']['posts']['type'].to_s)
end
# create file.json if doesn't exist
if not File.exist?(f['api']['collections']['posts']['filepath'])
  puts "file does not exist, let's create a new file".yellow.bold
  File.write(f['api']['collections']['posts']['filepath'], 'A Ruby bot be building this...[*_-]\n')
end

# authenticated or public API data
# import API_TOKEN from the environment. e.g. export API_TOKEN=example
api_token = ENV['API_TOKEN']
# check if api_token is auth or unauth
if api_token === nil
    # logs data to screen
    puts "ENV DEBUG: API_TOKEN FAILED! Testing a public request without a bearer token... ".red
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
    puts "API_TOKEN SUCCESS! Getting the authenticated data...".green
    puts ""
  end # close if/else

# TODO: add ['products'] collection
# parses through local Jekyll _config.yml file and gets collection `type`
#products_path = "[:site].config['api']['collections']['products']['type']"
posts_path = f['api']['collections']['posts']['type']
Jekyll.logger.debug "CONFIG DEBUG: JEKYLL CONFIG TYPE PATH: " "#{posts_path}".to_s.yellow.bold

# populate all data to have image data available in Strapi
# TODO: update this to work with any URL API in _config.yml; e.g. some API's don't need static /api like Strapi CMS
uri = "#{api_endpoint}#{endpoint_ext}#{posts_path}#{endpoint_query}"
Jekyll.logger.debug "HTTP DEBUG: URI: " "#{uri}".to_s.yellow

# the actual GET with header data; retrieve all json data from API
api_connect = api_builder.get(uri)
Jekyll.logger.debug "HTTP DEBUG: THE COLLECTION IS: #{posts_path} WITH STATUS CODE: #{api_connect.status}".to_s.yellow.bold

# api request variable passing uri and storing inside response var
# response = api_request(uri)
json_data = api_connect.body
Jekyll.logger.debug "HTTP DEBUG: IS JSON DATA EMPTY? #{json_data.empty?}".to_s.yellow
#Jekyll.logger.debug "DEBUG: STOUT JSON DATA: #{json_data}".to_s.yellow.bold

# opens the file and writes the data to the file
Jekyll.logger.debug "WRITING RAW JSON DATA TO FILE...".yellow.bold
File.write('./_data/posts/index.json', JSON.dump(json_data))
puts ""
Jekyll.logger.debug "SUCCESS! JSON FILE DOWNLOADED...".green
puts ""
