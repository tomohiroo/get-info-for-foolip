# encoding: utf-8

class V1::ClipsController < ApplicationController

  before_action :set_clip,  only: [:destroy, :update]
  before_action :authorize_with_clip_id,  only: [:destroy, :update]
  before_action :authorize_with_user_id,  only: [:create, :share]

  def index
    clips = Clip.search params[:user_id]
    render json: clips
  end

  def show
    render json: Clip.find(params[:id]).merge_restaurant
  end

  def create
    params = clip_params
    render json: Clip.create!(
      memo: params[:memo],
      rating: params[:rating],
      has_visit: params[:has_visit],
      user_id: params[:user_id],
      restaurant: Restaurant.find_by(foursquare_id: params[:foursquare_id])
    )
  end

  def update
    @clip.update_attributes! clip_params
    render json: @clip
  end

  def destroy
    @clip.destroy!
    render json: @clip
  end

  def share
    ll, name = Scraping.send "get_info_from_#{clip_params[:source]}", clip_params[:url]
    restaurant = Restaurant.search(
      ll: ll,
      query: name,
      radius: 50,
      limit: 1,
      categoryId: "4d4b7105d754a06374d81259,4bf58dd8d48988d116941735"
    )[0]
    return response_not_found if restaurant.blank?
    return response_quota_exceeded if restaurant =~ /^[0-9]+$/
    restaurant = Restaurant.find_by(foursquare_id: restaurant["foursquare_id"])
    if clip = Clip.find_by(restaurant: restaurant, user_id: clip_params[:user_id])
      clip.update! memo: clip_params[:memo]
    else
      clip = Clip.create! restaurant: restaurant, user_id: clip_params[:user_id], memo: clip_params[:memo]
    end
    clip.create_boards_and_clip_categories clip_params[:user_id], clip_params[:board_ids], clip_params[:new_board_names]
    render json: restaurant
  end

   private

     def clip_params
       params.permit(:id, :memo, :rating, :has_visit, :user_id, :restaurant_id, :foursquare_id, :url, :source, board_ids: [], new_board_names: [])
     end

     def set_clip
       @clip = Clip.find clip_params[:id]
     end

     def authorize_with_clip_id
       wrong_user_error unless @clip.user == current_user
     end

     def authorize_with_user_id
       wrong_user_error unless clip_params[:user_id].to_i == current_user.id
     end

     def wrong_user_error
       render json: { error: 'このクリップを編集する権限がありません。' }, status: 401
     end

end
