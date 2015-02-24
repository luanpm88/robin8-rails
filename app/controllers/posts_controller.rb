class PostsController < ApplicationController

  def index
    render json: current_user.posts.todays.order('scheduled_date desc'), each_serializer: PostSerializer
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
    if @post.update_attributes(post_params)
      render json: @post
    else
      render json: {}
    end
  end

  def show
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:text, :scheduled_date, :shrinked_links, social_networks: [:twitter, :facebook, :linkedin, :google])
  end

end
