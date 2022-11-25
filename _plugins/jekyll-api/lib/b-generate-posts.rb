# This software generates mardown formatted posts from json data.
# Copyright (C) SharpeTronics, LLC, 2013-2023

# Author(s): Charles Sharpe(@odinzu_me) aka SharpeTronics, LLC,
# License: GPLv3
# Version: 1.6

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

require 'fileutils' # https://ruby-doc.org/stdlib-2.4.1/libdoc/fileutils/rdoc/FileUtils.html
require 'json' # https://ruby-doc.org/stdlib-3.0.2/libdoc/json/rdoc/JSON.html
require 'yaml' # load Jekyll yaml config
require 'active_support/core_ext/object/blank' # load only the specific extension for .blank? support
require 'date' # https://github.com/ruby/date

module Jekyll
  # initialize variables
  jekyll_post_path = "collections/_posts/"
  file_ending = ".md"

  # searches for _config.yml file in the root / of the Jekyll project.
  config_yml = "_config.yml"
  f = YAML.load(File.read(config_yml.to_s))
  Jekyll.logger.debug "::DOCUMENT POST DEBUG:: Is the _config.yml available? " "#{f}".to_s.magenta.bold

  # set filepath, load the json, then parse through json file
  json_post_path = f['api']['collections']['posts']['filepath']
  json_author_path = f['api']['collections']['authors']['filepath']
  
  # must read data into memory before parsing file
  read_posts_json = File.read(json_post_path) # read json for all posts
  read_authors_json = File.read(json_post_path) # read json for all authors
  
  # parse through json files
  parsed_posts_file = JSON.parse(read_posts_json.to_s) # returns a hash
  parsed_authors_file = JSON.parse(read_authors_json.to_s) # returns a hash

  # cache / verify and download each post data
  post_ids = parsed_posts_file["data"]
  author_ids = parsed_authors_file["data"]
  
    # loop through each post id
    post_ids.each do |id|

      # get post modify time; it is cached in the Jekyll container
      updatedAt = id["attributes"]["updatedAt"]

      # store json specific data for each post
      # determine if heading is blank or null.
      if "#{id["attributes"]["title"]}".blank? || "#{id["attributes"]["title"]}".empty?
        Jekyll.logger.debug "ERROR: the post title is missing; does the post have a heading?".to_s.red
      else
        title = id["attributes"]["title"]
        Jekyll.logger.debug "::DOCUMENT POST DEBUG:: Title: " "#{title}".to_s.yellow.bold
      end

      # store slug into object (object is auto generated with Strapi plugin)
      slug = id["attributes"]["slug"]
      Jekyll.logger.debug "::DOCUMENT POST DEBUG:: Slug: " "#{slug}".to_s.yellow

      # determine if subheading is blank or null.
      if "#{id["attributes"]["subheading"]}".blank?
        Jekyll.logger.debug "ERROR: the subheading is missing; does post [" "#{title}] have a subheading?".to_s.red
      else
        subheading = id["attributes"]["subheading"]
        Jekyll.logger.debug "::DOCUMENT POST DEBUG:: Subheading: " "#{subheading}".to_s.yellow.bold
      end

      date = DateTime.strptime(id['attributes']['createdAt'], '%Y-%m-%dT%H:%M:%S')
      Jekyll.logger.debug "::DOCUMENT POST DEBUG:: Unformatted Post Creation Date: " "#{date}".to_s.yellow

      # determine if layout is blank or null.
      if "#{id["attributes"]["layout"]}".blank?
        Jekyll.logger.debug "ERROR: the layout is missing; does post [" "#{title}] have a layout?".to_s.red
      else
        layout = id["attributes"]["layout"]
        Jekyll.logger.debug "::DOCUMENT POST DEBUG:: Layout: " "#{layout}".to_s.yellow.bold
      end

      # determine if author data is blank or null.
      if "#{id["attributes"]["author"]["data"]}".blank? || "#{id["attributes"]["author"]["data"]}".blank?
        Jekyll.logger.debug "ERROR: the author is missing; does post [" "#{title}] have a author?".to_s.red
      else
        author = id["attributes"]["author"]["data"]["attributes"]["name"]
        Jekyll.logger.debug "::DOCUMENT POST DEBUG:: Author: " "#{author}".to_s.yellow
      end
      
      # determine if author avatar data is blank or null.
      if "#{id["attributes"]["author"]["data"]["attributes"]["avatar_image"]["data"]}".blank? || "#{id["attributes"]["author"]["data"]["attributes"]["avatar_image"]["data"]}".empty?
          Jekyll.logger.debug "ERROR: the author avatar data is missing; does post [" "#{title}] have a author avatar?".to_s.red
      else
        author_image = id["attributes"]["author"]["data"]["attributes"]["avatar_image"]["data"]["attributes"]["url"]
        Jekyll.logger.debug "::DOCUMENT POST DEBUG:: Author_Avatar URL: " "#{author_image}".to_s.yellow
      end
      
      # determine if banner_image is blank or null.
      if "#{id["attributes"]["banner_image"]["data"]}".blank?
        Jekyll.logger.debug "ERROR: the banner_image url is missing; does post [" "#{title}] have a banner image url?".to_s.red
      else
        banner_image = id["attributes"]["banner_image"]["data"]["attributes"]["url"]
        Jekyll.logger.debug "::DOCUMENT POST DEBUG:: Banner image: " "#{banner_image}".to_s.yellow.bold
      end

      # determine if gallery is blank or null, then loop through data.
      if "#{id["attributes"]["gallery"]["data"]}".blank? || "#{id["attributes"]["gallery"]["data"]}".empty?
        Jekyll.logger.debug "WARNING: the gallery data is missing".to_s.magenta
      else
        # we only need the urls for each image to prep for download
        gallery_images = id["attributes"]["gallery"]["data"]
        # loop through each product image.
        gallery_images.each do |image|
          puts ""
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Gallery image url(s): " "#{image["attributes"]["url"]}".to_s.yellow.bold
        end
        puts "" # pretty debug spacing
      end

      # determine if banner_image_description is blank or null.
      if "#{id["attributes"]["banner_image_description"]}".blank?
        Jekyll.logger.debug "WARNING: the banner_image_description is missing; does post [" "#{title}] have a banner_image_description?".to_s.yellow
      else
        banner_image_description = id["attributes"]["banner_image_description"]
        Jekyll.logger.debug "::DOCUMENT POST DEBUG:: Banner image desc: " "#{banner_image_description}".to_s.yellow
      end

      # determine if tags data is blank or null, then loop through data.
      if "#{id["attributes"]["tags"]["data"]}".blank? || "#{id["attributes"]["tags"]["data"]}".empty?
        Jekyll.logger.debug "ERROR: the tags are missing; does post [" "#{title}] have tags?".to_s.red
      else
      # an array for storing multiple inputs
      tags = id["attributes"]["tags"]["data"]
        # loop through each post tag.
        tags.each do |tag|
          puts ""
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Tag(s): " "#{tag["attributes"]["tag"]}".to_s.yellow
        end
        puts "" # pretty debug spacing
      end

      # determine if category data is blank or null; only one category per post.
      if "#{id["attributes"]["category"]["data"]}".blank? || "#{id["attributes"]["category"]["data"]}".empty?
        Jekyll.logger.debug "ERROR: the category is missing; does post [" "#{title}] have a category?".to_s.red
      else
        category = id["attributes"]["category"]["data"]["attributes"]["name"]
        Jekyll.logger.debug "::DOCUMENT POST DEBUG:: Category: " "#{category}".to_s.yellow.bold
      end

      # determine if post content is blank or null.
      if "#{id["attributes"]["content"]}".blank?
        Jekyll.logger.debug "ERROR: the the content is missing; does post [" "#{title}] have a descrption?".to_s.red
      else
        content = id["attributes"]["content"]
        Jekyll.logger.debug "::DOCUMENT POST DEBUG:: Raw Content: " "#{content}".to_s.yellow
      end

      # create the filename
      file_name = "#{date.strftime('%Y-%m-%d')}-#{slug}#{file_ending}"

      # let us put humpty dumpty back together again!
      # create a new collection type post *.md
      p = File.open( "#{jekyll_post_path}#{file_name}","w" )

      # create document.md content in Jekyll yaml formatting
      p.puts "---"
      p.puts "updatedAt: #{updatedAt}"
      p.puts "layout: #{layout}"
      p.puts "title: #{title}"
      p.puts "subheading: #{subheading}"
      p.puts "slug: #{slug}"
      p.puts "date: #{date.strftime('%Y-%m-%d')}"
      p.puts "author: #{author}"
      p.puts "author_image: #{author_image}"
      p.puts "banner_image: #{banner_image}"   # the banner images are downloaded from API in image-filter.rb.
      p.puts "banner_image_description: #{banner_image_description}"
      p.puts "category: " "#{category}"

      # add tags without json formatting in pretty format
      p.print "tags: " # pretty debug
      # loop & gather tags from one post
      if "#{id["attributes"]["tags"]}".blank? || "#{id["attributes"]["tags"]}".empty?
        Jekyll.logger.debug "WRITING ERROR: the tags are missing; does post [" "#{title}] have any tags?".to_s.red
      else
        tags = id["attributes"]["tags"]["data"]
          # loop through all tags
          tags.each do |tag|
            p.print tag["attributes"]["tag"]
            p.print ", "
          end
          p.puts "" # pretty debug spacing
      end

      p.puts "---" # close .yaml file frontmatter
      p.puts "#{content}" # write post content
      p.close # close the file; stop writing
    end
  
end # jekyll module
