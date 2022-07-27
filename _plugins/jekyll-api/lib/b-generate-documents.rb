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
require 'json' # https://ruby-doc.org/stdlib-3.0.2/libdoc/json/rdoc/JSON.html
require 'yaml' # load jekyll yaml config

module Jekyll
  # initialize variables
  product_path = "collections/_products/"
  post_path = "collections/_posts/"
  file_ending = ".md"

  # load _config.yml
  config_yml = "_config.yml"
  f = YAML.load(File.read(config_yml.to_s)) # r - read file
  Jekyll.logger.debug "DOCUMENT DEBUG: Is config empty? " "#{config_yml.empty?}".to_s.yellow

  # set filepath, load the json, then parse through json file in _data/posts/index.json
  json_post_path = f['api']['collections']['posts']['filepath']
  # must read data into memory before parsing file
  read_json = File.read(json_post_path) # read json for all posts
  #json_product_path = f['api']['collections']['products']['path']
  # TODO: update for products also
  parsed_file = JSON.parse(read_json.to_s) # returns a hash

  # cache / check and download all collection post data
  collection_ids = parsed_file["data"]
    # loop through each collection id
    collection_ids.each do |id|
      #puts "#{id}".yellow # output collection id for debug

      # store json specific data for each post
      # check if title date is empty
      if id["attributes"]["title"] === nil
        Jekyll.logger.debug "ERROR: title is empty; does API post have title?".to_s.red
      else
        title = id["attributes"]["title"]
        Jekyll.logger.debug "DOCUMENT DEBUG: Collection Title: " "#{title}".to_s.yellow.bold
      end

      # store slug into object
      slug = id["attributes"]["slug"]
      Jekyll.logger.debug "DOCUMENT DEBUG: Collection Slug: " "#{slug}".to_s.yellow

      # check if sub_heading data is empty
      if id["attributes"]["subheading"] === nil
        Jekyll.logger.debug "ERROR: subheading is empty; does API post have subheading?".to_s.red
      else
        sub_heading = id["attributes"]["subheading"]
        Jekyll.logger.debug "DOCUMENT DEBUG: Collection Subheading: " "#{sub_heading}".to_s.yellow.bold
      end

      # check if date data is empty
      if id["attributes"]["date"] === nil
        Jekyll.logger.debug "ERROR: date is empty; does API post have date?".to_s.red
      else
        date = id["attributes"]["date"]
        Jekyll.logger.debug "DOCUMENT DEBUG: Collection Date: " "#{date}".to_s.yellow
      end

      # check if layout data is empty
      if id["attributes"]["layout"] === nil
        Jekyll.logger.debug "ERROR: layout is empty; does API post have layout?".to_s.red
      else
        layout = id["attributes"]["layout"]
        Jekyll.logger.debug "DOCUMENT DEBUG: Collection Layout: " "#{layout}".to_s.yellow.bold
      end
      # check if author data is empty
      puts "#{id}"
      if "#{id["attributes"]["author"]}".empty? || nil
        Jekyll.logger.debug "ERROR: author is empty; does API post have author?".to_s.red
      else
        author = id["attributes"]["author"]["data"]["attributes"]["name"]
        Jekyll.logger.debug "DOCUMENT DEBUG: Collection Author: " "#{author}".to_s.yellow
      end

      # check if image data is empty
      if "#{id["attributes"]["image"]}".empty? || nil || "#{id["attributes"]["image"]["data"]}".empty?
        Jekyll.logger.debug "ERROR: banner_image url is empty; does API post have banner image url?".to_s.red
      else
        banner_image = id["attributes"]["image"]["data"]["attributes"]["url"]
        Jekyll.logger.debug "DOCUMENT DEBUG: Collection Banner Image: " "#{banner_image}".to_s.yellow.bold
      end

      # check if banner_image_alt data is empty
      if id["attributes"]["image_alt"] === nil
        Jekyll.logger.debug "ERROR: banner_image_alt is empty; does API post have banner_image_alt?".to_s.red
      else
        banner_image_alt = id["attributes"]["image_alt"]
        Jekyll.logger.debug "DOCUMENT DEBUG: Collection Banner Image Alt-text: " "#{banner_image_alt}".to_s.yellow
      end

      # check if tags data is empty
      if "#{id["attributes"]["tags"]}".empty? || nil
        Jekyll.logger.debug "ERROR: tags is empty; does API post have tags?".to_s.red
      else
      # an array for storing multiple input
      tags = id["attributes"]["tags"]["data"]
        # loop through all tags
        tags.each do |tag|
          puts ""
          Jekyll.logger.debug "DOCUMENT DEBUG: Collection Tag(s): " "#{tag}".to_s.yellow
        end
        puts "" # pretty debug spacing
      end

      # check if category data is empty
      if "#{id["attributes"]["category"]}".empty? || nil
        Jekyll.logger.debug "ERROR: category is empty; does API post have a category?".to_s.red
      else
        category = id["attributes"]["category"]["data"]["attributes"]["name"]
        Jekyll.logger.debug "DOCUMENT DEBUG: Collection Category: " "#{category}".to_s.yellow.bold
      end

      # check if content data is empty
      if id["attributes"]["content"] === nil
        Jekyll.logger.debug "ERROR: content is empty; does API post have content?".to_s.red
      else
        content = id["attributes"]["content"]
        Jekyll.logger.debug "DOCUMENT DEBUG: Collection Raw Content: " "#{content}".to_s.yellow
      end

      # create the filename
      file_name = "#{date}-#{slug}#{file_ending}"

      # let us put humpty dumpty back together again!
      # create a new collection type post *.md
      p = File.open( "#{post_path}#{file_name}","w" )

      # file content in Jekyll yaml formatting
      p.puts "---"
      p.puts "layout: #{layout}"
      p.puts "date: #{date}"
      p.puts "author: #{author}"
      p.puts "banner_image: #{banner_image}"   # the banner images are downloaded from API in image-filter.rb.
      p.puts "banner_image_alt: #{banner_image_alt}"
      p.puts "title: #{title}"

      if sub_heading != nil
          p.puts "sub_heading: #{sub_heading}"
      end
      # add tags without json formatting in pretty format
      p.print "tags: " # pretty debug

      if "#{id["attributes"]["tags"]}".empty? || nil
        Jekyll.logger.debug "ERROR: tags is empty; does API post have tags?".to_s.red
      else
        tags = id["attributes"]["tags"]["data"]
          # loop through all tags
          tags.each do |tag|
            p.print tag["attributes"]["tag"]
            p.print ", "
          end
          p.puts "" # pretty debug spacing
      end

      if "#{id["attributes"]["category"]}".empty? || nil
        Jekyll.logger.debug "ERROR: category is empty; does API post have a category?".to_s.red
      else
          category = id["attributes"]["category"]["data"]["attributes"]["name"]
          p.puts "category: " "#{category}"
      end

      p.puts "---" # close .yaml file frontmatter
      p.puts "#{content}" # write post content
      p.close # close the file; stop writing
    end
end
