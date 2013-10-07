class Exercise < ActiveRecord::Base
  attr_accessible :equipment_id, :exercise_type, :force, :level, :mechanics_type, :name

  belongs_to :equipment

  has_many :exercise_muscle
  has_many :muscles, :through => :exercise_muscle

  has_many :primary_muscles, :through => :exercise_muscle, :source => :muscle, :foreign_key => :exercise, :conditions => ["focus = ?", "primary"]
  has_many :secondary_muscles, :through => :exercise_muscle, :source => :muscle, :foreign_key => :exercise, :conditions => ["focus = ?", "secondary"]
end
