class Sequence < ActiveRecord::Base
  has_many :notes
  has_many :sessions
end
