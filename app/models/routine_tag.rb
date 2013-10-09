class RoutineTag < ActiveRecord::Base
  attr_accessible :routine_id, :tag_id

  belongs_to :tag
  belongs_to :routine
end
