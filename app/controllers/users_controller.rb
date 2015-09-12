class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end
  
  def new
    @user = User.new
  end
  
  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = 'Please check your email to confirm your account'
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile successfully updated!'
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted'
    redirect_to users_url
  end

  private
  
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    def logged_in_user
      unless logged_in?
        store_location
        flash[:warning] = 'Please login'
        redirect_to login_url
      end
    end
    
    def correct_user
      @user = User.find(params[:id])
      if current_user?(@user)
        return true
      else
        redirect_to root_url unless current_user?(@user)
        flash[:warning] = "Naughty, naughty. You shouldn't try to update others' profiles, you know."
      end
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end