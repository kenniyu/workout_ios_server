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
    @exercises = []
    if query.blank?
      exercises = Exercise.order("name asc").group_by{|exercise| exercise.name[0]}
    else
      exercises = Exercise.where(["name like ?", "%#{query}%"]).group_by{|exercise| exercise.name[0]}
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
      format.json { render json: @exercises.to_json }
    end
  end
end
