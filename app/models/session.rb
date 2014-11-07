class Session < ActiveRecord::Base
  belongs_to :user
  has_one :sequence
end
