class Tag < ActiveRecord::Base
  attr_accessible :name

  has_many :routine_tags
  has_many :routines, :through => :routine_tags
end
