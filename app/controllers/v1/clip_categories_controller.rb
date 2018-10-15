# encoding: utf-8

class V1::ClipCategoriesController < ApplicationController

  before_action :correct_user

  def create
    clip_category = ClipCategory.new clip_category_params
    clip_category.save!
    render json: clip_category
  end

  def destroy
    clip_category = ClipCategory.find_by! board_id: clip_category_params[:board_id], clip_id: clip_category_params[:clip_id]
    clip_category.destroy!
    render json: clip_category
  end

  private

    def clip_category_params
      params.permit(:id, :board_id, :clip_id)
    end

    def correct_user
      params = clip_category_params
      board_user = Board.find(params[:board_id]).user
      clip_user = Clip.find(params[:clip_id]).user
      wrong_user_error unless current_user == board_user && board_user == clip_user
    end

    def wrong_user_error
      render json: { error: 'このクリップボードを編集する権限がありません。' }, status: 401
    end

end
