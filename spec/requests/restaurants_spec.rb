# encoding: utf-8

require 'rails_helper'

RSpec.describe "Restaurants", type: :request do

  before do
    @user = FactoryBot.create :user
    @headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer #{@user.access_token}"
    }
  end

  describe "GET /v1/restaurants" do
    context "when there is authorization headers" do
      it "responds successfully" do
        get v1_restaurants_path, params: { near: '銀座', query: 'イタリアン',
           limit: '1', radius: 1000, categoryId: '4d4b7105d754a06374d81259' },
           headers: @headers
        expect(response).to be_successful
      end
    end

    context "when there isn't authorization headers" do
      it "responds unsuccessfully" do
        get v1_restaurants_path, params: { near: '渋谷', query: 'ラーメン',
          limit: '1', radius: 1000, categoryId: '4d4b7105d754a06374d81259' }
        expect(response).to have_http_status 401
      end
    end
  end

end
