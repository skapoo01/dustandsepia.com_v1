module PagesHelper

	def current_class(section_id)
	  	if params[:prev_tab].to_i == section_id
	  		return "active item"
	  	else
	  		return "item"
	  	end
  	end

end