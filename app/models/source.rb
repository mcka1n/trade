require 'mechanize'

class Source
  include Mongoid::Document

  def self.get_data(gtin)
    agent = Mechanize.new
    counter = 0
    image = ''
    price = ''
    description = '' 

    page = agent.get('http://www.google.com/shopping/')
    google_form = page.form('gbqf')

    google_form.q = gtin
    page = agent.submit(google_form, google_form.buttons.first)

    # #########################################
    # nokogiri does the job
    # #########################################
    page.parser.xpath("//table//div[@id='search']//div[@id='ires']//ol//li[@class='g']//div[@class='pslires']").each do |each_pslires|
      
      image = each_pslires.search("//div[@class='psliimg']//a")[counter]
      price =  each_pslires.search("//div[@class='psliprice']//div")[counter]
      description =  each_pslires.search("//div[@class='pslimain']//h3")[counter]

      @product = Product.find_or_create_by(:gtin => gtin)
      @product_seller = ProductSeller.find_or_create_by(:product_id => @product._id, :price => price, :image => image, :description => description)

      counter = counter + 1
    end
  end
  
end
