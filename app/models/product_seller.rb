class ProductSeller
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :product_id, :name, :price, :image, :description

  field :product_id, type: String
  field :name, type: String
  field :price, type: String
  field :image, type: String
  field :description, type: String
end
