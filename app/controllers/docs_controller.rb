class DocsController < ApplicationController

  before_filter :authenticate_user!, :except => ['show', 'home']
  before_filter :verify_admin, :only => ['new', 'edit', 'update', 'create', 'destroy']

  layout 'admin', :only => ['new', 'edit', 'update', 'create']


  #before_filter :get_tags
  #before_filter :set_docs, :only => 'show'
  #after_filter :view_causes_vote, :only => 'show'


  # GET /docs/1
  # GET /docs/1.xml
  def show
    @doc = Doc.where(id: params[:id]).active.first

    unless @doc.nil?
      @meta_description = @doc.meta_description
      @keywords = @doc.keywords

      @page_title = @doc.title.titleize
      @custom_title = @doc.title_tag.blank? ? @page_title : @doc.title_tag.titleize
      @title_tag = "#{Settings.site_name}: #{@custom_title}"

      add_breadcrumb t(:knowledgebase, default: "Knowledgebase"), categories_path
      add_breadcrumb @doc.category.name.titleize, category_path(@doc.category) if @doc.category.name
      add_breadcrumb @doc.title.titleize


      respond_to do |format|
        format.html # show.html.erb
      end

    else
      redirect_to root_url
    end

  end

  # GET /docs/new
  # GET /docs/new.xml
  def new
    @doc = Doc.new
    @doc.category_id = params[:category_id]

    @post = Post.where(id: params[:post_id]).first if current_user.admin == true
    @categories = Category.alpha

    respond_to do |format|
      format.html

    end
  end

  # GET /docs/1/edit
  def edit
    @doc = Doc.find(params[:id])
    @category = Category.where(id: params[:category_id]).first
    @categories = Category.alpha
  end

  # POST /docs
  # POST /docs.xml
  def create
    @doc = Doc.new(doc_params)
    @doc.user_id = current_user.id

    respond_to do |format|
      if @doc.save

        #@doc.tag_list = params[:tags]
        #@doc.save
        format.html { redirect_to(admin_articles_path(@doc.category.id)) }

      else
        format.html { render :action => "new" }

      end
    end
  end

  # PUT /docs/1
  # PUT /docs/1.xml
  def update

    unless params['lang'].nil?
      I18n.locale = params['lang']
    end

    @doc = Doc.where(id: params[:id]).first

    respond_to do |format|
      if @doc.update_attributes(doc_params)
        format.html { redirect_to(admin_articles_path(@doc.category.id)) }

      else
        format.html { render :action => "edit", :id => @doc }
      end
    end
  end

  # DELETE /docs/1
  # DELETE /docs/1.xml
  def destroy
    @doc = Doc.find(params[:id])
    @doc.destroy

    respond_to do |format|
      format.js { render js:"$('#doc-#{@doc.id}').fadeOut();

      Helpy.ready();
      Helpy.track();" }

    end
  end

  def set_docs
    if params[:permalink]
      @doc = Doc.find_by_permalink(params[:permalink])
    else
      category = Category.find_by_link(params[:link])
      @doc = Doc.find_by_category_id(params[:link])
    end
    @related = Doc.in_category(@doc.category_id)
  end

  def home
    render(:layout => 'discussion')
  end

  protected


  #def get_tags
  #  @tags = Doc.tag_counts
  #end

  def view_causes_vote
    if user_signed_in?
      @doc.votes.create unless current_user.admin?
    else
      @doc.votes.create
    end
  end

  private

  def doc_params
    params.require(:doc).permit(:title, :body, :keywords, :title_tag, :meta_description, :category_id, :rank, :active, :front_page, :user_id, {screenshots: []})
  end

end
