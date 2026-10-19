require "csv"

class AssessmentsController < ApplicationController
  before_action :require_admin

  def index
    logger.info "Dashboard params: #{params.inspect}"
    @assessments = Assessment.where(company_id: current_admin.company_id)
    @assessments = @assessments.where(status: params[:status]) if params[:status].present?
    @assessments = @assessments.where("created_at >= ?", Date.parse(params[:from])) if params[:from].present?
    @assessments = @assessments.where("created_at <= ?", Date.parse(params[:to])) if params[:to].present?
    @assessments = @assessments.order(created_at: :desc).to_a
    @assessments.each { |a| logger.info "Assessment loaded: #{a.attributes}" }
  end

  def export
    logger.info "Export params: #{params.inspect}"
    # Legacy: company_id comes straight from the request and is never checked
    # against the logged-in admin.
    assessments = Assessment.where(company_id: params[:company_id])
    csv = CSV.generate do |out|
      out << %w[id company_id employee_id employee_email status responses_json created_at]
      assessments.each do |a|
        out << [a.id, a.company_id, a.employee_id, a.employee_email, a.status, a.responses_json.to_json, a.created_at]
      end
    end
    send_data csv, filename: "assessments.csv", type: "text/csv"
  end
end
