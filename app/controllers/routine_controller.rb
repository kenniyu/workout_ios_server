class RoutineController < ApplicationController
  before_filter :authenticate_user!

  def index
    user = User.find_by_authentication_token(params[:auth_token])
    if user.present?
      filter = params[:filter] || "all"
      query = params[:query]

      if query.blank?
        if filter == "all"
          @routines = Routine.order("created_at desc")
        elsif filter == "yours"
          @routines = Routine.where(["creator_id = ?", user.id]).order("created_at desc")
        else
          @routines = Routine.order("created_at desc")
        end
      else
        if filter == "all"
          @routines = Routine.where(["name like ? or description like ?", "%#{query}%", "%#{query}%"]).order("created_at desc")
        elsif filter == "yours"
          @routines = Routine.where(["creator_id = ? and (name like ? or description like ?)", user.id, "%#{query}%", "%#{query}%"]).order("created_at desc")
        else
          @routines = Routine.where(["name like ? or description like ?", "%#{query}%", "%#{query}%"]).order("created_at desc")
        end
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @routines.to_json }
      end
    else
      render :nothing => true and return
    end
  end

  def get
    user = User.find_by_authentication_token(params[:auth_token])
    routine_id = params[:routine_id].to_i
    if user.present? && routine_id > 0
      routine = Routine.find_by_id(routine_id)
      if routine.present?
        # find out if the user has already started this routine
        existingUserRoutineExercises = UserRoutineExercise.where(:user_id => user.id, :routine_id => routine_id)
        if existingUserRoutineExercises.present?
          # they already exist, so return these guys
          @response = existingUserRoutineExercises.order('status desc, updated_at asc')
          render json: @response.as_json(include: :exercise) and return
        else
        # otherwise
          @exercises = routine.exercises.order("created_at asc")
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
        if UserRoutineExercise.exists?(:routine_id => routine.id, :user_id => user.id)
          # we have already created the batch entries for this user and this routine, so return
          @response = {
            :status => :fail,
            :message => "User exercise routines already exist for this user. User has already started this routine"
          }
        else
          # need to batch create userroutineexercises entries for this user and routine
          routine_exercises = routine.exercises
          exercise_ids = routine_exercises.map(&:id)
          exercise_ids.each do |exercise_id|
            UserRoutineExercise.create(:user_id => user.id, :exercise_id => exercise_id, :routine_id => routine_id, :status => "incomplete")
          end
          @response = {
            :status => :success,
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
end
