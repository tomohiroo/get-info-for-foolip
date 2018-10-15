# encoding: utf-8

require 'rails_helper'

RSpec.describe "Clips", type: :request do
  before do
    @clip = FactoryBot.create :clip, :clip_1
    @user = @clip.user
    @headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer #{@user.access_token}"
    }
  end

  describe "GET /v1/clips" do
    it "自分は見れる" do
      get v1_clips_path, params: {user_id: @user.id}, headers: @headers
      expect(response).to be_successful
    end

    it "他人も見れる" do
      @other_clip = FactoryBot.create :clip, :clip_2
      get v1_clips_path, params: {user_id: @other_clip.user.id}, headers: @headers
      expect(response).to be_successful
    end

    it "ヘッダーがないと見れない" do
      get v1_clips_path, params: {user_id: @user.id}
      expect(response).to have_http_status 401
    end
  end

  describe "GET /v1/clips/:id" do
    it "自分は見れる" do
      get v1_clip_path(@clip.id), headers: @headers
      expect(response).to be_successful
    end

    it "他人も見れる" do
      @other_clip = FactoryBot.create :clip, :clip_2
      get v1_clip_path(@other_clip.id), headers: @headers
      expect(response).to be_successful
    end

    it "ヘッダーがないと見れない" do
      get v1_clip_path(@clip.id)
      expect(response).to have_http_status 401
    end
  end

  describe "POST /v1/clips" do
    before do
      @restaurant = FactoryBot.create :restaurant_2
    end

    it "本人はクリップできるが、一度クリップした店をクリップしようとするとエラーになる" do
      body = {
        user_id: @user.id,
        memo: "memo",
        rating: 5,
        has_visit: false,
        foursquare_id:  @restaurant.foursquare_id
      }.to_json
      expect do
        post(v1_clips_path,
          params: body,
          headers: @headers
        )
      end.to change(@user.clips, :count).by(1)
      expect(response).to have_http_status 200

      expect do
        post(v1_clips_path,
          params: body,
          headers: @headers
        )
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "他人はクリップできない" do
      @other_user = FactoryBot.create :other_user
      body = {
        user_id: @other_user.id,
        memo: "他人はクリップできない",
        rating: 5,
        has_visit: false,
        foursquare_id:  @restaurant.foursquare_id
      }.to_json
      post(v1_clips_path,
        params: body,
        headers: @headers
      )
      expect(response).to have_http_status 401
    end

    it "ヘッダーがないとクリップできない" do
      body = {
        user_id: @user.id,
        memo: "memo",
        rating: 5,
        has_visit: false,
        foursquare_id:  @restaurant.foursquare_id
      }.to_json
      post(v1_clips_path,
        params: body
      )
      expect(response).to have_http_status 401
    end
  end

  describe "PATCH /v1/clips/:id" do
    it "本人は編集できる" do
      body = {
        memo: "メモを変更",
        rating: 5,
        has_visit: true,
      }.to_json
      patch(v1_clip_path(@clip.id),
        params: body,
        headers: @headers
      )
      expect(response).to have_http_status 200
    end

    it "他人には編集できない" do
      @other_clip = FactoryBot.create :clip, :clip_2
      body = {
        memo: "メモを変更",
        rating: 5,
        has_visit: true,
      }.to_json
      patch(v1_clip_path(@other_clip.id),
        params: body,
        headers: @headers
      )
      expect(response).to have_http_status 401
    end

    it "ヘッダーがないと編集できない" do
      body = {
        memo: "メモを変更",
        rating: 5,
        has_visit: true,
      }.to_json
      patch(v1_clip_path(@clip.id),
        params: body
      )
      expect(response).to have_http_status 401
    end
  end

  describe "DELETE /v1/clips/:id" do
    it "本人は削除できる" do
      expect do
        delete(v1_clip_path(@clip.id),
          headers: @headers
        )
      end.to change(@user.clips, :count).by(-1)
      expect(response).to have_http_status 200
    end

    it "他人には削除できない" do
      @other_clip = FactoryBot.create :clip, :clip_2
      expect do
        delete(v1_clip_path(@other_clip.id),
          headers: @headers
        )
      end.to change(@user.clips, :count).by(0)
      expect(response).to have_http_status 401
    end

    it "ヘッダーがないと削除できない" do
      expect do
        delete(v1_clip_path(@clip.id))
      end.to change(@user.clips, :count).by(0)
      expect(response).to have_http_status 401
    end
  end

end
