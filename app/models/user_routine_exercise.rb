class UserRoutineExercise < ActiveRecord::Base
  attr_accessible :exercise_id, :routine_id, :status, :user_id

  belongs_to :user
  belongs_to :exercise
  belongs_to :routine
end
