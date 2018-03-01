class Act < ApplicationRecord
  # before_validation :full_address, :track_change
  before_save :full_address, :track_change

  # has_many :conts, inverse_of: :act, optional: true
  validates_uniqueness_of :gp_id, allow_blank: true, allow_nil: true

  # has_one :act_web, dependent: :destroy
  # has_one :web, through: :act_web
  has_many :act_webs, dependent: :destroy
  has_many :webs, through: :act_webs

  has_many :conts, through: :webs
  has_many :links, through: :webs
  has_many :brands, through: :webs

  accepts_nested_attributes_for :act_webs, :webs, :conts, :links, :brands

  def full_address
    self.full_address = [street, city, state, zip].compact.join(', ')
  end

  def track_change
    self.adr_changed = Time.now if full_address_changed?
    self.act_changed = Time.now if act_name_changed?
  end


    # adr_changed: nil, act_changed: nil
    # attrs = ["full_address", "street2", "city", "state", "zipcode"]
    #
    # if (self.changed & attrs).any?
    #   then do something....
    # end

    # before_update :notify, :if => :my_attribute_changed?
    # puts "The Attribute 'my_attribute' has been changed!"



end
