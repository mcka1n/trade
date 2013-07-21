require 'mechanize'

class Source
  include Mongoid::Document

  def self.seller_name_cleaner(name_param)
    seller = name_param.to_s.gsub("<cite>", "")
    seller = seller.gsub("</cite>", "")
  end

  def self.price_cleaner(price_param)
    price = price_param.to_s.gsub("<b>", "")
    price = price.gsub("</b>", "")
  end

  def self.get_data(gtin)
    agent = Mechanize.new
    counter = 0
    image = ''
    price = ''
    description = '' 
    product_name = ''

    seller_name = ''
    seller_rating = ''
    url = ''
    product_condition = ''
    product_tax = ''
    total_price = ''
    base_price = ''

    page = agent.get('http://www.google.com/shopping/')
    google_form = page.form('gbqf')

    google_form.q = gtin
    page = agent.submit(google_form, google_form.buttons.first)

    # #########################################
    # nokogiri does the job
    # #########################################
    page.parser.xpath("//table//div[@id='search']//div[@id='ires']//ol//li[@class='g']//div[@class='pslires']").each do |each_pslires|
      
      image = each_pslires.search("//div[@class='psliimg']//a")[counter]
      product_name = each_pslires.search("//div[@class='psliimg']//a//img")[counter].attributes['alt'].to_s.gsub("...", "")
      price =  price_cleaner(each_pslires.search("//div[@class='psliprice']//div//b")[counter])
      seller_name = seller_name_cleaner(each_pslires.search("//div[@class='psliprice']//div//cite")[counter])
      description =  each_pslires.search("//div[@class='pslimain']//h3")[counter]

      if counter == 0
        @product = Product.find_or_create_by(:gtin => gtin, :name => product_name, :image => image)
      else
        @product = Product.find_or_create_by(:gtin => gtin)
      end
      
      #@product_seller = ProductSeller.find_or_create_by(:product_id => @product._id, :name => seller_name, :price => price, :image => image, :description => description)

      # #####################################
      # Clicks and gets data from 2nd page 
      # #####################################
      second_page = each_pslires.search("//div[@class='pslimain']//h3//a")[counter]
      counter_two = 0
      iteration_two = Mechanize::Page::Link.new(second_page, agent, page).click
      
      
      iteration_two.parser.xpath("//div[@id='main-content-with-search']//div[@id='ps-sellers-content']//div[@class='ps-sellers-table-container']//table//tr").each do |each_root_table_tr|
        if counter_two >= 1          

          if !each_root_table_tr.search("//tr//td[@class='seller-col']//span")[counter_two].nil?
            seller_name = each_root_table_tr.search("//tr//td[@class='seller-col']//span")[counter_two].content
          end

          if !each_root_table_tr.search("//tr//td[@class='rating-col']//a[@class='a']")[counter_two].nil?
            seller_rating = each_root_table_tr.search("//tr//td[@class='rating-col']//a[@class='a']")[counter_two].text
          end

          if !each_root_table_tr.search("//tr//td[@class='seller-col']//span//a")[counter_two].nil?
            url = each_root_table_tr.search("//tr//td[@class='seller-col']//span//a")[counter_two].attributes['href']
          end

          if !each_root_table_tr.search("//tr//td[@class='condition-col']//span")[counter_two].nil?
            product_condition = each_root_table_tr.search("//tr//td[@class='condition-col']//span")[counter_two].content
          end

          if !each_root_table_tr.search("//tr//td[@class='taxship-col']//span")[counter_two].nil?
            product_tax = each_root_table_tr.search("//tr//td[@class='taxship-col']//span")[counter_two].content
          end

          if !each_root_table_tr.search("//tr//td[@class='total-col']")[counter_two].nil?
            total_price = each_root_table_tr.search("//tr//td[@class='total-col']")[counter_two].content
          end

          if !each_root_table_tr.search("//tr//td[@class='price-col']//span")[counter_two].nil?
            base_price = each_root_table_tr.search("//tr//td[@class='price-col']//span")[counter_two].content
          end

          if !seller_name.include? "+ Show"
            @product_seller = ProductSeller.find_or_create_by(:product_id => @product._id, :name => seller_name, :rating => seller_rating, :condition => product_condition, :tax => product_tax, :base_price => base_price, :total_price => total_price, :url => url)  
          end
        end
        counter_two = counter_two + 1
      end

      counter = counter + 1
    end
  end
  
end
