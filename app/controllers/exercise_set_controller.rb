class ExerciseSetController < ActionController::Base
  def create
    user = User.find_by_authentication_token(params[:auth_token])
    session_id = params[:session_id]
    session = UserRoutineSession.find_by_id(session_id)
    exercise_id = params[:exercise_id]
    exercise = Exercise.find_by_id(exercise_id)

    if user.present? && session.present? && exercise.present?
      weight = params[:weight].to_f
      reps = params[:reps].to_i
      working_time = params[:working_time].to_f
      resting_time = params[:resting_time].to_f
      @exercise_set = ExerciseSet.create(
        :user_id => user.id,
        :session_id => session.id,
        :exercise_id => exercise.id,
        :weight => weight,
        :reps => reps,
        :working_time => working_time,
        :resting_time => resting_time
      )
      @response = {
        :status => :success,
        :exercise_set => @exercise_set
      }
    else
      @response = {
        :status => :fail,
        :message => "Invalid user, session, or exercise"
      }
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @response.to_json }
    end
  end

  def get
    user = User.find_by_authentication_token(params[:auth_token])
    session_id = params[:session_id]
    session = UserRoutineSession.find_by_id(session_id)
    exercise_id = params[:exercise_id]
    exercise = Exercise.find_by_id(exercise_id)

    if user.present? && session.present? && exercise.present?
      exercise_sets = ExerciseSet.where(:user_id => user.id, :session_id => session.id, :exercise_id => exercise.id)
    end

    if exercise_sets.present?
      @response = {
        :status => :success,
        :exercise_sets => exercise_sets
      }
    else
      @response = {
        :status => :fail,
        :message => "Invalid user, session, or exercise"
      }
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @response.to_json }
    end
  end
end
