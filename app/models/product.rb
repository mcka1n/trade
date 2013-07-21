class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :gtin, :name, :description

  field :gtin, type: String
  field :name, type: String
  field :description, type: String

  has_many :product_sellers

  def self.search(search)
    if search
      Product.all.where gtin: /#{search}/i
    else
      Product.all
    end
  end

end
