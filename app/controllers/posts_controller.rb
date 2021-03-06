class PostsController < ApplicationController
  before_action :get_post, only: [:show, :edit, :update, :vote]
  before_action :require_user, except: [:index, :show]
  before_action :require_creator, only: [:edit, :update]
  
  def index
    @posts = Post.all.sort_by { |post| post.total_votes }.reverse

    respond_to do |format|
      format.html
      format.xml { render xml: @posts }
      format.json { render json: @posts }
    end
  end

  def show
    @comment = Comment.new

    respond_to do |format|
      format.html
      format.xml { render xml: @post }
      format.json { render json: @post }
    end
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.creator = current_user

    if @post.save
      flash[:notice] = "Your post was created!"
      redirect_to post_url(@post)
    else
      render :new
    end
  end

  def edit; end

  def update
    if @post.update(post_params)
      flash[:notice] = "Your post was updated!"
      redirect_to post_url(@post)
    else
      render :edit
    end
  end

  def vote
    @vote = @post.votes.create(creator: current_user, vote: params[:vote])

    respond_to do |format|
      format.html do
        if @vote.valid?    
          flash[:notice] = "Your vote was counted."
        else
          flash[:error] = "You can only vote once on #{@post.title}."
        end
        redirect_to :back
      end
      format.js
    end
  end
  
  private

  def post_params
    params.require(:post).permit(:title, :url, :description, category_ids: [])
  end

  def get_post
    @post = Post.find_by(slug: params[:id])
  end

  def require_creator
    unless logged_in? && (current_user == @post.creator || admin?)
      access_denied
    end
  end

end
