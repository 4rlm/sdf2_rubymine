class Brand < ApplicationRecord

  has_many :web_brands, dependent: :destroy
  has_many :webs, through: :web_brands
  accepts_nested_attributes_for :web_brands, :webs

end
