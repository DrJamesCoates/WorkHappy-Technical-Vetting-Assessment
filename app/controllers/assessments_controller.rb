require "csv"

class AssessmentsController < ApplicationController
  PER_PAGE_OPTIONS = [ 25, 50, 100, 200 ].freeze

  before_action :require_admin

  def index
    @assessments = Assessment.where(company_id: current_admin.company_id)
    @assessments = @assessments.where(status: params[:status]) if params[:status].present?
    @assessments = @assessments.where("created_at >= ?", Date.parse(params[:from])) if params[:from].present?
    @assessments = @assessments.where("created_at <= ?", Date.parse(params[:to])) if params[:to].present?
    @assessments = @assessments.includes(:employee).order(created_at: :desc).paginate(page: [params[:page].to_i, 1].max, per_page: per_page)
  end

  def export
    assessments = Assessment.where(company_id: params[:company_id])
    csv = CSV.generate do |out|
      out << %w[id company_id employee_id employee_email status responses_json created_at]
      assessments.each do |a|
        out << [a.id, a.company_id, a.employee_id, a.employee_email, a.status, a.responses_json.to_json, a.created_at]
      end
    end
    send_data csv, filename: "assessments.csv", type: "text/csv"
  end

  private

  def per_page_options
    PER_PAGE_OPTIONS
  end
  helper_method :per_page_options

  def per_page
    requested = params[:per_page].to_i
    PER_PAGE_OPTIONS.include?(requested) ? requested : PER_PAGE_OPTIONS.second
  end
end
