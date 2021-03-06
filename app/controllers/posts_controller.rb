class PostsController < ApplicationController

  before_filter :authenticate_user!, :except => ['index', 'create', 'up_vote']
  before_filter :verify_admin, :only => ['new', 'edit', 'update', 'destroy']
  before_filter :instantiate_tracker

#  before_filter :fetch_counts, :only => 'create'
  after_filter :send_message, :only => 'create'
#  after_filter :view_causes_vote, :only => 'index'

  layout "clean", only: [:index]


  def index
    @topic = Topic.undeleted.ispublic.where(id: params[:topic_id]).first#.includes(:forum)
    if @topic
      @posts = @topic.posts.ispublic.active.all.chronologic
      @post = @topic.posts.new

      #@related = Topic.ispublic.by_popularity.front.tagged_with(@topic.tag_list)

      @feed_link = "<link rel='alternate' type='application/rss+xml' title='RSS' href='#{topic_posts_url(@topic)}.rss' />"

      @page_title = "#{@topic.name.titleize}"
      @title_tag = "#{Settings.site_name}: #{@page_title}"
      add_breadcrumb t(:community, default: "Community"), forums_path
      add_breadcrumb @topic.forum.name.titleize, forum_topics_path(@topic.forum)
      add_breadcrumb @topic.name.titleize
    end

    respond_to do |format|
      if @topic
        format.html # index.rhtml
        format.xml  { render :xml => @posts.to_xml }
        format.rss  { render :layout => false}
      else
        format.html { redirect_to root_path}
      end
    end
  end

  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
    end
  end

  def new
    @topic = Topic.find(params[:topic_id], :include => :forum)
    @post = Post.new
    @forums = Forum.all
  end

  def edit
    @post = Post.where(id: params[:id]).first

    respond_to do |format|
      format.js
    end
  end

  def cancel
    @post = Post.where(id: params[:id]).first

    respond_to do |format|
      format.js
    end
  end

  def create
    @topic = Topic.find(params[:topic_id])
    @post = Post.new(:body => params[:post][:body],
                     :topic_id => @topic.id,
                     :user_id => current_user.id,
                     :kind => params[:post][:kind],
                     :screenshots => params[:post][:screenshots])

    respond_to do |format|
      if @post.save

        format.html {
          @posts = @topic.posts.ispublic.chronologic.active
          redirect_to topic_posts_path(@topic)
          }
        format.js {
          if current_user.admin?
            fetch_counts

            @posts = @topic.posts.chronologic
            @admins = User.admins
            #@post = Post.new
            case @post.kind
            when "reply"
              @tracker.event(category: "Agent: #{current_user.name}", action: "Agent Replied", label: @topic.to_param) #TODO: Need minutes
            when "note"
              @tracker.event(category: "Agent: #{current_user.name}", action: "Agent Posted Note", label: @topic.to_param) #TODO: Need minutes
            end
            render 'admin/ticket'

          else #current_user is a customer
            @posts = @topic.posts.ispublic.chronologic.active
            unless @topic.assigned_user_id.nil?
              agent = User.find(@topic.assigned_user_id)
              @tracker.event(category: "Agent: #{agent.name}", action: "User Replied", label: @topic.to_param) #TODO: Need minutes
            end
          end

        }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @post = Post.find(params[:id])
    @post.body = params[:post][:body]
    @post.active = params[:post][:active]

    respond_to do |format|
      if @post.save
        format.js
      end
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
       format.html { redirect_to topic_posts_path(@post.topic) }
    end
  end

  def up_vote

    if user_signed_in?
      @post = Post.find(params[:id])
      @post.votes.create(user_id: current_user.id)
      @topic = @post.topic
      @topic.touch
      @post.reload
    end

    respond_to do |format|
      format.js
    end

  end


  protected

  def send_message
    # TODO deliver/create a firstmessage to deliver on the initial post
    #Should only send when admin posts, not when user replies

    if current_user.admin?
      TopicMailer.new_ticket(@post.topic).deliver_now if @topic.private == true
    else
      logger.info("reply is not from admin, don't email")
    end
  end

  def view_causes_vote
    if logged_in?
      @topic.votes.create unless current_user.admin?
    else
      @topic.votes.create
    end
  end
end
