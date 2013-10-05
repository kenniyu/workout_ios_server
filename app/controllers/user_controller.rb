class UserController < ActionController::Base
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
end
