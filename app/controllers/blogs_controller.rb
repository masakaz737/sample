class BlogsController < ApplicationController
  before_action :login_or_not, only: [:new, :show, :edit, :destroy]
  before_action :set_blog, only: [:show, :edit, :update, :destroy]

  def index
    @blogs = Blog.all
  end

  def new
    if params[:back]
      @blog = Blog.new(blog_params)
      @blog.image.retrieve_from_cache! params[:cache][:image]
    else
      @blog = Blog.new
    end
  end

  def create
    @blog = Blog.new(blog_params)
    @blog.user_id = current_user.id #現在ログインしているuserのidをblogのuser_idカラムに挿入する。
    @blog.image.retrieve_from_cache!  params[:cache][:image]

    if @blog.save
      @user = current_user
      CreateMailer.create_mail(@blog).deliver
      redirect_to blogs_path, notice: "ブログを作成しました！"
    else
      render 'new'
    end
  end

  def confirm
    @blog = Blog.new(blog_params)
    @blog.user_id = current_user.id #現在ログインしているuserのidをblogのuser_idカラムに挿入する。
    render :new if @blog.invalid?
  end

  def show
    @favorite = current_user.favorites.find_by(blog_id: @blog.id)
  end

  def edit
  end

  def update
    if @blog.update(blog_params)
      redirect_to blogs_path, notice: "ブログを編集しました！"
    else
      render 'edit'
    end
  end

  def destroy
    @blog.destroy
    redirect_to blogs_path, notice:"ブログを削除しました！"
  end

  private
  def blog_params
    params.require(:blog).permit(:title, :content, :image, :image_cache)
  end

  # idをキーとして値を取得するメソッド
  def set_blog
    @blog = Blog.find(params[:id])
  end

  def login_or_not
    if !current_user
      redirect_to new_session_path, notice:"ログインしてください"
    end
  end
end
