class CareerController < ApplicationController
  def exercises
    user = User.find_by_authentication_token(params[:auth_token])

    if user.present?
      exercise_ids = ExerciseSet.where(:user_id => user.id).order("created_at desc").map(&:exercise_id).uniq()
      exercises = Exercise.where(["id in (?)", exercise_ids])

      @response = {
        :exercises => exercises
      }
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @response.to_json }
    end
  end

  def get
    user = User.find_by_authentication_token(params[:auth_token])
    exercise_id = params[:exercise_id]

    if user.present?
      exercise_ids = ExerciseSet.where(:user_id => user.id).order("created_at desc").map(&:exercise_id).uniq()
      if exercise_ids.blank?
        # user has completed 0 exercises
        routine_grouped_exercise_sets = {}
      else
        # user has completed some exercises, so, if no exercise id was part of the request
        # assume we want to show most recent exercise data
        exercise_id = exercise_ids.first if exercise_id.blank?
        exercise_name = Exercise.find_by_id(exercise_id).name
        exercises = Exercise.where(["id in (?)", exercise_ids])

        # grab the 5 most recent sessions that include this exercise
        all_exercise_sets = ExerciseSet.where(["user_id = ? and exercise_id = ?", user.id, exercise_id]).order("created_at desc")
        recent_session_ids = all_exercise_sets.map(&:session_id).uniq().first(5).reverse()
        recent_session_exercise_sets = ExerciseSet.where(["user_id = ? and session_id in (?) and exercise_id = ?", user.id, recent_session_ids, exercise_id])

        # group the exercise sets by session
        routine_grouped_exercise_sets = recent_session_exercise_sets.group_by{|set| set.session_id}

        # prepare the new data to return

        # format the data
        formatted_data = []

        # go through each session and calculate work, time, and finish date
        recent_session_ids.each do |session_id|
          session_exercise_sets = routine_grouped_exercise_sets[session_id]
          total_workload = 0
          working_time = 0
          finish_time = 0
          session_exercise_sets.each do |set|
            rep = set.reps
            weight = set.weight
            workload = rep * weight
            total_workload += workload
            working_time += set.working_time
            finish_time = set.created_at
          end

          # store in data
          formatted_data.push({
            :session_id => session_id,
            :exercise_id => exercise_id,
            :exercise_name => exercise_name,
            :total_workload => total_workload,
            :working_time => working_time,
            :finish_time => finish_time
          })
        end
      end

      @response = {
        :exercises => exercises,
        :grouped_exercise_sets => formatted_data
      }
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @response.to_json }
    end
  end
end
