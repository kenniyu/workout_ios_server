class ExerciseController < ActionController::Base
  def create
    user = User.find_by_authentication_token(params[:auth_token])
    exercise_category = ExerciseCategory.find_by_id(params[:category_id])
    exercise_name = params[:exercise_name]

    render :nothing => true and return unless (user.present? && exercise_category.present? && exercise_name.present?)

    @exercise = Exercise.new(:name => exercise_name, :exercise_category_id => exercise_category.id, :user_id => user.id)

    respond_to do |format|
      if @exercise.save
        @response = {
          :status => :success
        }
        format.html { redirect_to @exercise, notice: 'Exercise was successfully created.' }
        format.json { render json: @response, :status => :created }
      else
        format.html { render action: "new" }
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
  end
end
