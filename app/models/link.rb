class Link < ApplicationRecord

  has_many :web_links, dependent: :destroy
  has_many :webs, through: :web_links
  accepts_nested_attributes_for :web_links, :webs

end
