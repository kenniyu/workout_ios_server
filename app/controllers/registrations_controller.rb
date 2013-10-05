class RegistrationsController < Devise::RegistrationsController
  def create
    respond_to do |format|
      format.html {
        super
      }
      format.json {
        email = params[:user][:email]
        if email.nil?
          render :status => 400,
          :json => {:error_code => 'EMAIL_BLANK',
              :message => 'Please enter a valid email.'}
          return
        elsif email.present?
          at_pos = email.rindex("@")
          dot_pos = email.rindex(".")
          if (at_pos < dot_pos && at_pos > 0 && !email.index("@@") && dot_pos > 2 && (email.length - dot_pos > 2))
            # valid email format, check for dups
            duplicate_user = User.find_by_email(email)
            unless duplicate_user.nil?
              render :status => 409,
              :json => {
                :error_code => "EMAIL_EXISTS",
                :message => 'This email is already taken!'
              }
              return
            end
          else
            # invalid email format
            render :status => 400,
            :json => {
              :error_code => "EMAIL_INVALID",
              :message => 'Please enter a valid email'
            }
            return
          end
        end

        if params[:user][:password].nil? || params[:user][:password].length < 6
          render :status => 400,
          :json => {
            :error_code => "PASSWORD_INVALID",
            :message => 'Password must be at least 6 characters'
          }
          return
        else
          # valid password, check for confirmation
          if params[:user][:password_confirmation].present?
            if params[:user][:password_confirmation] != params[:user][:password]
              render :status => 400,
              :json => {
                :error_code => "CONFIRM_PASSWORD_MISMATCH",
                :message => 'Passwords must match'
              }
              return
            end
          else
          render :status => 400,
          :json => {
            :error_code => "CONFIRM_PASSWORD_BLANK",
            :message => 'Please confirm your password'
          }
          return
          end
        end

        @user = User.create(params[:user])

        if @user.save
          render :json => {:user => @user}
        else
          render :status => 400,
          :json => {:message => @user.errors.full_messages}
        end
      }
    end
  end
end
