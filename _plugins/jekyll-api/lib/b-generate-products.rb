# This software generates mardown formatted products from json data.
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

require 'fileutils' # https://ruby-doc.org/stdlib-2.4.1/libdoc/fileutils/rdoc/FileUtils.html
require 'json' # https://ruby-doc.org/stdlib-3.0.2/libdoc/json/rdoc/JSON.html
require 'yaml' # load Jekyll yaml config
require 'active_support/core_ext/object/blank' # load only the specific extension for .blank? support
require 'date' # https://github.com/ruby/date

module Jekyll
  # initialize variables
  jekyll_product_path = "collections/_products/"
  file_ending = ".md"

  # load _config.yml
  config_yml = "_config.yml"
  f = YAML.load(File.read(config_yml.to_s)) # r - read file
  Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Is config empty? " "#{config_yml.blank?}".to_s.magenta.bold

  # is Stripe turned on in site _config.yml file?
  stripe_enabled = f['api']['stripe']['enabled']
  Jekyll.logger.debug "ENV DEBUG: Is Stripe enabled? " "#{stripe_enabled}".to_s.yellow.bold

  # if Stripe is enabled in _config.yml, then generate products
  if "#{stripe_enabled}" === "true"

    # set filepath, load the json, then parse through json file
    json_product_path = f['api']['collections']['products']['filepath']

    # must read data into memory before parsing file
    read_products_json = File.read(json_product_path) # read json for all products

    # parse through json files
    parsed_products_file = JSON.parse(read_products_json.to_s) # returns a hash

    # cache / verify and download each product data
    product_ids = parsed_products_file["data"]
      # loop through each collection id
      product_ids.each do |id|
        # store json specific data for each product
        # determine if stripe_id is blank or null.; this unique identifier is used for Stripe product ids also.
        # this allows overwriting Stripe id and syncronizes ids created from CMS API.
        if "#{id}".blank?
          Jekyll.logger.debug "ERROR: the product id is missing;".to_s.red
        else
          stripe_id = id["id"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Does the JSON data exist? " "#{stripe_id}".to_s.yellow
        end

        # determine if heading is blank or null.
        if "#{id["attributes"]["heading"]}".blank?
          Jekyll.logger.debug "ERROR: the product heading is missing; does product [" "#{heading}] have a heading?".to_s.red
        else
          heading = id["attributes"]["heading"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Heading: " "#{heading}".to_s.yellow.bold
        end

        # store slug into object (object is auto generated with Strapi plugin)
        slug = id["attributes"]["slug"]
        Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Slug: " "#{slug}".to_s.yellow

        # determine if subheading is blank or null.
        if "#{id["attributes"]["subheading"]}".blank?
          Jekyll.logger.debug "ERROR: the subheading is missing; does product [" "#{heading}] have a subheading?".to_s.red
        else
          subheading = id["attributes"]["subheading"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Subheading: " "#{subheading}".to_s.yellow.bold
        end

        # determine if date is blank or null.
        if "#{id["attributes"]["date"]}".blank?
          Jekyll.logger.debug "ERROR: the date is missing; does product [" "#{heading}] have a date?".to_s.red
        else
          date = id["attributes"]["date"]
          # store build times of local products with Stripe metadata
          # on update too Stripe, updates the Stripe updatedAt time creating an infinite loop; we must have a static local time for each product that doesn't change on pushing to Stripe API
          # NOTE: this time needs to be local product data and doesn't come from Strapi CMS API.
          local_cms_time = DateTime.strptime(id['attributes']['updatedAt'], '%Y-%m-%dT%H:%M:%S')
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Date: " "#{date}".to_s.yellow
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Build_Time: " "#{local_cms_time}".to_s.yellow
        end

        # determine if layout is blank or null.
        if "#{id["attributes"]["layout"]}".blank?
          Jekyll.logger.debug "ERROR: the layout is missing; does product [" "#{heading}] have a layout?".to_s.red
        else
          layout = id["attributes"]["layout"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Layout: " "#{layout}".to_s.yellow.bold
        end

        # determine if author data is blank or null.
        if "#{id["attributes"]["author"]["data"]}".blank? || "#{id["attributes"]["author"]["data"]}".empty?
          Jekyll.logger.debug "ERROR: the author is missing; does product [" "#{heading}] have a author?".to_s.red
        else
          author = id["attributes"]["author"]["data"]["attributes"]["name"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Author: " "#{author}".to_s.yellow
        end

        # determine if banner_image is blank or null.
        if "#{id["attributes"]["banner_image"]}".blank?
          Jekyll.logger.debug "ERROR: the banner_image url is missing; does product [" "#{heading}] have a banner image url?".to_s.red
        else
          banner_image = id["attributes"]["banner_image"]["data"]["attributes"]["url"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Banner image: " "#{banner_image}".to_s.yellow.bold
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
          Jekyll.logger.debug "ERROR: the banner_image_description is missing; does product [" "#{heading}] have a banner_image_description?".to_s.red
        else
          banner_image_description = id["attributes"]["banner_image_description"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Banner image desc: " "#{banner_image_description}".to_s.yellow
        end

        # determine if tags data is blank or null, then loop through data.
        if "#{id["attributes"]["tags"]["data"]}".blank? || "#{id["attributes"]["tags"]["data"]}".empty?
          Jekyll.logger.debug "ERROR: the tags is missing; does product [" "#{heading}] have tags?".to_s.red
        else
        # an array for storing multiple inputs
        tags = id["attributes"]["tags"]["data"]
          # loop through each product tag.
          tags.each do |tag|
            puts ""
            Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Tag(s): " "#{tag["attributes"]["tag"]}".to_s.yellow
          end
          puts "" # pretty debug spacing
        end

        # determine if category data is blank or null; only one category per product andor post.
        if "#{id["attributes"]["category"]["data"]}".blank? || "#{id["attributes"]["category"]["data"]}".empty?
          Jekyll.logger.debug "ERROR: the category is missing; does product [" "#{heading}] have a category?".to_s.red
        else
          category = id["attributes"]["category"]["data"]["attributes"]["name"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Category: " "#{category}".to_s.yellow.bold
        end

        # determine if product description is blank or null.
        if "#{id["attributes"]["description"]}".blank?
          Jekyll.logger.debug "ERROR: the the description is missing; does product [" "#{heading}] have a descrption?".to_s.red
        else
          description = id["attributes"]["description"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Raw Content: " "#{description}".to_s.yellow
        end

        # determine if is_featured is blank or null.
        if "#{id["attributes"]["is_featured"]}".blank?
          Jekyll.logger.debug "ERROR: the is_featured is missing; is product " "#{heading} featured?".to_s.red
        else
          is_featured = id["attributes"]["is_featured"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: is_featured: " "#{is_featured}".to_s.yellow.bold
        end

        # determine if is_software is blank or null.
        if "#{id["attributes"]["is_software"]}".blank?
          Jekyll.logger.debug "ERROR: the is_software is missing; is product " "#{heading} software?".to_s.red
        else
          is_software = id["attributes"]["is_software"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: is_software: " "#{is_software}".to_s.yellow.bold
        end

        # determine if is_shippable is blank or null.
        if "#{id["attributes"]["is_shippable"]}".blank?
          Jekyll.logger.debug "ERROR: the is_shippable is missing; is product " "#{heading} shippable?".to_s.red
        else
          is_shippable = id["attributes"]["is_shippable"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: is_shippable: " "#{is_shippable}".to_s.yellow.bold
        end

        # determine if unit_price is blank or null.
        if "#{id["attributes"]["unit_price"]}".blank?
          Jekyll.logger.debug "ERROR: the amount is missing; does product [" "#{heading}] have a price?".to_s.red
        else
          unit_price = id["attributes"]["unit_price"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: unit_price: $" "#{unit_price}".to_s.yellow.bold
        end

        # determine if product quantity is blank or null.
        if "#{id["attributes"]["quantity"]}".blank?
          Jekyll.logger.debug "ERROR: the quantity is missing; does product [" "#{heading}] have a quantity?".to_s.red
        else
          quantity = id["attributes"]["quantity"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: quantity: " "#{quantity}".to_s.yellow.bold
        end

        # determine if product weight is blank or null.
        if "#{id["attributes"]["weight"]}".blank?
          Jekyll.logger.debug "ERROR: the weight is missing; does product [" "#{heading}] have a weight?".to_s.red
        else
          weight = id["attributes"]["weight"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: weight: " "#{weight}".to_s.yellow.bold
        end

        # determine if product package_dimensions is blank or null.
        if "#{id["attributes"]["package_dimensions"]}".blank?
          Jekyll.logger.debug "ERROR: the package_dimensions is missing; does product [" "#{heading}] have a package_dimensions?".to_s.red
        else
          package_dimensions = id["attributes"]["package_dimensions"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: package_dimensions: " "#{package_dimensions}".to_s.yellow.bold
        end

        # determine if product material_type is blank or null.
        if "#{id["attributes"]["material_type"]}".blank?
          Jekyll.logger.debug "ERROR: the material_type is missing; does product [" "#{heading}] have a material_type?".to_s.red
        else
          material_type = id["attributes"]["material_type"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: material_type: " "#{material_type}".to_s.yellow.bold
        end

        # determine if product tax_code is blank or null.
        if "#{id["attributes"]["tax_code"]}".blank?
          Jekyll.logger.debug "ERROR: the tax_code is missing; does product [" "#{heading}] have a tax_code?".to_s.red
        else
          tax_code = id["attributes"]["tax_code"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: tax_code: " "#{tax_code}".to_s.yellow.bold
        end

        # determine if product webpage_url is blank or null.
        if "#{id["attributes"]["webpage_url"]}".blank?
          Jekyll.logger.debug "ERROR: the webpage_url is missing; does product [" "#{heading}] have a webpage_url?".to_s.red
        else
          webpage_url = id["attributes"]["webpage_url"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: webpage_url: " "#{webpage_url}".to_s.yellow.bold
        end

        # determine if product shipping_price is blank or null.
        if "#{id["attributes"]["shipping_price"]}".blank?
          Jekyll.logger.debug "ERROR: the shipping_price is missing; does product [" "#{heading}] have a shipping_price?".to_s.red
        else
          shipping_price = id["attributes"]["shipping_price"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: shipping_price: " "#{shipping_price}".to_s.yellow.bold
        end

        # determine if product currency_type is blank or null.
        if "#{id["attributes"]["currency_type"]}".blank?
          Jekyll.logger.debug "ERROR: the currency_type is missing; does product [" "#{heading}] have a currency_type?".to_s.red
        else
          currency_type = id["attributes"]["currency_type"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: currency_type: " "#{material_type}".to_s.yellow.bold
        end

        # determine if product shipping_rates is blank or null.
        if "#{id["attributes"]["shipping_rates"]}".blank?
          Jekyll.logger.debug "ERROR: the shipping_rates is missing; does product [" "#{heading}] have shipping_rates?".to_s.red
        else
          shipping_rates = id["attributes"]["shipping_rates"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: shipping_rates: " "#{shipping_rates}".to_s.yellow.bold
          #placeholder for looping through each shipping rate option
        end

        # determine if product shipping_companies is blank or null.
        if "#{id["attributes"]["shipping_companies"]}".blank?
          Jekyll.logger.debug "ERROR: the shipping_companies is missing; does product [" "#{heading}] have shipping_companies?".to_s.red
        else
          shipping_companies = id["attributes"]["shipping_companies"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: shipping_companies: " "#{shipping_companies}".to_s.yellow.bold
          #placeholder for looping through each shipping_companies option
        end

        # determine if product country_origin is blank or null.
        if "#{id["attributes"]["country_origin"]}".blank?
          Jekyll.logger.debug "ERROR: the country_origin is missing; does product [" "#{heading}] have a country_origin?".to_s.red
        else
          country_origin = id["attributes"]["country_origin"]
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: country_origin: " "#{country_origin}".to_s.yellow.bold
        end

        # create the filename
        file_name = "#{date}-#{slug}#{file_ending}"

        # let us put humpty dumpty back together again!
        # create a new collection type post *.md
        p = File.open( "#{jekyll_product_path}#{file_name}","w" )

        # create document.md content in Jekyll yaml formatting
        p.puts "---"
        p.puts "stripe_id: #{stripe_id}"
        p.puts "metadata: #{local_cms_time}"
        p.puts "layout: #{layout}"
        p.puts "heading: #{heading}"
        p.puts "subheading: #{subheading}"
        p.puts "slug: #{slug}"
        p.puts "date: #{date}"
        p.puts "author: #{author}"
        p.puts "banner_image: #{banner_image}"   # the banner images are downloaded from API in image-filter.rb.
        p.puts "banner_image_description: #{banner_image_description}"
        p.puts "category: " "#{category}"

        # add gallery images without json formatting in pretty format
        p.print "gallery: \n" # pretty debug
        # loop & gather gallery images from one product
        if "#{id["attributes"]["gallery"]["data"]}".blank?
          Jekyll.logger.debug "WRITING ERROR: the gallery images are missing; does product [" "#{heading}] have any gallery images?".to_s.red
        else
          gallery = id["attributes"]["gallery"]["data"]
            # loop through all tags
            gallery.each do |gallery_image|
              p.print "  - image_path: " "#{gallery_image["attributes"]["url"]} \n"
              p.print "    title: " "#{gallery_image["attributes"]["hash"]} \n"
            end
            p.puts "" # pretty debug spacing
        end

        # add tags without json formatting in pretty format
        p.print "tags: " # pretty debug
        # loop & gather tags from one product
        if "#{id["attributes"]["tags"]["data"]}".blank?
          Jekyll.logger.debug "WRITING ERROR: the tags are missing; does product [" "#{heading}] have any tags?".to_s.red
        else
          tags = id["attributes"]["tags"]["data"]
            # loop through all tags
            tags.each do |tag|
              p.print
              p.print tag["attributes"]["tag"]
              p.print ", "
            end
            p.puts "" # pretty debug spacing
        end

        p.puts "webpage_url: #{webpage_url}"
        p.puts "is_featured: #{is_featured}"
        p.puts "is_software: #{is_software}"
        p.puts "is_shippable: #{is_shippable}"
        p.puts "currency_type: #{currency_type}"
        p.puts "country_origin: #{country_origin}"
        p.puts "unit_price: #{unit_price}"
        p.puts "quantity: #{quantity}"
        p.puts "package_dimensions: #{package_dimensions}"
        p.puts "material_type: #{material_type}"
        p.puts "weight: #{weight}"
        p.puts "tax_code: #{tax_code}"
        p.puts "shipping_price: #{shipping_price}"
        p.puts "shipping_rates: #{shipping_rates}"
        p.puts "shipping_company: #{shipping_companies}"

        p.puts "---" # close .yaml file frontmatter
        p.puts "#{description}" # write product description
        p.close # close the file; stop writing
      end
  else
    Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Stripe is disabled in the _config.yml"
  end
end
