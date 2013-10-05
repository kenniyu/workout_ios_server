class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  #
  has_many :exercises

  def get_grouped_exercises
    final = []
    grouped_exercises = self.exercises.group_by{|e| e.exercise_category_id}
    grouped_exercises.each do |k, v|
      exercise_category = ExerciseCategory.find_by_id(k)
      exercises = []
      v.each do |exercise|
        exercise_data = {:exercise_id => exercise.id, :exercise_name => exercise.name}
        exercises << exercise_data
      end
      data = { :category_id => exercise_category.id, :category_name => exercise_category.name, :exercises => exercises }
      final << data
    end
    return final
  end
end
