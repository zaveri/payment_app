class UsersController < ApplicationController  
  
  
  before_filter :logged_in?, :except => [:new, :create]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if(@user.save)
      redirect_to root_path
    else
      render :new
    end
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to root_path
    else
      redirect_to edit_path(current_user.id)
    end
  end
  
  def destroy
  end
  
  def key
    @user = current_user
  end
  
end
