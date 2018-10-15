class V1::UsersController < ApplicationController

  skip_before_action :authenticate_user_from_token!

 def create
   @user = User.create!
   render json: @user, serializer: V1::SessionSerializer, root: nil
 end

end
