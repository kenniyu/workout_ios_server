class ExerciseSetController < ActionController::Base
  def create
    user = User.find_by_authentication_token(params[:auth_token])
    weight = params[:weight].to_f
    reps = params[:reps].to_i
    exercise_id = params[:exercise_id]
    exercise = Exercise.find_by_id(exercise_id)

    if weight == 0 || reps == 0 || exercise.nil? || user.nil?
      render :nothing => true and return
    end

    @exercise_set = ExerciseSet.new(:user_id => user.id,
                    :exercise_id => exercise.id,
                    :weight => weight,
                    :reps => reps)

    respond_to do |format|
      if @exercise_set.save
        @response = {
          :status => :success
        }
        format.html { redirect_to @exercise_set, notice: 'Exercise set was successfully created.' }
        format.json { render json: @response }
      else
        format.html { render action: "new" }
        format.json { render json: @exercise_set.errors, status: :unprocessable_entity }
      end
    end
  end

end
