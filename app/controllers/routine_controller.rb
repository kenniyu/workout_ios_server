class RoutineController < ApplicationController
  before_filter :authenticate_user!

  def index
    user = User.find_by_authentication_token(params[:auth_token])
    if user.present?
      filter = params[:filter] || "all"
      query = params[:query]

      if query.blank?
        if filter == "all"
          @routines = Routine.order("created_at desc").includes([{:exercises => :primary_muscles}])
        elsif filter == "yours"
          @routines = Routine.where(["creator_id = ?", user.id]).order("created_at desc").includes([{:exercises => :primary_muscles}])
        else
          @routines = Routine.order("created_at desc").includes([{:exercises => :primary_muscles}])
        end
      else
        if filter == "all"
          @routines = Routine.where(["name like ? or description like ?", "%#{query}%", "%#{query}%"]).order("created_at desc").includes([{:exercises => :primary_muscles}])
        elsif filter == "yours"
          @routines = Routine.where(["creator_id = ? and (name like ? or description like ?)", user.id, "%#{query}%", "%#{query}%"]).order("created_at desc").includes([{:exercises => :primary_muscles}])
        else
          @routines = Routine.where(["name like ? or description like ?", "%#{query}%", "%#{query}%"]).order("created_at desc").includes([{:exercises => :primary_muscles}])
        end
      end

      @user_routine_sessions = UserRoutineSession.where(:user_id => user.id)
      user_routine_sessions_data = {}

      @user_routine_sessions.each do |session|
        status = session.status == "complete" ? "terminated" : "ongoing"
        count = session.status == "complete" ? 1 : 0
        if !user_routine_sessions_data[session.routine_id]
          user_routine_sessions_data[session.routine_id] = {
            :times_completed => count,
            :status => status
          }
        else
          if status != "ongoing"
            # only update count and status is not ongoing
            user_routine_sessions_data[session.routine_id][:times_completed] += 1
          else
            user_routine_sessions_data[session.routine_id][:status] = status
          end
        end
      end

      primary_muscles_data = {}
      @routines.each do |routine|
        exercises = routine.exercises
        if routine.id == 11
          puts exercises
        end
        primary_muscles = exercises.map(&:primary_muscles).flatten.map(&:name).uniq()
        primary_muscles_data[routine.id] = primary_muscles
      end

      @response = {
        :routines => @routines,
        :primary_muscles => primary_muscles_data,
        :user_routine_sessions => user_routine_sessions_data
      }
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @response }
      end
    else
      render :nothing => true and return
    end
  end

  def preview
    # previews a routine
    user = User.find_by_authentication_token(params[:auth_token])
    routine_id = params[:routine_id].to_i
    routine = Routine.find_by_id(routine_id)

    if user.present? && routine.present?
      primary_muscles = routine.exercises.includes(:primary_muscles).map(&:primary_muscles).flatten.map(&:name).uniq
      secondary_muscles = routine.exercises.includes(:secondary_muscles).map(&:secondary_muscles).flatten.map(&:name).uniq
      secondary_muscles.delete_if{|muscle|primary_muscles.include?(muscle)}
    end

    @response = {
      :routine => routine,
      :primary_muscles => primary_muscles,
      :secondary_muscles => secondary_muscles
    }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @response.to_json }
    end
  end

  def get
    user = User.find_by_authentication_token(params[:auth_token])
    routine_id = params[:routine_id].to_i

    if user.present? && routine_id > 0
      routine = Routine.find_by_id(routine_id)

      if routine.present?
        # find out if the user has already started a session with this routine
        existing_user_routine_session = UserRoutineSession.where(:routine_id => routine_id, :user_id => user.id).order("created_at desc")
        if existing_user_routine_session.present?
          # There were routine sessions from before
          # Get the most recent one, which would be the last one
          # and check to see if it's complete
          most_recent_user_routine_session = existing_user_routine_session.first

          if most_recent_user_routine_session.status == "completed"
            # we need to make a brand new routine
            UserRoutineSession.create(:routine_id => routine_id, :status => "incomplete", :user_id => user.id)
          else
            # we have an ongoing routine, do nothing
          end

          # fetch the user routine exercises
          @exercises = routine.exercises.includes([:routine_exercises]).order("routine_exercises.created_at asc")

=begin
          user_routine_exercises = UserRoutineExercise.where(:routine_id => routine_id, :user_id => user.id)
          @response = user_routine_exercises.order("status desc, updated_at asc")
          render json: @response.as_json(include: :exercise) and return
=end
        else
        # otherwise
          @exercises = routine.exercises.includes([:routine_exercises]).order("routine_exercises.created_at asc")
        end
        @response = @exercises
      else
        @response = {
          :status => :fail,
          :message => "Routine does not exist"
        }
      end
    else
      @response = {
        :status => :fail,
        :message => "Invalid user or routine"
      }
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @response.to_json }
    end
  end

  def start
    user = User.find_by_authentication_token(params[:auth_token])
    routine_id = params[:routine_id].to_i

    if user.present? && routine_id > 0
      routine = Routine.find_by_id(routine_id)

      if routine.present?
        # first check to see if a user with this routine has session that is incomplete
        if UserRoutineSession.exists?(:routine_id => routine.id, :user_id => user.id, :status => "incomplete")
          # we cannot start a new routine since an ongoing one exists
          @response = {
            :status => :fail,
            :message => "User exercise routines already exist for this user. User has already started this routine"
          }
        else
          # create a new session and mark as incomplete
          user_routine_session = UserRoutineSession.create(:routine_id => routine.id, :user_id => user.id, :status => "incomplete")
          # need to batch create userroutineexercises entries for this user and routine
          routine_exercises = routine.exercises
          exercise_ids = routine_exercises.map(&:id)
          exercise_ids.each do |exercise_id|
            UserRoutineExercise.create(:user_id => user.id, :exercise_id => exercise_id, :routine_id => routine_id, :status => "incomplete")
          end
          @response = {
            :status => :success,
            :session_id => user_routine_session.id,
            :message => "Created user exercise routines"
          }
        end
      else
        @response = {
          :status => :fail,
          :message => "routine does not exist!"
        }
      end
    else
      @response = {
        :status => :fail,
        :message => "Invalid user or routine"
      }
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @response.to_json }
    end
  end

  def complete_exercise
    user = User.find_by_authentication_token(params[:auth_token])
    routine_id = params[:routine_id].to_i
    exercise_id = params[:exercise_id].to_i
    if user.present? && routine_id > 0 && exercise_id > 0
      routine = Routine.find_by_id(routine_id)
      exercise = Exercise.find_by_id(exercise_id)
      if routine.present? && exercise.present? && routine.exercises.map(&:id).include?(exercise_id)
        # this exercise is part of this routine
        # complete it
        user_exercise_routine = UserRoutineExercise.find_by_user_id_and_exercise_id_and_routine_id(user.id, exercise_id, routine_id)
        user_exercise_routine.update_attributes(:status => "completed")
        if user_exercise_routine.save
          @exercises = routine.exercises.order("created_at asc")
          @response = {
            :status => :success,
            :message => "Completed user exercise routine"
          }
        else
          @response = {
            :status => :fail,
            :message => "Could not update user exercise routine"
          }
        end
      else
        @response = {
          :status => :fail,
          :message => "Matching routine and exercise do not exist"
        }
      end
    else
      @response = {
        :status => :fail,
        :message => "Invalid user or routine"
      }
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @response.to_json }
    end
  end

  def complete_routine
    user = User.find_by_authentication_token(params[:auth_token])
    routine_id = params[:routine_id].to_i
    if user.present? && routine_id > 0
      routine = Routine.find_by_id(routine_id)
      user_routine_session = UserRoutineSession.find_by_user_id_and_routine_id_and_status(user.id, routine.id, "incomplete")
      if routine.present? and user_routine_session.present?
        # valid to complete
        user_routine_session.status = "complete"
        user_routine_session.save
        @response = {
          :status => :success,
          :message => "Completed user exercise routine"
        }
      else
        @response = {
          :status => :fail,
          :message => "Matching routine and exercise do not exist"
        }
      end
    else
      @response = {
        :status => :fail,
        :message => "Invalid user or routine"
      }
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @response.to_json }
    end
  end
end
