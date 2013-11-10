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

  # really misleading
  # gets all sets existing for this exercise, as well as previous sessions
  def get
    user = User.find_by_authentication_token(params[:auth_token])
    exercise_id = params[:exercise_id]
    exercise = Exercise.find_by_id(exercise_id)
    routine_id = params[:routine_id]
    routine = Routine.find_by_id(routine_id)

    most_recent_routine_session = UserRoutineSession.where(:user_id => user.id, :routine_id => routine.id).order("created_at desc").first
    if most_recent_routine_session.status == "complete"
      current_ongoing_routine_session = UserRoutineSession.where(:user_id => user.id, :routine_id => routine.id, :status => "complete").order("created_at desc").first
      last_completed_routine_session = UserRoutineSession.where(:user_id => user.id, :routine_id => routine.id, :status => "complete").order("created_at desc").second
      pre_last_completed_routine_session = UserRoutineSession.where(:user_id => user.id, :routine_id => routine.id, :status => "complete").order("created_at desc").third
    else
      current_ongoing_routine_session = UserRoutineSession.where(:user_id => user.id, :routine_id => routine.id, :status => "incomplete").order("created_at desc").first
      last_completed_routine_session = UserRoutineSession.where(:user_id => user.id, :routine_id => routine.id, :status => "complete").order("created_at desc").first
      pre_last_completed_routine_session = UserRoutineSession.where(:user_id => user.id, :routine_id => routine.id, :status => "complete").order("created_at desc").second
    end

    if user.present? && exercise.present?
      # get the current routines exercise sets
      current_exercise_sets = []
      if current_ongoing_routine_session.present?
        current_exercise_sets = ExerciseSet.where(:user_id => user.id, :session_id => current_ongoing_routine_session.id, :exercise_id => exercise.id)
      end

      # also fetch the previous routines exercise sets, if we have it
      prev_exercise_sets = []
      if last_completed_routine_session.present?
        prev_exercise_sets = ExerciseSet.where(:user_id => user.id, :session_id => last_completed_routine_session.id, :exercise_id => exercise.id)
      end

      # and the one before that too...
      pre_prev_exercise_sets = []
      if pre_last_completed_routine_session.present?
        pre_prev_exercise_sets = ExerciseSet.where(:user_id => user.id, :session_id => pre_last_completed_routine_session.id, :exercise_id => exercise.id)
      end

      @response = {
        :status => :success,
        :exercise_sets => current_exercise_sets,
        :previous_sets => prev_exercise_sets,
        :pre_previous_sets => pre_prev_exercise_sets
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
