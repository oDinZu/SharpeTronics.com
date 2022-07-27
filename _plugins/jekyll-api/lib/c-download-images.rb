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

require 'fileutils' # https://ruby-doc.org/stdlib-2.4.1/libdoc/fileutils/rdoc/FileUtils.html
require 'yaml' # load jekyll yaml config
require 'faraday' # https://lostisland.github.io/faraday/usage/
require 'faraday/multipart' # https://github.com/lostisland/faraday-multipart
require 'httpx/adapters/faraday' # https://honeyryderchuck.gitlab.io/httpx/

# load and verify _config.yml
config_yml = "_config.yml"
f = YAML.load(File.read(config_yml.to_s)) # r - read file
api_endpoint = f['api']['endpoint']
Jekyll.logger.debug "CONFIG DEBUG: API_ENDPDOINT: " "#{api_endpoint}".to_s.yellow
media_dir = f['api']['local_media_dir']
Jekyll.logger.debug "CONFIG DEBUG: MEDIA DIR: " "#{media_dir}".to_s.yellow.bold
output = f['api']['output']
Jekyll.logger.debug "CONFIG DEBUG: OUTPUT CONFIG: " "#{output}".to_s.yellow

# check if output is true or false in _config.yml
if "#{output}" === "false" || nil
  Jekyll.logger.debug "CONFIG DEBUG: CONFIG FAILED TO LOAD".to_s.yellow
else
  # create image directory if doesn't exist
  if not Dir.exist?(f['api']['local_media_dir'].to_s)
    Jekyll.logger.info "the image directory does not exist, I am going to create one".to_s.red
    Dir.mkdir f['api']['local_media_dir'].to_s
  end

# All images are downloaded from EACH NEW collection
# Each collection is parsed through the local _data json
# Furthermore, the url is pieced together on each collection type like a post or product.

# prepare http api connection
api_builder = Faraday.new do |builder|
  # add by symbol, lookup from Faraday::Request,
  # Faraday::Response and Faraday::Adapter registries
  builder.adapter :httpx # must add adapter; default is Net:HTTP
  #builder.request :authorization, options
  builder.request :multipart
  # identical, but add the class directly instead of using lookups
  builder.use Faraday::Response::RaiseError
end
Jekyll.logger.debug "HTTP DEBUG: BULIDING CONNECTION: #{api_builder}".to_s.yellow

# load file, then parse through json file in _data/posts/index.json
# add new collections here
json_post_path = f['api']['collections']['posts']['filepath']
Jekyll.logger.debug "JSON DEBUG: GET JSON CONFIG PATH: " "#{json_post_path}".to_s.yellow.bold
# TODO: add product_path to parsed_json_file
#json_product_path = f['api']['collections']['products']['path']
#Jekyll.logger.debug "DEBUG: OUTPUT CONFIG: " "#{json_product_path}".to_s.yellow

# TODO: add extra error log if file is missing
read_json = File.read(json_post_path) # read json for all posts
#Jekyll.logger.debug "DEBUG: READ JSON FILE: " "#{read_json}".to_s.yellow.bold  # basic debug test

parsed_json_file = JSON.parse(read_json.to_s) # returns json hash
Jekyll.logger.debug "JSON DEBUG: IS parsed_json_file EMPTY? " "#{parsed_json_file.empty?}".to_s.yellow  # basic debug test

# cache / check and download all collection image data
collection_ids = parsed_json_file["data"]
  # loop through each collection id
  collection_ids.each do |id|
    #puts "#{id}".yellow # output collection id for debug

    # get image_url
    if "#{id["attributes"]["image"]}".to_s.empty? || nil || "#{id["attributes"]["image"]["data"]}".to_s.empty?
      Jekyll.logger.debug "ERROR: IMAGE DATA EMPTY for COLLECTION: " "#{id["attributes"]["title"]}".to_s.red  # basic debug test
    else
      # set uri_path
      uri_path = "#{api_endpoint}""#{id["attributes"]["image"]["data"]["attributes"]["url"]}"
      Jekyll.logger.debug "HTTP DEBUG: URI_PATH:" "#{uri_path}".to_s.yellow.bold

      # get file_name
      file_name = "#{id["attributes"]["image"]["data"]["attributes"]["hash"]}"

      # prepare file
      file_ext = File.extname(uri_path) # get file extension from API
      Jekyll.logger.debug "FILE DEBUG: THE FILE EXTENSION NAME " "#{file_ext}".to_s.yellow.bold  # basic debug test

      # TODO: add image modified time to each API image
      #puts File.exist?(media_dir + file_name + file_ext) #debug if File exists
      if File.exist?(media_dir + file_name + file_ext) === false

        # where the magic happens; download a new image
        image = api_builder.get(uri_path)
        Jekyll.logger.debug "DOWNLOADING... IMAGE URL IS: " "#{id["attributes"]["image"]["data"]["attributes"]["url"]}".to_s.green  # basic debug test
        Jekyll.logger.debug "HTTP DEBUG: A NEW IMAGE HTTP(S) RESPONSE: " "#{image.status}\n" "#{image.headers}\n".to_s.yellow # debug http response status

        # only save file if data exists
        file_exist = File.exist?(media_dir + file_name + file_ext) # file already exists? then, TODO: skip
        Jekyll.logger.debug "FILE DEBUG: DOES FILE ALREADY EXIST? " "#{file_exist}".to_s.yellow  # basic debug test

        # TODO: enable to work with Windows NTFS File Systems
        #file_ctime = File.ctime(media_dir + file_name + file_ext) # in NTFS (Windows) returns creation time (birthtime)
        #Jekyll.logger.debug "DEBUG: WHEN WAS FILE LAST MODIFIED? " "#{file_ctime}".to_s.yellow  # basic debug test

        c = File.open(file_name + file_ext, 'w') # w - Create an empty file for writing.
        c.write(image.body)
        c.close
        FileUtils.mv "#{c.path}", "#{media_dir}"
        Jekyll.logger.debug "FILE DEBUG: THE WHOLE FILE NAME " "#{file_name}" "#{file_ext}".to_s.yellow.bold  # basic debug test
      else
        Jekyll.logger.debug "WARNING: FILE ALREADY EXISTS - SKIPPING".to_s.red.bold  # basic debug test
      end
    end # end if output = true
  end
end
