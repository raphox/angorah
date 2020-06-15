class UsersController < ApplicationController
  ACTIVE_MODEL_CLASS = User # UserNeo4j

  before_action :set_user, only: %i[show friends edit update destroy invite]

  # GET /users
  # GET /users.json
  def index
    @users = ACTIVE_MODEL_CLASS.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    user_neo4j = UserNeo4j.find(@user.neo4j_uuid)

    if params[:q].present?
      friends, friends_path = user_neo4j.friends_by_search(params[:q])
    elsif user_neo4j.present?
      friends = user_neo4j.friends
    end

    # FIXME: Change this When use ACTIVE_MODEL_CLASS as UserNeo4j
    @friends = User.where(:neo4j_uuid.in => friends.pluck(:uuid))
    @friends_path = friends_path&.transform_values do |item|
      uuids = item.map { |node| node.props[:uuid] || node.uuid }

      # it is necessary to order after query in database to preser correct path
      User.where(:neo4j_uuid.in => uuids).
        to_a.sort_by { |value| uuids.index(value.neo4j_uuid) }
    end
  end

  # GET /users/1/friends
  # GET /users/1/friends.json
  def friends
    show # load data

    respond_to do |format|
      format.html { render partial: 'friends' }
      format.json { render json: { status: :ok, message: notice } }
    end
  end

  # GET /users/new
  def new
    @user = ACTIVE_MODEL_CLASS.new
  end

  # GET /users/1/edit
  def edit; end

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

  # GET /users/1/invite
  # GET /users/1/invite.json
  def invite
    notice = 'User was successfully invited.'

    neo4j = UserNeo4j.find(@current_user.neo4j_uuid)
    neo4j.invite(@user.neo4j_uuid)

    respond_to do |format|
      format.js { render json: { status: :ok, message: notice } }
      format.html { redirect_to user_path(@user), notice: notice }
      format.json { render json: { status: :ok, message: notice } }
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
