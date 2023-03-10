class UsersController < ApplicationController

  def index
    @users = User.all

    @markers = @users.geocoded.map do |user|
      {
        lat: user.latitude,
        lng: user.longitude,
        profile_window_html: render_to_string(partial: "profile_window", locals: { user: user }),
        marker_html: render_to_string(partial: "marker")
      }
    end
  end

  def search_map; end

  def filter_users_map
    users_filtered_by_gender_params = User.all.where(gender: params[:gender])
    category = Category.find_by(name: params[:categories])
    interests = Interest.where(user_id: users_filtered_by_gender_params.ids, category_id: category)
    @users_for_map = interests.map { |interest| User.find(interest.user_id) }
    users_filtered_by_location_params = User.near(params[:address], 2).to_a
    results = @users_for_map & users_filtered_by_location_params
    # maybe use SQL query to find ILIKE for address from user (so returns all users with that address-ish)
    @markers = results.map do |user|
      {
        lat: user.geocode[0],
        lng: user.geocode[1],
        profile_window_html: render_to_string(partial: "profile_window", locals: { user: user }),
        marker_html: render_to_string(partial: "marker")
      }
    end

    # redirect_to user_get_filter_users_map_path, params: @markers
    redirect_to controller: 'users', action: 'the_results', markers: @markers
  end

  def the_results
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
  end
end
