class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, :except => [:show]
  helper_method :sort_column, :sort_direction
  
  # GET /posts
  # GET /posts.json
  def index
    @sections = Section.all

    if current_user.admin?
      if filter_field.nil?
        @posts = Post.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
      else
        if filter_field == "section_id"
          @posts = Post.search(params[:search]).where(section_id: filter_value.to_i).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page]).paginate(:per_page => 15, :page => params[:page])
        elsif filter_field == "author"
          @posts = Post.search(params[:search]).where(user_id: filter_value.to_i).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
        elsif filter_field == "series_id"
          @posts = Post.search(params[:search]).where(series_id: filter_value.to_i).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
        end     
      end
      @users = User.all.order("id")
    else
      if filter_field.nil?
        @posts = Post.search(params[:search]).where(user_id: current_user.id).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
      else
        if filter_field == "section_id"
          @posts = Post.search(params[:search]).where(user_id: current_user.id).where(section_id: filter_value.to_i).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
        elsif filter_field == "author"
          @posts = Post.search(params[:search]).where(user_id: current_user.id).where(user_id: filter_value.to_i).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
        elsif filter_field == "series_id"
          @posts = Post.search(params[:search]).where(user_id: current_user.id).where(series_id: filter_value.to_i).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
        end     
      end
    end
    
    #@posts = Post.all
    session.delete(:post_params)                    # In case back is pressed
    session.delete(:post_step)                      # remove sessions variables for post form
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])
    session.delete(:post_params)                    # In case back is pressed FUNCTION??
    session.delete(:post_step)                      # remove sessions variables for post form
  end

  # GET /posts/new
  def new
    session[:post_params] ||= {}
    @post = Post.new
    @post.first_step!                               # since create derives current step from the session
    session[:post_step] = @post.current_step        # session must store step.first in new
    #session[:post_step] = @post.steps.first # words if attr_accessor has steps, SECURITY RISK
  end

  # GET /posts/1/edit
  def edit
    if !(current_user.admin? || @post.user_id == current_user.id)
      redirect_to posts_path, alert: 'Access denied'
    end
    session[:post_params] = {}
    @post.first_step!                               
    session[:post_step] = @post.current_step
    
  end

  # POST /posts
  # POST /posts.json
  # PROBLEM #1: Cookie overflow
  # Solution #1: remove image from session[:post_param] by stroing it in an intermediate 
  #              variable and reattaching it to @post BUT HOW???
  # Solution #2: replace cookies with ActiveRecordStorage BUT MAJOR SECURITY RISK IS 
  #              a million people try to save images in ActiveRecordStorage at the same 
  #              time
  #
  # PROBLEM #2: Image cannot be stored in session_store
  # Solution #1: remove image from post_params before deep_merging with sessions, and then
  #              reattach to @post using a temp variable
  #
  # PROBLEM #3: Once image is cleaved, ruby debugger loses formatting but it does show
  #             temp variable holding image HOW TO FIX THIS??????
  #
  def create
    session[:post_params].deep_merge!(post_params.except(:cover_image)) if post_params
    tmp_img = post_params[:cover_image]
    @post = Post.new(session[:post_params])
    @sections = Section.all         # NECESSARRY BECAUSE session may hold
    @post.cover_image = tmp_img                     # data from prior steps
    @post.current_step = session[:post_step]
    
    if @post.valid?
      if params[:previous_button]
        @post.previous_step
      elsif @post.last_step? 
        @post.user_id = current_user.id ################################################
        @post.save if @post.all_elems_valid?
      else
        @post.next_step
      end
      session[:post_step] = @post.current_step
    end

    if @post.new_record?
      render 'new'
    else
      redirect_to @post, notice: 'Post was successfully created'
    end 

    # WHAT IS ALL THIS JUNK??
    %#respond_to do |format|
      
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end #

  end 

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update

    if !(current_user.admin? || @post.user_id == current_user.id)
      redirect_to posts_path, alert: 'Access denied'
    end

    session[:post_params].deep_merge!(post_params.except(:cover_image))
    img_before_update = true
    if @post.cover_image_file_size.nil?
      img_before_update = false
      tmp_img = post_params[:cover_image]
    else
      tmp_img = @post.cover_image
    end
    @post.hash_to_post(session[:post_params])
    @post.cover_image = tmp_img 
    @post.current_step = session[:post_step]
    @sections = Section.all

    if @post.valid?
      if params[:previous_button]
        @post.previous_step
      elsif @post.last_step?
        @post.user_id = current_user.id 
        @post.update(post_params) if @post.all_elems_valid?
      else
        @post.next_step
      end
    end

    session[:post_step] = @post.current_step

    if @post.updated_at_changed? != nil           # WHY IS updated_at_changed? RETURNING FALSE
      redirect_to @post, notice: 'Post was successfully updated'
    else
      render 'edit' 
    end
    %#
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end #
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy

    if !(current_user.admin? || @post.user_id == current_user.id)
        redirect_to posts_path, alert: 'You cannot delete articles that do not belong to you'
    end

    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def delete_image

    if !(current_user.admin? || @post.user_id == current_user.id)
      redirect_to posts_path, alert: 'Access denied'
    end

    @post = Post.find(params[:id])
    @post.cover_image.destroy
    @post.save
    #@post.save

    #redirect_to :back, notice: 'HERE'
    @post.current_step = session[:post_step]
    render 'edit'
  end

  def action


    if !params[:post_ids].nil?
      params[:post_ids].each do |id|
        post = Post.find(id.to_i)

        if params[:delete_selected]
            post.destroy
        elsif params[:publish_selected]
            post.publish = true
        elsif params[:hide_selected]
            post.publish = false
        elsif params[:enable_comments_for_selected]
            post.commenting = true
        elsif params[:disable_comments_for_selected]
            post.commenting = false
        end

        post.save
      end
    end

    redirect_to posts_path
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
        @post = Post.find(params[:id]) 
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.fetch(:post, {}).permit(:title, :body, :composed_on, :summary, :author, :cover_image, :section_id, :publish, :commenting)
    end

    def sort_column
      Post.column_names.include?(params[:sort]) ? params[:sort] : "composed_on"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "desc"
    end

    def filter_field
      Post.column_names.include?(params[:filter_by]) ? params[:filter_by] : nil
    end

    def filter_value 
      params[:value]
    end

end

__END__

put deletion of sessions variables in update and save instead of index