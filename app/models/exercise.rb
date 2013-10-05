class Exercise < ActiveRecord::Base
  attr_accessible :exercise_category_id, :name, :user_id

  belongs_to :exercise_category
  belongs_to :user
end
