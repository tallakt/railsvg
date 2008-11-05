class IntTagsController < ApplicationController
  # GET /int_tags
  # GET /int_tags.xml
  def index
    @int_tags = IntTag.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @int_tags }
    end
  end

  # GET /int_tags/1
  # GET /int_tags/1.xml
  def show
    @int_tag = IntTag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @int_tag }
    end
  end

  # GET /int_tags/new
  # GET /int_tags/new.xml
  def new
    @int_tag = IntTag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @int_tag }
    end
  end

  # GET /int_tags/1/edit
  def edit
    @int_tag = IntTag.find(params[:id])
  end

  # POST /int_tags
  # POST /int_tags.xml
  def create
    @int_tag = IntTag.new(params[:int_tag])

    respond_to do |format|
      if @int_tag.save
        flash[:notice] = 'IntTag was successfully created.'
        format.html { redirect_to(@int_tag) }
        format.xml  { render :xml => @int_tag, :status => :created, :location => @int_tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @int_tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /int_tags/1
  # PUT /int_tags/1.xml
  def update
    @int_tag = IntTag.find(params[:id])

    respond_to do |format|
      if @int_tag.update_attributes(params[:int_tag])
        flash[:notice] = 'IntTag was successfully updated.'
        format.html { redirect_to(@int_tag) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @int_tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /int_tags/1
  # DELETE /int_tags/1.xml
  def destroy
    @int_tag = IntTag.find(params[:id])
    @int_tag.destroy

    respond_to do |format|
      format.html { redirect_to(int_tags_url) }
      format.xml  { head :ok }
    end
  end
end
