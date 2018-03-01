class WebLink < ApplicationRecord
  belongs_to :web
  belongs_to :link

  accepts_nested_attributes_for :link
  validates_uniqueness_of :web, scope: :link_id
end
