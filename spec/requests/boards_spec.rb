# encoding: utf-8

require 'rails_helper'

RSpec.describe "Boards", type: :request do
  before do
    @clip = FactoryBot.create :clip, :clip_1
    @board = FactoryBot.create :board, :board_1
    @clip_category = ClipCategory.create clip: @clip, board: @board
    @user = @board.user
    @headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer #{@user.access_token}"
    }
  end

  describe "GET /v1/boards" do
    it "自分は見れる" do
      get v1_boards_path, params: {user_id: @user.id}, headers: @headers
      expect(response).to be_successful
    end

    it "他人も見れる" do
      other_clip = FactoryBot.create :clip, :clip_2
      ClipCategory.create clip: other_clip, board: FactoryBot.create(:board, :board_2)
      get v1_boards_path, params: {user_id: other_clip.user.id}, headers: @headers
      expect(response).to be_successful
    end

    it "ヘッダーがないと見れない" do
      get v1_boards_path, params: {user_id: @user.id}
      expect(response).to have_http_status 401
    end
  end

  describe "GET /v1/boards/:id" do
    it "自分は見れる" do
      get v1_board_path(@board.id), params: {user_id: @user.id}, headers: @headers
      expect(response).to be_successful
    end

    it "他人も見れる" do
      other_board = FactoryBot.create :board, :board_2
      ClipCategory.create clip: FactoryBot.create(:clip, :clip_2), board: other_board
      get v1_board_path(other_board.id), params: {user_id: other_board.user.id}, headers: @headers
      expect(response).to be_successful
    end

    it "ヘッダーがないと見れない" do
      get v1_board_path(@board.id), params: {user_id: @user.id}
      expect(response).to have_http_status 401
    end
  end

  describe "POST /v1/clips" do

    it "本人はボードを作れる" do
      body = {
        user_id: @user.id,
        name: 'ボードの名前'
      }.to_json
      expect do
        post(v1_boards_path,
          params: body,
          headers: @headers
        )
      end.to change(@user.boards, :count).by(1)
      expect(response).to have_http_status 200
    end

    it "他人はボードを作れない" do
      @other_user = FactoryBot.create :other_user
      body = {
        user_id: @other_user.id,
        name: '他人のボード'
      }.to_json
      post(v1_boards_path,
        params: body,
        headers: @headers
      )
      expect(response).to have_http_status 401
    end

    it "ヘッダーがないとクリップできない" do
      body = {
        user_id: @user.id,
        name: 'ヘッダーなし'
      }.to_json
      post(v1_boards_path,
        params: body
      )
      expect(response).to have_http_status 401
    end
  end

  describe "PATCH /v1/boards/:id" do
    it "本人は編集できる" do
      body = {
        name: '名前変更'
      }.to_json
      patch(v1_board_path(@board.id),
        params: body,
        headers: @headers
      )
      expect(response).to have_http_status 200
    end

    it "他人には編集できない" do
      @other_board = FactoryBot.create :board, :board_2
      body = {
        name: '他人のボードは作れない'
      }.to_json
      patch(v1_board_path(@other_board.id),
        params: body,
        headers: @headers
      )
      expect(response).to have_http_status 401
    end

    it "ヘッダーがないと編集できない" do
      body = {
        name: 'ヘッダーなし'
      }.to_json
      patch(v1_board_path(@board.id),
        params: body
      )
      expect(response).to have_http_status 401
    end
  end

  describe "DELETE /v1/boards/:id" do
    it "本人は削除できる" do
      expect do
        delete(v1_board_path(@board.id),
          headers: @headers
        )
      end.to change(@user.boards, :count).by(-1)
      expect(response).to have_http_status 200
    end

    it "他人には削除できない" do
      @other_board = FactoryBot.create :board, :board_2
      expect do
        delete(v1_board_path(@other_board.id),
          headers: @headers
        )
      end.to change(@user.boards, :count).by(0)
      expect(response).to have_http_status 401
    end

    it "ヘッダーがないと削除できない" do
      expect do
        delete(v1_board_path(@board.id))
      end.to change(@user.boards, :count).by(0)
      expect(response).to have_http_status 401
    end
  end

end
