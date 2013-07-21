class ProductSeller
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :product_id, :name, :rating, :condition, :tax, :base_price, :total_price, :description, :url

  field :product_id, type: String
  field :name, type: String
  field :rating, type: String
  field :condition, type: String
  field :tax, type: String
  field :base_price, type: String
  field :total_price, type: String
  #field :image, type: String
  field :description, type: String
  field :url, type: String

  belongs_to :product
end
