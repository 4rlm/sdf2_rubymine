class WebBrand < ApplicationRecord
  belongs_to :web
  belongs_to :brand

  accepts_nested_attributes_for :web
  validates_uniqueness_of :web, scope: :brand_id
end
