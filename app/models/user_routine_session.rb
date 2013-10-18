class UserRoutineSession < ActiveRecord::Base
  attr_accessible :routine_id, :status, :user_id
  # attr_accessible :title, :body
end
