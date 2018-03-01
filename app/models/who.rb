class Who < ApplicationRecord

  has_many :webings, as: :webable
  has_many :webs, through: :webings
  accepts_nested_attributes_for :webings, :webs

  # validates_uniqueness_of :ip, allow_blank: true, allow_nil: true

end
