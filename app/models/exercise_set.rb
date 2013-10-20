class ExerciseSet < ActiveRecord::Base
  attr_accessible :exercise_id, :reps, :user_id, :weight, :session_id, :working_time, :resting_time
  belongs_to :user

  belongs_to :user_routine_session, :foreign_key => :session
end
