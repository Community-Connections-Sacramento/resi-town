class ReportsController < ApplicationController
  before_action :ensure_admin
  
  def index
    @report = SummaryReport.new
  end
end
