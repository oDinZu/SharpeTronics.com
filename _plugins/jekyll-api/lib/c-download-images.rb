# This software refactors static json image data and downloads unknown images for building a Jekyll web app.
# Copyright (C) SharpeTronics, Inc. 2013-2023

# Author(s): Charles Sharpe(@odinzu_me) aka SharpeTronics, Inc.
# License: GPLv3
# Version: 1.3

# This is Free Software released under GPLv3. Any misuse of this software
# will be followed up with GPL enforcement via Software Freedom Law Center:
# https://www.softwarefreedom.org/

# If you incorporate or include any code from SharpeTronics, Inc., your
# code must be licensed as GPLv3 (not GPLv2 or MIT)

# The GPLv3 software license applies to the code directly included in this source distribution.
# See the LICENSE & COPYING file for full information.

# Dependencies downloaded as part of the build process may be covered by other open-source licenses.

# We are open to granting a more permissive (such as MIT or Apache 2.0) license to SharpeTronics, Inc.
# software on a *case-by-case* basis, for an agreed upon price. Please email
# info@sharpetronics.com.

# If you would like to contribute to this code, please follow GPLv3 guidelines.
# as an example, after making changes to the software (Called a Fork) and credit the original copyright holder as the creator with your credit added to theirs.

require 'fileutils' # https://ruby-doc.org/stdlib-2.4.1/libdoc/fileutils/rdoc/FileUtils.html
require 'yaml' # load jekyll yaml config
require 'faraday' # https://lostisland.github.io/faraday/usage/
require 'faraday/multipart' # https://github.com/lostisland/faraday-multipart
require 'httpx/adapters/faraday' # https://honeyryderchuck.gitlab.io/httpx/
require 'active_support/core_ext/object/blank' # load only the specific extension for .blank? support

# load and verify _config.yml
config_yml = "_config.yml"
f = YAML.load(File.read(config_yml.to_s)) # r - read file
api_endpoint = f['api']['endpoint']
Jekyll.logger.debug "CONFIG DEBUG: API_ENDPDOINT: " "#{api_endpoint}".to_s.yellow
media_dir = f['api']['local_media_dir']
Jekyll.logger.debug "CONFIG DEBUG: MEDIA_DIR: " "#{media_dir}".to_s.yellow.bold
cache_images = f['api']['cache_images']
Jekyll.logger.debug "CONFIG DEBUG: CACHED_IMAGES_DIR: " "#{cache_images}".to_s.yellow

# check if cache_images is true or false in _config.yml
if "#{cache_images}" === "false" # "If A described a set, would B be a member of that set?" Jörg W Mittag
  Jekyll.logger.debug "CONFIG DEBUG: Downloading images is DISABLED in _config.yml.".to_s.yellow
else
  # determine image directory filepath in _config.yml
  if not Dir.exist?(f['api']['local_media_dir'].to_s)
    Jekyll.logger.info "the Jekyll image directory does not exist, see _config_yml api --> local_media_dir.".to_s.red
    Dir.mkdir f['api']['local_media_dir'].to_s
    Jekyll.logger.info "CONFIG DEBUG: The local media directory is created at: #{f['api']['local_media_dir'].to_s}".to_s.yellow
  end

  # All images are downloaded from EACH NEW collection
  # Each collection is parsed through the local _data json
  # Furthermore, the url is pieced together on each collection type like a post or product.

  # prepare http api connection; this is used for each collection type
  api_builder = Faraday.new do |builder|
    # add by symbol, lookup from Faraday::Request,
    # Faraday::Response and Faraday::Adapter registries
    builder.adapter :httpx # must add adapter; default is Net:HTTP
    #builder.request :authorization, options
    builder.request :multipart
    # identical, but add the class directly instead of using lookups
    builder.use Faraday::Response::RaiseError
  end # api_builder
  Jekyll.logger.debug "HTTP DEBUG: BULIDING CONNECTION: #{api_builder}".to_s.yellow

  # begin sorting through PRODUCT json data
  # determine if using ecommerce integration, then prepare product images from sorting the json data.
  if f['api']['collections']['products']['type'] != 'products' # case sensitive
    Jekyll.logger.debug "CONFIG DEBUG: PRODUCTS FILEPATH IS MISSING IN JEKYLL _CONFIG.YML ".to_s.red.bold
  else
    # load filepath, then parse through json file in _data/posts/index.json
    json_product_path = f['api']['collections']['products']['filepath']
    Jekyll.logger.debug "CONFIG DEBUG: PRODUCTS PATH: " "#{json_product_path}".to_s.yellow.bold

    read_product_json = File.read(json_product_path) # read json for all posts
    #Jekyll.logger.debug "DEBUG: READ JSON FILE: " "#{read_product_json}".to_s.yellow.bold  # basic debug test

    parsed_product_json_file = JSON.parse(read_product_json.to_s) # returns json hash
    Jekyll.logger.debug "JSON DEBUG: IS PARSED_JSON_FILE MISSING? " "#{parsed_product_json_file.blank?}".to_s.magenta  # basic debug test

    # cache / check and download all PRODUCT image data
    product_collection_ids = parsed_product_json_file["data"]
    # loop through each product collection id
    product_collection_ids.each do |id|

      # loop through gallery image data if exists
      if "#{id["attributes"]["gallery"]["data"]}".blank? || "#{id["attributes"]["gallery"]["data"]}".empty?
        Jekyll.logger.debug "GALLERY DEBUG: THE PRODUCT GALLERY DATA DOESN'T EXIST "
      else
        # we only need the urls for each image to prep for download
        product_gallery_images = id["attributes"]["gallery"]["data"]
        # loop through each product image.
        product_gallery_images.each do |image|

          # prepare gallery_image_uri_path  and store in a variable https://www.example.com/uploads/example.webp
          product_gallery_image_uri_path = "#{api_endpoint}""#{image["attributes"]["url"]}"
          Jekyll.logger.debug "PRODUCT FILE DEBUG: GALLERY IMAGE PATH: " "#{product_gallery_image_uri_path}".to_s.yellow

          # prepare gallery_image_file_name and store in a variable
          product_gallery_image_file_name = "#{image["attributes"]["hash"]}"
          Jekyll.logger.debug "PRODUCT FILE DEBUG: GALLERY IMAGE FILE NAME: " "#{product_gallery_image_file_name}".to_s.yellow.bold

          # prepare gallery_image_file_ext and store in a variable
          product_gallery_image_file_ext = "#{image["attributes"]["ext"]}" # get file extension from API
          Jekyll.logger.debug "PRODUCT FILE DEBUG: GALLERY IMAGE FILE EXT: " "#{product_gallery_image_file_ext}".to_s.yellow
          puts ""


          # if cached PRODUCT product_gallery_images exist, skip; else check modified time.
          #File.exist?(media_dir + product_gallery_image_file_name + product_gallery_image_file_ext)
          if File.exist?(media_dir + product_gallery_image_file_name + product_gallery_image_file_ext) === false

            # where the magic happens; we finally download a new image
            gallery_download_image = api_builder.get(product_gallery_image_uri_path)
            Jekyll.logger.debug "DOWNLOADING... THE GALLERY PRODUCT IMAGE URI IS: " "#{product_gallery_image_uri_path}".to_s.cyan.bold  # basic debug test
            Jekyll.logger.debug "HTTP DEBUG: A NEW GALLERY PRODUCT IMAGE HTTP(S) RESPONSE: " "#{gallery_download_image.status}\n" "#{gallery_download_image.headers}\n".to_s.yellow # debug http response status

            # only save file if data exists
            file_exist_debug = File.exist?(media_dir + product_gallery_image_file_name + product_gallery_image_file_ext) # file already exists? then, TODO: skip
            Jekyll.logger.debug "FILE DEBUG: DOES GALLERY PRODUCT IMAGE ALREADY EXIST? " "#{file_exist_debug}".to_s.yellow  # basic debug test

            # TODO: enable to work with Windows NTFS File Systems
            #file_ctime = File.ctime(media_dir + file_name + file_ext) # in NTFS (Windows) returns creation time (birthtime)
            #Jekyll.logger.debug "DEBUG: WHEN WAS FILE LAST MODIFIED? " "#{file_ctime}".to_s.yellow  # basic debug test

            c = File.open(product_gallery_image_file_name + product_gallery_image_file_ext, 'w') # w - Create an empty file for writing.
            c.write(gallery_download_image.body) # write the download to local media_dir
            c.close # close the file
            FileUtils.mv "#{c.path}", "#{media_dir}" # move the file to custom path
            Jekyll.logger.debug "FILE DEBUG: THE WHOLE GALLERY PRODUCT IMAGE FILE NAME " "#{product_gallery_image_file_name}" "#{product_gallery_image_file_ext}".to_s.yellow.bold  # basic debug test
          else
            Jekyll.logger.debug "PRODUCT GALLERY IMAGE ALREADY EXISTS - SKIPPING".to_s.magenta
            # get banner_image_uri_path from each PRODUCT
            if "#{id["attributes"]["banner_image"]["data"]}".blank? || "#{id["attributes"]["banner_image"]["data"]}".empty?
              Jekyll.logger.debug "ERROR: IMAGE DATA EMPTY for PRODUCT: " "#{id["attributes"]["name"]}".to_s.red  # basic debug test
            else
              # set uri_path https://www.example.com/uploads/example.webp
              banner_image_uri_path = "#{api_endpoint}""#{id["attributes"]["banner_image"]["data"]["attributes"]["url"]}"
              Jekyll.logger.debug "PRODUCT FILE DEBUG: PRODUCT BANNER_IMAGE URI_PATH: " "#{banner_image_uri_path}".to_s.yellow

              # get image_file_name
              banner_image_file_name = "#{id["attributes"]["banner_image"]["data"]["attributes"]["hash"]}"
              Jekyll.logger.debug "PRODUCT FILE DEBUG: PRODUCT BANNER_IMAGE URI_PATH: " "#{banner_image_file_name}".to_s.yellow.bold

              # prepare filename
              banner_image_file_ext = "#{id["attributes"]["banner_image"]["data"]["attributes"]["ext"]}"
              Jekyll.logger.debug "PRODUCT FILE DEBUG: THE FILE EXTENSION NAME: " "#{banner_image_file_ext}".to_s.yellow  # basic debug test

              # if cached PRODUCT banner_image_file_name exists, skip; else check modified time.
              #File.exist?(media_dir + banner_image_file_name + banner_image_file_ext).to_s.yellow.bold
              File.exist?(media_dir + banner_image_file_name + banner_image_file_ext)
              if File.exist?(media_dir + banner_image_file_name + banner_image_file_ext) == false

                # where the magic happens; we finally download a new image
                download_image = api_builder.get(banner_image_uri_path)
                Jekyll.logger.debug "DOWNLOADING... THE PRODUCT IMAGE URI IS: " "#{banner_image_uri_path}".to_s.cyan.bold  # basic debug test
                Jekyll.logger.debug "HTTP DEBUG: A NEW PRODUCT IMAGE HTTP(S) RESPONSE: " "#{download_image.status}\n" "#{download_image.headers}\n".to_s.yellow # debug http response status

                # only save file if data exists
                file_exist_debug = File.exist?(media_dir + banner_image_file_name + banner_image_file_ext) # file already exists? then, TODO: skip
                Jekyll.logger.debug "FILE DEBUG: DOES PRODUCT IMAGE ALREADY EXIST? " "#{file_exist_debug}".to_s.yellow  # basic debug test

                # TODO: enable to work with Windows NTFS File Systems
                #file_ctime = File.ctime(media_dir + file_name + file_ext) # in NTFS (Windows) returns creation time (birthtime)
                #Jekyll.logger.debug "DEBUG: WHEN WAS FILE LAST MODIFIED? " "#{file_ctime}".to_s.yellow  # basic debug test

                c = File.open(banner_image_file_name + banner_image_file_ext, 'w') # w - Create an empty file for writing.
                c.write(download_image.body) # write the download to local media_dir
                c.close # close the file
                FileUtils.mv "#{c.path}", "#{media_dir}" # move the file to custom path
                Jekyll.logger.debug "FILE DEBUG: THE WHOLE PRODUCT BANNER IMAGE FILE NAME " "#{banner_image_file_name}" "#{banner_image_file_ext}".to_s.yellow.bold  # basic debug test
              else
                Jekyll.logger.debug "PRODUCT BANNER IMAGE ALREADY EXISTS - SKIPPING".to_s.magenta
              end
            end # end banner_image data
          end # end cached if file exists

        end # ends product gallery images each loop
        puts "" # pretty debug spacing
      end # ends product gallery image data loop

    end # end product_collection_ids
    puts "" # pretty debug spacing
  end # end product formatting check


  # begin parsing through POST json data.
  # prepare post images from sorting the json data.
  if f['api']['collections']['posts']['type'] != 'posts' # case sensitive
    Jekyll.logger.debug "CONFIG DEBUG: POSTS FILEPATH IS MISSING IN JEKYLL _CONFIG.YML ".to_s.red
  else
    # load filepath, then parse through json file in _data/posts/index.json
    json_post_path = f['api']['collections']['posts']['filepath']
    Jekyll.logger.debug "CONFIG DEBUG: POSTS PATH: " "#{json_post_path}".to_s.yellow.bold

    read_post_json = File.read(json_post_path) # read json for all posts
    #Jekyll.logger.debug "DEBUG: READ JSON FILE: " "#{read_post_json}".to_s.yellow.bold  # basic debug test

    parsed_post_json_file = JSON.parse(read_post_json.to_s) # returns json hash
    Jekyll.logger.debug "JSON DEBUG: IS PARSED_JSON_FILE MISSING? " "#{parsed_post_json_file.blank?}".to_s.yellow  # basic debug test

    # cache / check and download all POSTS image data
    post_collection_ids = parsed_post_json_file["data"]
    # loop through each post collection id
    post_collection_ids.each do |id|

      # loop through post gallery image data if exists
      if "#{id["attributes"]["gallery"]["data"]}".blank? || "#{id["attributes"]["gallery"]["data"]}".empty?
        Jekyll.logger.debug "GALLERY DEBUG: THE POST ID: " "#{id["id"]} " "GALLERY DATA DOESN'T EXIST".to_s.magenta
      else
        # we only need the urls for each image to prep for download
        post_gallery_images = id["attributes"]["gallery"]["data"]
        # loop through each post image.
        post_gallery_images.each do |post_image|
        
          # prepare gallery_image_uri_path  and store in a variable https://www.example.com/uploads/example.webp
          post_gallery_image_uri_path = "#{api_endpoint}""#{post_image["attributes"]["url"]}"
          Jekyll.logger.debug "POST FILE DEBUG: POST gallery_image_uri_path: " "#{post_gallery_image_uri_path}".to_s.yellow

          # prepare gallery_image_file_name and store in a variable
          post_gallery_image_file_name = "#{post_image["attributes"]["hash"]}"
          Jekyll.logger.debug "POST FILE DEBUG: POST gallery_image_file_name: " "#{post_gallery_image_file_name}".to_s.yellow.bold

          # prepare gallery_image_file_ext and store in a variable
          post_gallery_image_file_ext = "#{post_image["attributes"]["ext"]}" # get file extension from API
          Jekyll.logger.debug "POST FILE DEBUG: THE POST gallery_image_file_ext: " "#{post_gallery_image_file_ext}".to_s.yellow  # basic debug test
          puts ""

          # if cached POST post_banner_image_file_name exists, skip; else check modified time.
          if File.exist?(media_dir + post_gallery_image_file_name + post_gallery_image_file_ext) === false

            # where the magic happens; we finally download a new image
            post_gallery_download_image = api_builder.get(post_gallery_image_uri_path)
            Jekyll.logger.debug "DOWNLOADING... THE GALLERY POST IMAGE URI IS: " "#{post_gallery_image_uri_path}".to_s.cyan.bold  # basic debug test
            Jekyll.logger.debug "HTTP DEBUG: A NEW GALLERY POST IMAGE HTTP(S) RESPONSE: " "#{post_gallery_download_image.status}\n" "#{post_gallery_download_image.headers}\n".to_s.yellow # debug http response status

            # only save file if data exists
            post_gallery_file_exist_debug = File.exist?(media_dir + post_gallery_image_file_name + post_gallery_image_file_ext) # file already exists? then, TODO: skip
            Jekyll.logger.debug "FILE DEBUG: DOES GALLERY POST IMAGE ALREADY EXIST? " "#{post_gallery_file_exist_debug}".to_s.yellow  # basic debug test

            # TODO: enable to work with Windows NTFS File Systems
            #file_ctime = File.ctime(media_dir + file_name + file_ext) # in NTFS (Windows) returns creation time (birthtime)
            #Jekyll.logger.debug "DEBUG: WHEN WAS FILE LAST MODIFIED? " "#{file_ctime}".to_s.yellow  # basic debug test

            c = File.open(post_gallery_image_file_name + post_gallery_image_file_ext, 'w') # w - Create an empty file for writing.
            c.write(post_gallery_download_image.body) # write the download to local media_dir
            c.close # close the file
            FileUtils.mv "#{c.path}", "#{media_dir}" # move the file to custom path
            Jekyll.logger.debug "FILE DEBUG: THE WHOLE GALLERY POST IMAGE FILE NAME " "#{post_gallery_image_file_name}" "#{post_gallery_image_file_ext}".to_s.yellow.bold  # basic debug test
          else
            Jekyll.logger.debug "POST GALLERY IMAGE ALREADY EXISTS - SKIPPING".to_s.magenta
          end # ends does post gallery image exist?

        end # end post_gallery_images each loop
        puts "" # pretty debug spacing
        
      end # ends post gallery image data loop

        # we only need the urls for each image to prep for download
        #pp id
        post_banner_images = id["attributes"]["banner_image"]["data"]
        # loop through each post image.
        post_banner_images.each do |banner_image|
          # get post_banner_image_uri_path from each POST
          if banner_image.blank? || banner_image.empty?
            Jekyll.logger.debug "ERROR: IMAGE DATA EMPTY for POST: " "#{banner_image["attributes"]["name"]}".to_s.red  # basic debug test
          else
            # set uri_path https://www.example.com/uploads/example.webp            
            post_banner_image_uri_path = "#{api_endpoint}#{id["attributes"]["banner_image"]["data"]["attributes"]["url"]}"
            Jekyll.logger.debug "POST FILE DEBUG: POST BANNER_IMAGE URI_PATH: " "#{post_banner_image_uri_path}".to_s.yellow.bold

            # get image_file_name
            post_banner_image_file_name = "#{id["attributes"]["banner_image"]["data"]["attributes"]["hash"]}"
            Jekyll.logger.debug "POST FILE DEBUG: POST BANNER_IMAGE URI_PATH: " "#{post_banner_image_file_name}".to_s.yellow.bold

            # prepare filename
            post_banner_image_file_ext = "#{id["attributes"]["banner_image"]["data"]["attributes"]["ext"]}"
            Jekyll.logger.debug "POST FILE DEBUG: THE FILE EXTENSION NAME: " "#{post_banner_image_file_ext}".to_s.yellow.bold  # basic debug test

            # if cached POST post_banner_image_file_name exists, skip; else check modified time.
            if File.exist?(media_dir + post_banner_image_file_name + post_banner_image_file_ext) === false

              # where the magic happens; we finally download a new image
              post_banner_download_image = api_builder.get(post_banner_image_uri_path)
              Jekyll.logger.debug "DOWNLOADING... THE POST BANNER IMAGE URI IS: " "#{post_banner_image_uri_path}".to_s.cyan.bold  # basic debug test
              Jekyll.logger.debug "HTTP DEBUG: A NEW POST BANNER IMAGE HTTP(S) RESPONSE: " "#{post_banner_download_image.status}\n" "#{post_banner_download_image.headers}\n".to_s.yellow # debug http response status

              # only save file if data exists
              post_banner_file_exist_debug = File.exist?(media_dir + post_banner_image_file_name + post_banner_image_file_ext) # file already exists?
              Jekyll.logger.debug "FILE DEBUG: DOES POST BANNER IMAGE ALREADY EXIST? " "#{post_banner_file_exist_debug}".to_s.yellow  # basic debug test

              # TODO: enable to work with Windows NTFS File Systems
              #file_ctime = File.ctime(media_dir + file_name + file_ext) # in NTFS (Windows) returns creation time (birthtime)
              #Jekyll.logger.debug "DEBUG: WHEN WAS FILE LAST MODIFIED? " "#{file_ctime}".to_s.yellow  # basic debug test

              c = File.open(post_banner_image_file_name + post_banner_image_file_ext, 'w') # w - Create an empty file for writing.
              c.write(post_banner_download_image.body) # write the download to local media_dir
              c.close # close the file
              FileUtils.mv "#{c.path}", "#{media_dir}" # move the file to custom path
              Jekyll.logger.debug "FILE DEBUG: THE WHOLE POST BANNER IMAGE FILE NAME " "#{post_banner_image_file_name}" "#{post_banner_image_file_ext}".to_s.yellow.bold  # basic debug test
            else
              Jekyll.logger.debug "POST BANNER IMAGE ALREADY EXISTS - SKIPPING".to_s.magenta
            end # end cached if file exists
          end # post banner data exist?
        end # post_banner_images.each do


    end # ends post collection id exist?
    puts "" # pretty debug spacing
  end # end post formatting check

end # end is cache_images enabled?
