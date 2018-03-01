class Web < ApplicationRecord

  validates_uniqueness_of :url, allow_blank: false, allow_nil: false
  has_many :conts

  has_many :web_links, dependent: :destroy
  has_many :links, through: :web_links

  has_many :web_brands, dependent: :destroy
  has_many :brands, through: :web_brands

  has_many :act_webs, dependent: :destroy
  has_many :acts, through: :act_webs

  accepts_nested_attributes_for :act_webs, :acts, :conts, :web_links, :links, :web_brands, :brands
end
