class ExerciseCategoryController < ActionController::Base
  def index
    @exercise_categories = ExerciseCategory.where(["name LIKE ?", "#{params[:category_name]}%"])
    user = User.find_by_authentication_token(params[:auth_token])
    if user.present?
      @exercises = Exercise.find_all_by_user_id(user.id)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @exercise_categories}
    end
  end
end
