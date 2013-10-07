class Muscle < ActiveRecord::Base
  attr_accessible :alias, :name

  belongs_to :exercise_muscle

  has_many :exercise_muscles
  has_many :exercises, :through => :exercise_muscle
end
