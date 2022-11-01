# This software creates product data from the Stripe API and populates it on Strapi frontend dashboard.
# Copyright (C) SharpeTronics, LLC 2013-2023

# Author(s): Charles Sharpe(@odinzu_me) aka SharpeTronics, LLC,
# License: GPLv3
# Version: 1.3

# This is Free Software released under GPLv3. Any misuse of this software
# will be followed up with GPL enforcement via Software Freedom Law Center:
# https://www.softwarefreedom.org/

# If you incorporate or include any code from SharpeTronics, LLC, your
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
require 'yaml' # https://github.com/ruby/yaml
require 'faraday' # https://lostisland.github.io/faraday/usage/
require 'faraday/multipart' # https://github.com/lostisland/faraday-multipart
require 'httpx/adapters/faraday' # https://honeyryderchuck.gitlab.io/httpx/
require 'stripe' # https://github.com/stripe/stripe-ruby
require 'active_support/core_ext/object/blank' # load only the specific extension for .blank? support; normally used with Rails; see Jekyll gemfile
require 'date' # https://github.com/ruby/date
require 'json' # https://ruby-doc.org/stdlib-3.0.2/libdoc/json/rdoc/JSON.html

# read local Jekyll _config.yml data into memory
config_yml = "_config.yml"
f = YAML.load(File.read(config_yml.to_s)) # r - read file

# is Stripe turned on in site _config.yml file?
stripe_enabled = f['api']['stripe']['enabled']

# is Stripe turned on in site _config.yml file?
site_endpoint = f['api']['endpoint']

# reset the Stripe products db
stripe_db_reset = f['api']['stripe']['reset_stripe_db']
Jekyll.logger.debug "ENV DEBUG: Is Stripe enabled? " "#{stripe_enabled}".to_s.yellow.bold

# if Stripe is enabled in _config.yml, get tokens from local environment for accessing Stripe API [see documentation]
if "#{stripe_enabled}" === "true"

  remote_stripe_name = nil # initialize the variable outside the loop
  local_stripe_name = nil # initialize the variable outside the loop

  # set api key globally with Stripe gem
  Stripe.api_key = ENV['STRIPE_LIVE_KEY'] # retrieved from docker-compose machine
  Stripe.max_network_retries = 3
  Stripe.open_timeout = 30 # in seconds

  # store remote stripe json data from Stripe products
  remote_stripe_json_products = Stripe::Product.list # user must create product on Stripe (Live Key)

  # retrieve remote Stripe product name if exists
  # parse through json file
  remote_parse_products = JSON.parse(remote_stripe_json_products.to_s) # returns a hash
  Jekyll.logger.debug "STRIPE HTTPS DEBUG: Download all remote products: \n\n" "#{remote_parse_products} \n".to_s.cyan.bold

  # cache, verify and download each product data from product_name
  remote_stripe_product_data = remote_parse_products["data"].sort_by { |v| -v['id'] } # need ids in ascending order

  # remove all default Stripe data ids that begin with prod_ (ids created with Stripe dashboard))
  filtered_cached_remote_data = remote_stripe_product_data.delete_if{|v| v['id'] =~ /^prod_/} # deletes id hash if exists
  Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Filtered Cached Remote Product IDs: \n\n" "#{filtered_cached_remote_data}\n".to_s.yellow.bold
  
  # retrieve LOCAL Stripe product name
  # set filepath, load the json, then parse through json file
  json_product_path = f['api']['collections']['products']['filepath']

  # must read data into memory before parsing file
  read_products_json = File.read(json_product_path)

  # parse through json files
  local_parsed_products_file = JSON.parse(read_products_json) # returns a hash
  #Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Developer debug: #{local_parsed_products_file}".to_s.yellow
  local_product_data = local_parsed_products_file["data"].sort_by { |v| v['id'] } # need ids in ascending order

  # must have an array of ids to match against locally; checking against a remote API locally, rather than pinging another server with duplicate data on each build.
  cached_local_ids = local_product_data.map { |i| i["id"] }
  Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Cached Local Product ID: " "#{cached_local_ids}".to_s.yellow.bold
  
  cached_remote_ids = remote_stripe_product_data.map { |x| x["id"]} # cache all remote Stripe data.
  Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Cached Remote Product IDs: " "#{cached_remote_ids}".to_s.yellow.bold
  
  cached_remote_updated_product_time = remote_stripe_product_data.map { |x| x["updated"]}
  Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Cached Remote Product Modify Times: " "#{cached_remote_updated_product_time}".to_s.yellow.bold

# begin psueodo code here, b3ep b(oo)p b0p!
  if filtered_cached_remote_data.present?
  
    # the following loop only 'counts' each remote product ID from Stripe API
    filtered_cached_remote_data.each do |update_product|
      # conv remote Stripe product unix epoch time into proper format before local_product loop
      remote_conv_modify_time = update_product['metadata'].dig('build_time')
      Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Remote Product ID: " "#{update_product['id']}" " updated at: " "#{remote_conv_modify_time} \n".to_s.yellow.bold

      # next, we loop through all local product data
      # Go through each local product , then MEASURE against REMOTE TIME product after converted to same format
      local_product_data.each do |local_product|
      
        # store local modify time; all time from Strapi API should be the same
        # this field is currently able to change in Strapi CMS dashboard
        local_conv_modify_time = DateTime.strptime(local_product['attributes']['updatedAt'], '%Y-%m-%dT%H:%M:%S')
        Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Product ID: " "#{local_product['id']}" " updated at: " "#{local_conv_modify_time} \n".to_s.yellow.bold

        # if ids equal, deteremine if modify time is different
        if local_product['id'].to_s == update_product['id'].to_s # going through all local product data and rejecting all product IDs that are  EQUAL to update_product; if no matched ids exist, then this loop ends

          Jekyll.logger.debug "Product ID MATCH FOUND, comparing modify times... \n".to_s.magenta.bold
          
          # do comparison operation of remote and local modify times.
          
          if  local_conv_modify_time.to_s != remote_conv_modify_time.to_s
            
            begin
              puts "After checking if remote json data exists, update the product ".to_s.yellow
              local_product_name = local_product["attributes"]["heading"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Name: " "#{local_product_name}"
              local_product_id = local_product["id"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product ID: " "#{local_product_id}"

              # TODO: Quantity needs to be split into a min, max and starting unit amount; also need to custom_unit_amount
              #local_product_quantity = local_product["attributes"]["quantity"]
              #Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Quantity: " "#{local_product_quantity}"

              local_product_description = local_product["attributes"]["description"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Description: " "#{local_product_description}"
              local_product_weight = local_product["attributes"]["weight"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Weight: " "#{local_product_weight}"
              local_product_webpage_url = local_product["attributes"]["webpage_url"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product WebPage: " "#{local_product_webpage_url}"
              local_product_tax_code = local_product["attributes"]["tax_code"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Tax Code: " "#{local_product_tax_code}"
              local_product_is_shippable = local_product["attributes"]["is_shippable"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Is Shippable?: " "#{local_product_is_shippable}"
              local_product_shipping_rates = local_product["attributes"]["shipping_rates"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Shipping Rates: " "#{local_product_shipping_rates}"

              # TODO: On CMS API, we need to split into 4 seperate values; height, length, weight, width with 2 decimal places
              #local_product_package_dimensions = local_product["attributes"]["package_dimensions"]
              #Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Pk Dimensions: " "#{local_product_package_dimensions}"

              local_product_shipping_companies = local_product["attributes"]["shipping_companies"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Shipping Company: " "#{local_product_shipping_companies}"
              # Prices defined in each available currency option. Each key must be a three-letter ISO currency code and a supported currency. For example, to define your price in eur, pass the fields below in the eur key of currency_options.
              local_product_currency_type = local_product["attributes"]["currency_type"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Currency Type: " "#{local_product_currency_type}"
              local_product_shipping_price = local_product["attributes"]["shipping_price"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Shipping Price: " "#{local_product_shipping_price}"
              # Same as unit_amount, but accepts a decimal value in cents with at most 12 decimal places. Only one of unit_amount and unit_amount_decimal can be set.
              local_product_unit_price = local_product["attributes"]["unit_price"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Unit Price: " "#{local_product_unit_price}"

              # TODO
              # A label that represents units of this product in Stripe and on customers’ receipts and invoices. When set, this will be included in associated invoice line item descriptions.
              #local_product_unit_label = local_product["attributes"]["unit_label"]
              #Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Currency Type: " "#{local_product_unit_label}"

              # TODO
              # An arbitrary string to be displayed on your customer’s credit card or bank statement. While most banks display this information consistently, some may display it incorrectly or not at all.
              # This may be up to 22 characters. The statement description may not include <, >, \, ", ’ characters, and will appear on your customer’s statement in capital letters. Non-ASCII characters are automatically stripped. It must contain at least one letter.
              #local_product_statement_descriptor = local_product["attributes"]["statement_descriptor"]
              #Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Statement Descriptor: " "#{local_product_statement_descriptor}"

              # TODO
              # Only 8 image URLs per product; loop through each image to get the url
              #local_product_images = local_product["attributes"]["gallery"]["data"]["attributes"]["url"]
              #Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Gallery Images: " "#{local_product_images}"

              local_product_banner_image = local_product["attributes"]["banner_image"]["data"]["attributes"]["url"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Image: " "#{site_endpoint}#{local_product_banner_image}"
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Product Beginning Update " "#{local_product_name}".to_s.yellow.bold
              # updates the specific product by setting the values of the parameters passed. Any parameters not provided will be left unchanged.
              Stripe::Product.update(
                "#{local_product_id}", # prod_id that is being updated
                
                name: "#{local_product_name}",
                description: "#{local_product_description}",
                metadata: {build_time: "#{local_conv_modify_time}"},
                
                #unit_amount_decimal: "#{local_product_unit_price * 100 }", # format must be in cents e.g. 2000 cents = $20

                url: "#{site_endpoint + local_product_webpage_url}",
                tax_code: "#{local_product_tax_code}", # must match these codes https://stripe.com/docs/tax/tax-categories
                shippable: "#{local_product_is_shippable}",
                images: ["#{site_endpoint + local_product_banner_image}"],

                # package_dimensions {
                #   weight: "#{local_product_weight}",
                #   height: "#{local_product_height}",
                #   length: "#{local_product_length}",
                #   width: "#{local_product_width}",
                # }

                #name: "#{local_product_shipping_rates}",
                #name: "#{local_product_shipping_companies}",
                #name: "#{local_product_shipping_price}"},
                #unit_amount_decimal: "#{local_product_unit_price}",
              )

              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Product UPDATED! " "#{local_product_name} \n".to_s.cyan.bold
              # check relative stripe product id from each new local_product if error arises
              Stripe::Product.retrieve(local_product_id.to_s)
              rescue Stripe::InvalidRequestError => e
              # Invalid parameters were supplied to Stripe's API
              Jekyll.logger.debug "Stripe Error: Invalid API Request - SKIPPING PRODUCT: " "#{local_product_name}".to_s.red
            end # begin
            
          else
          
          # Skip
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: MODIFY TIMES MATCH, SKIPPING: ".to_s.magenta.bold
          end
          
        else
        
          # Skip
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: IDS DON'T MATCH, SKIPPING: ".to_s.magenta.bold
        end # remote_product['id'] conditional
      end # local product data loop
      
    end # filtered_cached_remote_data
    
  else
  
    Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Remote Stripe Data is EMPTY, SKIPPING PRODUCT UPDATES! ".to_s.red.bold
  end # filtered_cached_remote_data.present?
  
  if  local_product_data.present?

    # the following loop only 'counts' each remote product ID from Stripe API
    filtered_cached_remote_data.each do |update_product|
      Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Remote Product ID: " "#{update_product['id']}".to_s.yellow.bold

        if filtered_cached_remote_data.present?
          
         local_product_data.each do |local_product|

          # if ids are on stripe remote, SKIP
          if local_product_data.reject { |i| i["id"] == update_product['id'] } # going through all local product data and rejecting all product IDs that are NOT EQUAL to update_product; if no matched ids exist, then this loop ends
            Jekyll.logger.debug "Product ID MATCH FOUND!, SKIPPING \n".to_s.magenta.bold
          
          else
            # only execute this after all data is sorted through and compared
            # get all product data from each id
            begin
              puts "Creating products after checking if remote json data exists".to_s.yellow
              local_product_name = local_product["attributes"]["heading"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Name: " "#{local_product_name}"
              local_product_id = local_product["id"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product ID: " "#{local_product_id}"

              # TODO: Quantity needs to be split into a min, max and starting unit amount; also need to custom_unit_amount
              #local_product_quantity = local_product["attributes"]["quantity"]
              #Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Quantity: " "#{local_product_quantity}"

              # store local modify time; all time from Strapi API should be the same
              # this field is currently able to change in Strapi CMS dashboard
              local_conv_modify_time = DateTime.strptime(local_product['attributes']['updatedAt'], '%Y-%m-%dT%H:%M:%S')
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Product ID: " "#{local_product['id']}" " updated at: " "#{local_conv_modify_time} \n".to_s.yellow.bold
              
              local_product_description = local_product["attributes"]["description"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Description: " "#{local_product_description}"
              local_product_weight = local_product["attributes"]["weight"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Weight: " "#{local_product_weight}"
              local_product_webpage_url = local_product["attributes"]["webpage_url"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product WebPage: " "#{local_product_webpage_url}"
              local_product_tax_code = local_product["attributes"]["tax_code"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Tax Code: " "#{local_product_tax_code}"
              local_product_is_shippable = local_product["attributes"]["is_shippable"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Is Shippable?: " "#{local_product_is_shippable}"
              local_product_shipping_rates = local_product["attributes"]["shipping_rates"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Shipping Rates: " "#{local_product_shipping_rates}"

              # TODO: On CMS API, we need to split into 4 seperate values; height, length, weight, width with 2 decimal places
              #local_product_package_dimensions = local_product["attributes"]["package_dimensions"]
              #Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Pk Dimensions: " "#{local_product_package_dimensions}"

              local_product_shipping_companies = local_product["attributes"]["shipping_companies"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Shipping Company: " "#{local_product_shipping_companies}"
              # Prices defined in each available currency option. Each key must be a three-letter ISO currency code and a supported currency. For example, to define your price in eur, pass the fields below in the eur key of currency_options.
              local_product_currency_type = local_product["attributes"]["currency_type"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Currency Type: " "#{local_product_currency_type}"
              local_product_shipping_price = local_product["attributes"]["shipping_price"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Shipping Price: " "#{local_product_shipping_price}"
              # Same as unit_amount, but accepts a decimal value in cents with at most 12 decimal places. Only one of unit_amount and unit_amount_decimal can be set.
              local_product_unit_price = local_product["attributes"]["unit_price"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Unit Price: " "#{local_product_unit_price}"

              # TODO
              # A label that represents units of this product in Stripe and on customers’ receipts and invoices. When set, this will be included in associated invoice line item descriptions.
              #local_product_unit_label = local_product["attributes"]["unit_label"]
              #Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Currency Type: " "#{local_product_unit_label}"

              # TODO
              # An arbitrary string to be displayed on your customer’s credit card or bank statement. While most banks display this information consistently, some may display it incorrectly or not at all.
              # This may be up to 22 characters. The statement description may not include <, >, \, ", ’ characters, and will appear on your customer’s statement in capital letters. Non-ASCII characters are automatically stripped. It must contain at least one letter.
              #local_product_statement_descriptor = local_product["attributes"]["statement_descriptor"]
              #Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Statement Descriptor: " "#{local_product_statement_descriptor}"

              # TODO
              # Only 8 image URLs per product; loop through each image to get the url
              #local_product_images = local_product["attributes"]["gallery"]["data"]["attributes"]["url"]
              #Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Gallery Images: " "#{local_product_images}"

              local_product_banner_image = local_product["attributes"]["banner_image"]["data"]["attributes"]["url"]
              Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Product Image: " "#{local_product_banner_image}"

              # create data on Stripe API
              Stripe::Product.create({
                name: "#{local_product_name}",
                id: "#{local_product_id}",
                description: "#{local_product_description}",

                default_price_data: {
                  currency: "#{local_product_currency_type}",
                  unit_amount_decimal: "#{local_product_unit_price * 100 }", # format must be in cents e.g. 2000 cents = $20
                },

                metadata: {build_time: "#{local_conv_modify_time}"},
                url: "#{site_endpoint + local_product_webpage_url}",
                tax_code: "#{local_product_tax_code}", # must match these codes https://stripe.com/docs/tax/tax-categories
                shippable: "#{local_product_is_shippable}",
                images: ["#{site_endpoint + local_product_banner_image}"],

                # package_dimensions {
                #   weight: "#{local_product_weight}",
                #   height: "#{local_product_height}",
                #   length: "#{local_product_length}",
                #   width: "#{local_product_width}",
                # }

                #name: "#{local_product_shipping_rates}",
                #name: "#{local_product_shipping_companies}",
                #name: "#{local_product_shipping_price}"},
                #unit_amount_decimal: "#{local_product_unit_price}",

              })
              Jekyll.logger.debug "PRODUCT CREATED & POSTED! " "#{local_product_name} \n".to_s.cyan.bold
              # check relative stripe product id from each new local_product if error arises
              Stripe::Product.retrieve(local_product_id.to_s)
              rescue Stripe::InvalidRequestError => e
              # Invalid parameters were supplied to Stripe's API
              Jekyll.logger.debug "Stripe Error: Invalid API Request - SKIPPING PRODUCT: " "#{local_product_name}".to_s.red
            end # begin loop
          end # local_product_data
        end # if local_product_data.reject...
        
        else
          Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Remote Product Data is MISSING: ".to_s.yellow.bold
        end # filtered_cached_remote_data.present?
    end # filter_remote_product_data
    
  else
  
    Jekyll.logger.debug "::DOCUMENT PRODUCT DEBUG:: Local Stripe Data is EMPTY, SKIPPING PRODUCT CREATION! ".to_s.red.bold
  end # local_product_data.present?
  
else

  Jekyll.logger.debug "ENV STRIPE DEBUG: Stripe is disabled, enable it in the _config.yml; see docs for more details. " "#{stripe_enabled}".to_s.red.bold
end
