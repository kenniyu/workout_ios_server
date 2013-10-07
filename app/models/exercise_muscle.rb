class ExerciseMuscle < ActiveRecord::Base
  attr_accessible :exercise_id, :focus, :muscle_id

  belongs_to :exercise
  belongs_to :muscle
end
