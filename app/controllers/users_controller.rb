class UsersController < ApplicationController
  ACTIVE_MODEL_CLASS = User # UserNeo4j

  before_action :set_user, only: [:show, :edit, :update, :destroy, :invite]

  # GET /users
  # GET /users.json
  def index
    @users = ACTIVE_MODEL_CLASS.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = ACTIVE_MODEL_CLASS.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = ACTIVE_MODEL_CLASS.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to user_path(@user), notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_path(@user), notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def invite
    friend_a = UserNeo4j.first # TODO: Use session user
    friend_b = UserNeo4j.find(@user.neo4j_uuid)

    friend_a.friends << friend_b if friend_a != friend_b

    respond_to do |format|
      format.html { redirect_to user_path(@user), notice: 'User was successfully invited.' }
      format.json { render json: { status: :ok, message: 'User was successfully invited.' } }
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = ACTIVE_MODEL_CLASS.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :website,
      :introduction
    )
  end
end
