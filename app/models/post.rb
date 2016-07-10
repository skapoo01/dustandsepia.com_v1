class Post < ActiveRecord::Base
	has_attached_file :cover_image, styles: {medium: "300x300>", thumb: "100x100>"} #default_url: "/images/:style/missing.png"
	validates_attachment_content_type :cover_image, content_type: /\Aimage\/.*\Z/
	attr_writer :current_step #, :step # for security and remembering step on first 'Next >>'
	validates_presence_of :title, :author, :composed_on, :body, :if => :public_step? 
	validates_presence_of :summary, :if => :private_step?

  belongs_to :users

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

  	def public_step?
  		current_step == "public_form_elems"
  	end

  	def private_step?
  		current_step == "private_form_elems"
  	end

  	def all_elems_valid?
  		steps.all? do |step|
  			self.current_step = step
  			valid?
  		end
  	end

  	def hash_to_post(h)
  		h.each { |k, v| public_send("#{k}=", v)}
  	end

end
  # what does attr_accessible do?

  %#__END__

  put image sizes as percent not absolute sizes

  #