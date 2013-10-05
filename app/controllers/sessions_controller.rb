class SessionsController < Devise::SessionsController
  before_filter :authenticate_user!, :except => [:create, :destroy]
  respond_to :json

  def create
    email = params[:email] || params[:user][:email]
    password = params[:password] || params[:user][:password]
    resource = User.find_for_database_authentication(:email => email)
    return invalid_login_attempt unless resource

    if resource.valid_password?(password)
      sign_in(:user, resource)
      resource.ensure_authentication_token!
      render :json=> {:success=>true, :id=>resource.id, :auth_token=>resource.authentication_token, :email=>resource.email}
    return
    end
    invalid_login_attempt
  end

  def destroy
    email = params[:email] || params[:user][:email]
    resource = User.find_for_database_authentication(:email => email)
    resource.authentication_token = nil
    resource.save
    render :json=> {:success=>true}
  end

  protected

  def invalid_login_attempt
    render :json=> {:success=>false, :message=>"Error with your login or password"}, :status=>401
  end
end
