# encoding: utf-8

require 'rails_helper'

RSpec.describe "ClipCategories", type: :request do
  before do
    @clip = FactoryBot.create :clip, :clip_1
    @user = @clip.user
    @board = FactoryBot.build :board, :board_1
    @board.user = @user
    @board.save
    @headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer #{@user.access_token}"
    }
  end

  describe "POST /v1/clip_categories" do
    describe "POST /v1/clips" do

      it "本人はボードにピンできる" do
        body = {
          board_id: @board.id,
          clip_id: @clip.id
        }.to_json
        expect do
          post(v1_clip_categories_path,
            params: body,
            headers: @headers
          )
        end.to change(@user.boards[0].clips, :count).by(1)
        expect(response).to have_http_status 200
      end

      it "他人はピンできない" do
        other_user = FactoryBot.create :other_user
        body = {
          board_id: @board.id,
          clip_id: @clip.id
        }.to_json
        post(v1_clip_categories_path,
          params: body,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer #{other_user.access_token}"
          }
        )
        expect(response).to have_http_status 401
      end

      it "ヘッダーがないとピンできない" do
        body = {
          board_id: @board.id,
          clip_id: @clip.id
        }.to_json
        post(v1_clip_categories_path,
          params: body
        )
        expect(response).to have_http_status 401
      end
    end
  end

  describe "DELETE /v1/clip_categores/:id" do
    before do
      @clip_category = ClipCategory.create clip: @clip, board: @board
    end

    it "本人はピンから外せる" do
      body = {
        board_id: @board.id,
        clip_id: @clip.id
      }.to_json
      expect do
        delete(v1_clip_category_path("delete"),
          headers: @headers,
          params: body
        )
      end.to change(@user.boards[0].clips, :count).by(-1)
      expect(response).to have_http_status 200
    end

    it "他人には削除できない" do
      other_user = FactoryBot.create :other_user
      body = {
        board_id: @board.id,
        clip_id: @clip.id
      }.to_json
      expect do
        delete(v1_clip_category_path("delete"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer #{other_user.access_token}"
          },
          params: body
        )
      end.to change(@user.boards[0].clips, :count).by(0)
      expect(response).to have_http_status 401
    end

    it "ヘッダーがないと削除できない" do
      body = {
        board_id: @board.id,
        clip_id: @clip.id
      }.to_json
      expect do
        delete(v1_clip_category_path("delete"),
        params: body
      )
      end.to change(@user.boards[0].clips, :count).by(0)
      expect(response).to have_http_status 401
    end

  end
end
