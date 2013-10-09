class RoutineExercise < ActiveRecord::Base
  attr_accessible :exercise_id, :routine_id

  belongs_to :exercise
  belongs_to :routine
end
