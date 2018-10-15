class V1::RestaurantsController < ApplicationController

  def index
    result = Restaurant.search restaurant_params
    if result == 400
      response_bad_request
    elsif result == 429
      response_quota_exceeded
    else
      render json: result
    end
  end

  def distance
    user_ll = [location_params[:lat], location_params[:lng]]
    render json: Restaurant.find(params[:id]).distance_to(user_ll)
  end

   private

     def restaurant_params
       params.permit(:ll, :query, :limit, :radius, :categoryId)
     end

     def location_params
       params.permit(:lat, :lng)
     end

end
