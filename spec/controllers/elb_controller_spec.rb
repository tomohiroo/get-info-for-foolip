require 'rails_helper'

RSpec.describe ElbController, type: :controller do

  describe "GET #health" do
    it "returns http success" do
      get :health
      expect(response).to have_http_status(:success)
    end
  end

end
