require 'zip'
class LogsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_permission_admin, only: %i[index]

  def index
    @keyword = params[:keyword]
    @all_projects = current_tenant.projects
    @all_logs = Log.by_project_id(@all_projects.ids)
    @start_date = params[:start_date]
    @end_date = params[:end_date]

    start_date = Time.zone.parse(params[:start_date]) if params[:start_date].present?
    end_date = Time.zone.parse(params[:end_date]) if params[:end_date].present?

    if start_date && end_date
      @log_range = @all_logs.where(created_at: start_date..end_date)
    elsif start_date
      @log_range = @all_logs.where(created_at: start_date..Time.zone.now)
    elsif end_date
      first_log = @all_logs.order(:created_at).first&.created_at
      @log_range = @all_logs.where(created_at: first_log..end_date)
    else
      @log_range = @all_logs.all
    end

    @search = @log_range.ransack(ip_or_user_agent_or_api_endpoint_or_api_body_or_ai_endpoint_or_ai_body_or_response_i_cont: @keyword)
    @logs = @search.result.order(created_at: :desc).page(params[:page]).per(10)
  end

  def download_log
    keyword = params[:keyword]
    start_date = params[:start_date]
    end_date = params[:end_date]
    prompt_id = params[:prompt_id]
    logs = valid_logs(prompt_id, keyword, start_date, end_date)
    respond_to do |format|
      format.zip do
        compressed_filestream = Zip::OutputStream.write_buffer(::StringIO.new('')) do |zos|
          zos.put_next_entry "log.csv"
          csv_data = CSV.generate do |csv|
            idx = 1
            csv << ["No", "Created at", "IP Address", "User Agent", "API Endpoint",
                    "API Body", "AI Endpoint", "AI Body", "Response"]
            logs.each do |log|
              csv << [idx, log.created_at.strftime('%m/%d/%Y %H:%M:%S'), log.ip, log.user_agent,
                      log.api_endpoint, log.api_body, log.ai_endpoint,
                      log.ai_body, log.response]
              idx += 1
            end
          end
          zos.print csv_data
        end
        compressed_filestream.rewind
        send_data compressed_filestream.read, filename: "log_history.zip"
      end
    end
  end

  def valid_logs(prompt_id, keyword, start_date, end_date)
    all_projects = current_tenant.projects
    all_logs = Log.by_project_id(all_projects.ids)
    prompt = Prompt.find_by(public_uid: prompt_id)
    valid_logs = prompt.present? ? all_logs.where(prompt_id: prompt&.id) : all_logs
    log_range = if start_date.present?
      if end_date.present?
        valid_logs.where(created_at: Time.zone.parse(start_date)..Time.zone.parse(end_date))
      else
        valid_logs.where(created_at: Time.zone.parse(start_date)..Time.zone.now)
      end
    else
      if end_date.present?
        first_log = valid_logs.first&.created_at
        valid_logs.where(created_at: first_log..Time.zone.parse(end_date))
      else
        valid_logs
      end
    end
    log_range.ransack(ip_or_user_agent_or_api_endpoint_or_api_body_or_ai_endpoint_or_ai_body_or_response_i_cont: keyword).result.order(created_at: :desc)
  end
end
