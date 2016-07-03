class Post < ActiveRecord::Base
	has_attached_file :cover_image, styles: {medium: "300x300>", thumb: "100x100>"} #default_url: "/images/:style/missing.png"
	validates_attachment_content_type :cover_image, content_type: /\Aimage\/.*\Z/
	attr_writer :current_step #, :step # for security and remembering step on first 'Next >>'
	validates_presence_of :title, :author, :composed_on, :body, :if => lambda {|p| p.current_step == "public_form_elems"} 
	validates_presence_of :cover_image, :summary, :if => lambda {|p| p.current_step == "private_form_elems"} 

	def current_step
    		#@post = Post.find(params[:id])
    		@current_step || steps.first
  	end

  	def steps
    		%w[public_form_elems private_form_elems]
  	end

  	def next_step
  		self.current_step = steps[steps.index(current_step)+1]
  	end

  	def previous_step
  		self.current_step = steps[steps.index(current_step)-1]
  	end

  	def first_step?
  		current_step == steps.first
  	end

  	def first_step!
  		current_step = steps.first
  	end

  	def last_step?
  		current_step == steps.last
  	end

end
  # what does attr_accessible do?