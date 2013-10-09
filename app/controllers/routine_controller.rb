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
        @exercises = routine.exercises.order("created_at asc")
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
end
