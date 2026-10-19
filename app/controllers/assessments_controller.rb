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
    response.headers["Content-Type"] = "text/csv"
    response.headers["Content-Disposition"] = "attachment; filename=#{export_filename}"

    self.response_body = Enumerator.new do |y|
      y << CSV.generate_line(%w[id created_at status responses_json])

      assessments.find_each do |assessment|
        row = [
          assessment.id,
          assessment.created_at.iso8601,
          assessment.status,
          assessment.redacted_responses_json
        ]

        y << CSV.generate_line(row)
      end
    end
  end

  private

  def assessments
    @_assessments ||= begin
      query = Assessment.where(company_id: current_admin.company_id, **status_filter)

      if from_date_filter.present? && to_date_filter.present? && from_date_filter <= to_date_filter
        query = query.where("created_at >= ?", from_date_filter)
        query = query.where("created_at <= ?", to_date_filter)
      elsif from_date_filter.present?
        query = query.where("created_at >= ?", from_date_filter)
      elsif to_date_filter.present?
        query = query.where("created_at <= ?", to_date_filter)
      end

      query
    end
  end

  def export_filename
    "assessments_export-#{Date.current}.csv"
  end

  def status_filter
    status = filter_params[:status]&.to_sym
    return {} unless status.present? && Assessment::VALID_STATUSES.include?(status)

    { status: status }
  end

  def from_date_filter
    Date.parse(filter_params[:from]) rescue nil
  end

  def to_date_filter
    Date.parse(filter_params[:to]).end_of_day rescue nil
  end

  def filter_params
    params.permit(:status, :from, :to)
  end
end
