class ScheduledMessagesController < ApplicationController
  # GET /scheduled_messages
  # GET /scheduled_messages.xml
  def index
    @scheduled_messages = ScheduledMessage.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scheduled_messages }
    end
  end

  # GET /scheduled_messages/1
  # GET /scheduled_messages/1.xml
  def show
    @scheduled_message = ScheduledMessage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scheduled_message }
    end
  end

  # GET /scheduled_messages/new
  # GET /scheduled_messages/new.xml
  def new
    @scheduled_message = ScheduledMessage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scheduled_message }
    end
  end

  # GET /scheduled_messages/1/edit
  def edit
    @scheduled_message = ScheduledMessage.find(params[:id])
  end

  # POST /scheduled_messages
  # POST /scheduled_messages.xml
  def create
    @scheduled_message = ScheduledMessage.new(params[:scheduled_message])

    respond_to do |format|
      if @scheduled_message.save
        flash[:notice] = 'ScheduledMessage was successfully created.'
        format.html { redirect_to(@scheduled_message) }
        format.xml  { render :xml => @scheduled_message, :status => :created, :location => @scheduled_message }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scheduled_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scheduled_messages/1
  # PUT /scheduled_messages/1.xml
  def update
    @scheduled_message = ScheduledMessage.find(params[:id])

    respond_to do |format|
      if @scheduled_message.update_attributes(params[:scheduled_message])
        flash[:notice] = 'ScheduledMessage was successfully updated.'
        format.html { redirect_to(@scheduled_message) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scheduled_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scheduled_messages/1
  # DELETE /scheduled_messages/1.xml
  def destroy
    @scheduled_message = ScheduledMessage.find(params[:id])
    @scheduled_message.destroy

    respond_to do |format|
      format.html { redirect_to(scheduled_messages_url) }
      format.xml  { head :ok }
    end
  end
end
