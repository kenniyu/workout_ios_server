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

  def search
    query = params[:query]
    filter = params[:filter] || "alphabetical"
    @exercises = []
    if query.blank?
      exercises = Exercise.select("exercises.name, exercises.id, exercises.exercise_type, 
      (select muscles.name from muscles where muscles.id in
        (select exercise_muscles.muscle_id from exercise_muscles where exercise_muscles.exercise_id = exercises.id)
        ) as muscle_name").order("exercises.name asc").includes([:exercise_muscle => :muscle ]).group_by{|exercise| exercise.name[0]}
    else
      exercises = Exercise.select("exercises.name, exercises.id, exercises.exercise_type, 
      (select muscles.name from muscles where muscles.id in
        (select exercise_muscles.muscle_id from exercise_muscles where exercise_muscles.exercise_id = exercises.id)
        ) as muscle_name").where(["
      (select muscles.name from muscles where muscles.id in
        (select exercise_muscles.muscle_id from exercise_muscles where exercise_muscles.exercise_id = exercises.id)
        ) like ? or name like ? or exercise_type like ?", "%#{query}%", "%#{query}%", "%#{query}%"]).includes([:exercise_muscle]).group_by{|exercise| exercise.name[0]}
    end

    exercises.each do |section_title, values|
      @exercises << {
                      :title => section_title,
                      :values => values
                    }
    end

    logger.debug(exercises)

    respond_to do |format|
      format.html
      format.json { render json: @exercises.as_json(except: [:force, :level, :mechanics_type, :updated_at, :created_at], include: { exercise_muscle: { include: { muscle: { only: :name } }, only: :muscle_id } }) }
    end
  end
end
