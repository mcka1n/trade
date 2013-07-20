class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :gtin, :name, :description

  field :gtin, type: String
  field :name, type: String
  field :description, type: String


end
