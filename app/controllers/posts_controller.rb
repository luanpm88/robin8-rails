class PostsController < ApplicationController

  def index
    @posts = current_user.posts#.todays
  end

  def new
  end

  def create
    if current_user.posts.create(post_params)
      render json: {}
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
      render json: {}
    else
      render json: {}
    end
  end

  def show
  end

  def set_post
    @post = Question.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:text, :scheduled_date, social_networks: [:twitter, :facebook, :linkedin, :google])
  end

end
