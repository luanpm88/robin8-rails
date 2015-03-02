class MediaListsController < ApplicationController
  before_action :set_media_list, only: [:show, :edit, :update, :destroy]

  # GET /media_lists
  # GET /media_lists.json
  def index
    @media_lists = current_user.media_lists.all
    
    respond_to do |format|
      format.json
    end
  end

  # GET /media_lists/1
  # GET /media_lists/1.json
  def show
  end

  # POST /media_lists
  # POST /media_lists.json
  def create
    @media_list = current_user.media_lists.new(media_list_params)

    respond_to do |format|
      if @media_list.save
#        format.html { redirect_to @media_list, notice: 'Media list was successfully created.' }
        format.json { render :show, status: :created, location: @media_list }
      else
#        format.html { render :new }
        format.json { render json: @media_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /media_lists/1
  # DELETE /media_lists/1.json
  def destroy
    @media_list.destroy
    respond_to do |format|
#      format.html { redirect_to media_lists_url, notice: 'Media list was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_media_list
      @media_list = current_user.media_lists.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def media_list_params
      params.require(:media_list).permit(:name)
    end
end
