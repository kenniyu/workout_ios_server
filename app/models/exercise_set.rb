class ExerciseSet < ActiveRecord::Base
  attr_accessible :exercise_id, :reps, :user_id, :weight
  belongs_to :user
end
