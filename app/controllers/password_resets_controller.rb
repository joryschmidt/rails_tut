class PasswordResetsController < ApplicationController
  def new
  end

  def edit
  end
  
  def create
    @user = User.find_by(:email, params[:password_reset][:email])
    if @user
      @user.create_reset_digest
      @user.send_password_email
      flash[:info] = 'Please check your email to reset your password'
      redirect_to root_url
    else
      flash.now[:danger] = 'Your email address was not found'
      render 'new'
    end
  end
  
  def update
  end
end
