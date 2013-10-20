class UserController < ActionController::Base
  before_filter :authenticate_user!

  def exercises
    user = User.find_by_authentication_token(params[:auth_token])
    if user.present?
      grouped_exercises = user.get_grouped_exercises
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: grouped_exercises }
      end
    else
      render :nothing => true and return
    end
  end

  def exercise_sets
    user = User.find_by_authentication_token(params[:auth_token])
    exercise = Exercise.find_by_id(params[:exercise_id])
    if user.present? && exercise.present?
      # grouped_sets = user.get_grouped_sets(exercise.id)
      listed_sets = user.get_listed_sets(exercise.id)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: listed_sets }
      end
    else
      render :nothing => true and return
    end
  end

  def delete_exercise_set
    user = User.find_by_authentication_token(params[:auth_token])
    exercise_set = ExerciseSet.find_by_id(params[:exercise_set_id])

    if user.present? && exercise_set.present? && exercise_set.user == user
      exercise_id = exercise_set.exercise_id
      exercise_set.destroy
      listed_sets = user.get_listed_sets(exercise_id)
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: listed_sets }
      end
    else
      render :nothing => true and return
    end
  end

  def batch_update_exercise_set
    user = User.find_by_authentication_token(params[:auth_token])
    exercise_set_ids = params[:exercise_set_ids]
    weights = params[:weights]
    reps = params[:reps]
    exercise_id = params[:exercise_id]

    exercise_set_ids_arr = exercise_set_ids.split(',')
    weights_arr = weights.split(',')
    reps_arr = reps.split(',')

    grouped_update_info = exercise_set_ids_arr.zip(weights_arr, reps_arr)

    if user.present?
      if grouped_update_info.length > 0
        exercise_sets = ExerciseSet.where(["id in (?)", exercise_set_ids_arr])
        render :nothing => true and return if exercise_sets.map(&:exercise_id).uniq.length != 1
        render :nothing => true and return if exercise_sets.map(&:user_id).uniq.length != 1
        render :nothing => true and return if exercise_sets.map(&:user_id)[0] != user.id

        grouped_update_info.each do |update_info|
          exercise_set_id = update_info[0]
          weight = update_info[1].to_f
          reps = update_info[2].to_i

          next if weight == 0 || reps == 0
          ExerciseSet.update_all("weight = #{weight}, reps = #{reps}", "id = #{exercise_set_id}")
        end

        # delete all the ones we did not get
        ExerciseSet.destroy_all(["user_id = ? and exercise_id = ? and id not in (?)", user.id, exercise_id, exercise_set_ids_arr])
      else
        # everything was deleted, so remove all exercise sets where
        # user_id = user.id and exercise_id = exercise_id
        ExerciseSet.destroy_all("user_id = #{user.id} and exercise_id = #{exercise_id}")
      end

      listed_sets = user.get_listed_sets(exercise_id)
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: listed_sets }
      end
    else
      render :nothing => true and return
    end
  end


  def save_routine
    exercise_ids = params[:exercise_ids]
    routine_name = params[:routine_name]
    routine_description = params[:routine_description]

    user = User.find_by_authentication_token(params[:auth_token])
    if user.present? && exercise_ids.present?
      routine_data = Routine.analyze(routine_name, routine_description)
      if routine_data
        tags = routine_data[:tags].uniq
        description = routine_data[:description]
        name = routine_data[:name]
        @routine = Routine.new(:name => name, :description => description, :creator_id => user.id)
        if @routine.save
          routine = @routine.reload
          routine_id = routine.id

          # create tags and associations
          tags.each do |tag_name|
            tag = Tag.find_or_create_by_name(tag_name)

            # create assocation
            RoutineTag.create(:routine_id => routine_id, :tag_id => tag.id)
          end

          # create exercise associations
          exercise_ids_arr = exercise_ids.split(',')
          exercises = Exercise.where(["id in (?)", exercise_ids_arr]).group_by {|exercise| exercise.id}
          exercise_ids_arr.each do |exercise_id|
            if exercises[exercise_id.to_i]
              RoutineExercise.create(:routine_id => routine_id, :exercise_id => exercise_id)
              logger.debug("created")
            end
          end

          @response = {
            :status => :success,
            :message => "Routine saved!"
          }
        else
          @response = {
            :status => :fail,
            :message => "Could not save routine"
          }
        end
      else
        # no routine data
        @response = {
          :status => :fail,
          :message => "Could not save routine"
        }
      end
    else
      # no user
      @response = {
        :status => :fail,
        :message => "Invalid user."
      }
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @response }
    end

  end
end
