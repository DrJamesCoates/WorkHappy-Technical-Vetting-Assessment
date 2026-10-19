require "csv"

class AssessmentsController < ApplicationController
  before_action :require_admin
  before_action :validate_export_filters, only: :export

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
    parse_date(filter_params[:from])
  end

  def to_date_filter
    parse_date(filter_params[:to])&.end_of_day
  end

  def parse_date(value)
    Date.parse(value) rescue nil
  end

  def validate_export_filters
    status, from, to = filter_params.values_at(:status, :from, :to)
    errors = []

    if status.present? && !Assessment::VALID_STATUSES.map(&:to_s).include?(status)
      errors << "Status must be one of: #{Assessment::VALID_STATUSES.join(', ')}"
    end

    errors << "From date is not a valid date" if from.present? && parse_date(from).nil?
    errors << "To date is not a valid date" if to.present? && parse_date(to).nil?

    if from.present? && to.present? && parse_date(from) && parse_date(to) && parse_date(from) > parse_date(to)
      errors << "From date must be on or before To date"
    end

    render json: { errors: errors }, status: :unprocessable_entity if errors.any?
  end

  def filter_params
    params.permit(:status, :from, :to)
  end
end
