class Team < ApplicationRecord
  validates_uniqueness_of :name
  validates_uniqueness_of :url
end
