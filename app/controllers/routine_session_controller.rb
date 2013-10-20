class RoutineSessionController < ApplicationController
  def new
    user = User.find_by_authentication_token(params[:auth_token])
    routine_id = params[:routine_id].to_i

    if user.present? && routine_id > 0
      routine = Routine.find_by_id(routine_id)

      if routine.present?
        # find out if the user has already started a session with this routine
        existing_user_routine_session = UserRoutineSession.where(:routine_id => routine_id, :status => "incomplete", :user_id => user.id)
        if existing_user_routine_session.present?
          # There is already an incomplete session in place, so we can't create a new one
          # we should just return this session
          user_routine_session = existing_user_routine_session.first
        else
          # we should make a brand new routine
          user_routine_session = UserRoutineSession.create(:routine_id => routine_id, :status => "incomplete", :user_id => user.id)
        end
        @response = {
          :status => "success",
          :routine_session => user_routine_session
        }
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
