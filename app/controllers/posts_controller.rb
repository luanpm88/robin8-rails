class PostsController < ApplicationController

  def index
    @posts = current_user.posts
    render json: @posts.todays.order('scheduled_date desc'), each_serializer: PostSerializer
  end

  def tomorrows
    @posts = current_user.posts
    render json: @posts.tomorrows.order('scheduled_date desc'), each_serializer: PostSerializer
  end

  def others
    @posts = current_user.posts
    render json: @posts.others.order('scheduled_date asc'), each_serializer: PostSerializer
  end

  def new
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      render json: @post
    else
      render nothing: true
    end
  end

  def destroy
    @posts = Post.find(params[:id])
    @posts.destroy
    render nothing: true
  end
  
  def edit
  end

  def update
    @post = Post.find params[:id]
    params[:post][:twitter_ids] = [] if params[:post][:twitter_ids].blank?
    params[:post][:facebook_ids] = [] if params[:post][:facebook_ids].blank?
    params[:post][:linkedin_ids] = [] if params[:post][:linkedin_ids].blank?

    if @post.update_attributes(post_params)
      render json: @post
    else
      render json: {}
    end
  end

  def update_social
    @post = Post.find params[:id]
    if @post.update_attributes(social_networks: post_params[:social_networks])
      render json: @post
    else
      render json: {}
    end
  end

  def show
    @post = Post.find params[:id]
    render json: @post
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:text, :scheduled_date, :shrinked_links, facebook_ids:[], linkedin_ids:[], twitter_ids:[])
  end

end
