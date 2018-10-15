# encoding: utf-8

class V1::BoardsController < ApplicationController

  before_action :set_board,  only: [:destroy, :update]
  before_action :authorize_with_board_id,  only: [:destroy, :update]
  before_action :authorize_with_user_id,  only: :create

  def index
    boards = Board.get_boards board_params[:user_id]
    render json: boards
  end

  def show
    render json: Board
      .includes(clips: [:clip_categories, { restaurant: [:restaurant_pictures, :category, :station] }])
      .find(board_params[:id]).merge_clips
  end

  def create
    board = Board.new board_params
    board.save!
    render json: board
  end

  def update
    @board.update_attribute :name, board_params[:name]
    render json: @board
  end

  def destroy
    @board.destroy!
    render json: @board
  end

  private

    def board_params
      params.permit(:id, :name, :user_id)
    end

    def set_board
      @board = Board.find board_params[:id]
    end

    def authorize_with_board_id
      wrong_user_error unless @board.user == current_user
    end

    def authorize_with_user_id
      wrong_user_error unless  User.find(board_params[:user_id]) == current_user
    end

    def wrong_user_error
      render json: { error: 'このボードを編集する権限がありません。' }, status: 401
    end

end
