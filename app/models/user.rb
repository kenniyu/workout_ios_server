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
  has_many :exercise_sets

  def get_grouped_exercises
    final = []
    grouped_exercises = self.exercises.group_by{|e| e.exercise_category_id}
    grouped_exercises.each do |k, v|
      exercise_category = ExerciseCategory.find_by_id(k)
      exercises = []
      v.each do |exercise|
        exercise_data = {
          :exercise_id => exercise.id,
          :exercise_name => exercise.name,
          :category_id => exercise_category.id,
          :category_name => exercise_category.name
        }
        exercises << exercise_data
      end
      final << exercises
    end
    puts final
    return final
  end

  def get_grouped_sets(exercise_id)
    sets = ExerciseSet.where(:user_id => self.id, :exercise_id => exercise_id)

    set_data = []
    sets.each_with_index do |set, index|
      set_hash = {
        :name => "Set #{index + 1}",
        :id => set.id,
        :details => [
          {
            :label => "weight",
            :value => set.weight.to_f
          },
          {
            :label => "reps",
            :value => set.reps
          }
        ]
      }
      set_data << set_hash
    end
    return set_data
  end

  def get_listed_sets(exercise_id)
    sets = ExerciseSet.where(:user_id => self.id, :exercise_id => exercise_id)
    set_data = []
    sets.each_with_index do |set, index|
      set_hash = {
        :id => set.id,
        :set_number => index + 1,
        :weight => set.weight.to_f,
        :reps => set.reps,
        :exercise_id => exercise_id
      }
      set_data << set_hash
    end
    return set_data
  end

  def get_profile_data
    user_routine_sessions = UserRoutineSession.where(:user_id => self.id, :status => "complete")
    profile_data = {
      :completed_sessions => user_routine_sessions.size
    }
    return profile_data
  end
end
