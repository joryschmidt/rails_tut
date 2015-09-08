class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  
  def new
  end

  def edit
  end
  
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
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
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = 'Your password has been reset'
      redirect_to @user
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
  
  def get_user
    @user = User.find_by(email: params[:email])
  end
  
  def valid_user
    unless(@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end
  
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = 'Your reset link has expired'
      redirect_to new_password_reset_url
    end
  end
end
