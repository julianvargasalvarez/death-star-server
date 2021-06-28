class Battle < ApplicationRecord
  validates_uniqueness_of :name

  has_many :measures

  def self.active
    where(status: 'active')
  end

  def data
    f = open("./batalla#{self.id}.csv","r")
    d = f.read().split("\n")
    f.close
    d
  end
end
