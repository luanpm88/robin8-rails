module Crm
  module V1
    class NotesController < Crm::ApplicationController
      before_action :authenticate!

      def index
        @notes = Note.where(seller_id: current_seller.id, case_id: params[:case_id]).paginate(:page => params[:page])
        render json: { notes: @notes, error: 0 }
      end

      def create
        @note = Note.new(note_params.merge(seller_id: current_seller.id))
        if @note.save
          render json: { note: @note, error: 0 }
        else
          render json: { error: 1, message: '保存失败' }
        end
      end

      def update
        @note = Note.find_by params[:id]
        begin
          @note.update_attributes!(note_params)
          render json: { note: @note, error: 0 }
        rescue
          render json: { error: 1, message: '更新失败' }
        end
      end

      def show
        @note = current_seller.notes.find_by(params[:id])
        render json: { note: @note }
      end

      private

      def note_params
        params.permit(:title, :content, :case_id)
      end
    end
  end
end
