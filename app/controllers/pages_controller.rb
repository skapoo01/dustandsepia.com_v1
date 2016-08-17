class PagesController < ApplicationController
	include PagesHelper

  def home
  	@posts = Post.all
  end

  def tabs
  	@posts = Post.where(:section_id => params[:tab].to_i)
    	@sections = Section.all
  end

  

end
