class ExerciseCategoryController < ActionController::Base
  def index
    @exercise_categories = ExerciseCategory.all
    user = User.find_by_authentication_token(params[:auth_token])
    if user.present?
      @exercises = Exercise.find_all_by_user_id(user.id)
      @grouped_exercises = @exercises.group
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @exercise_categories}
    end
  end
end
