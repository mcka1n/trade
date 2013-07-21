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
        @product = Product.find_or_create_by(:gtin => gtin, :name => product_name)
      else
        @product = Product.find_or_create_by(:gtin => gtin)
      end
      
      @product_seller = ProductSeller.find_or_create_by(:product_id => @product._id, :name => seller_name, :price => price, :image => image, :description => description)

      counter = counter + 1
    end
  end
  
end
