
class PagesController < ApplicationController
  helper_method :pages, :page
  respond_to :json, only: [:index, :create, :update, :destroy]
  respond_to :html, only: [:index]

  def index
    @pages = Page.where(display: true)
    respond_with @pages
    # @pages = Page.where(display: true)
    # @wikis = GollumRepo::Wiki.pages
  end


  def create
    page = Page.new(name: params[:title], title: params[:title], content: params[:content])
    page.save
    respond_with page
    # @page = Page.new(params[:page])
    # @page.name = params[:page][:title]
    # @page.display = true
    # if @page.save
    #   respond_to do |format|
    #     format.html { redirect_to(@page, notice: 'Page was successfully created.') }
    #   end
    # else
    #   render 'new'
    # end
  end

  def edit
    # @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
    # @page.update_attributes(params)
    # respond_with @page
    @edit = Page.new(name: @page[:name], title: params[:page][:title], content: params[:page][:content])
    @edit.document = @page
    @page.update_attributes(params[:page]) && @edit.save
    
    respond_with(@page) do |format|
      format.json { render json: @page }
    end


    # @page = Page.find(params[:id])
    # @edit = Page.new(name: @page[:name], title: params[:page][:title], content: params[:page][:content])
    # @edit.document = @page

    # if @page.update_attributes(params[:page]) && @edit.save
    #   redirect_to @page
    # else
    #   render 'edit'
    # end

  end

  def destroy
    @page = Page.find(params[:id])
    respond_with @page.archive
    # redirect_to pages_path
  end

  def new
    binding.pry
    @page = Page.new
  end

  private

  # def edit_params
    # params[:page].slice(:title)
  # end

end

