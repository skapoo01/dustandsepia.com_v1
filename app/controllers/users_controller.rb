class UsersController < ApplicationController

	def new
   	 	@user = User.new
  	end
  
  	def create
    		@user = User.new(user_params)
    		if @user.save
      			redirect_to root_url, :notice => "A new user has been created!"
    		else
      			render "new"
    		end
  	end

  	private
	# Use callbacks to share common setup or constraints between actions.
	def set_user
	@user = Post.find(user[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def user_params
	params.fetch(:user, {}).permit(:name, :username, :admin)
	end
end
