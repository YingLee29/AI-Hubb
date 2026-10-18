require 'csv'

class KeysController < ApplicationController
  PER_PAGE = 10

  def index
    @keys = Key.where(prompt: Prompt.find_by(public_uid: params[:id])).order(created_at: :desc).page(params[:page]).per(PER_PAGE)
  end

  def create
    @key = Key.new key_params.merge(user: current_user.presence, key_string: Key.generate_key)
    @keys = Key.where(prompt_id: @key.prompt_id).order(created_at: :desc).page(params[:page]).per(PER_PAGE)
    if @key.save
      flash.now[:success] = 'Create API key successfully!'
    end
  end

  def destroy
    key = Key.find_by!(public_uid: params[:id])
    key.destroy
    @keys = Key.where(prompt_id: key.prompt_id).order(created_at: :desc).page(params[:page]).per(PER_PAGE)
    flash.now[:success] = 'Delete API key successfully!'
  end

  def download
    key = Key.find_by!(public_uid: params[:id])
    return if key.used

    key.update(used: true)
    csv_data = CSV.generate do |csv|
      csv << ['API key', 'Purpose', 'Created by', 'Created at', 'Valid Until']
      csv << [key.key_string, key.note, key.user&.name, key.created_at, key.valid_until]
    end
    send_data csv_data, type: 'text/csv; charset=utf-8; header=present', disposition: 'attachment; filename=api_key.csv'
  end

  private

  def key_params
    params.require(:key).permit(:valid_until, :note, :prompt_id)
  end
end
