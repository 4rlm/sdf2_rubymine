class ActWeb < ApplicationRecord
    belongs_to :act
    belongs_to :web

    accepts_nested_attributes_for :web
    validates_uniqueness_of :act, scope: :web_id
end
