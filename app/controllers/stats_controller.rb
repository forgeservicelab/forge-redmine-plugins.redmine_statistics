class StatsController < ApplicationController
  unloadable

before_filter :find_project, :authorize, :only => :index

  def index

# Finds the project ID
@project = Project.find_by_identifier(params[:project_id])

# Time counts for Issue amounts
count_one = (Time.now - 1.day)..Time.now
count_seven = (Time.now - 7.day)..Time.now
count_fourteen = (Time.now - 14.day)..Time.now
count_thirty = (Time.now - 30.day)..Time.now

# Counts the Issue amounts over certain time periods
@total_count = Issue.joins(:project).where(projects: {identifier: params[:project_id]}).to_a
@one_day_count = Issue.joins(:project).where(projects: {identifier: params[:project_id]}).where('created_on' => count_one ).to_a
@seven_day_count = Issue.joins(:project).where(projects: {identifier: params[:project_id]}).where('created_on' => count_seven ).to_a
@fourteen_day_count = Issue.joins(:project).where(projects: {identifier: params[:project_id]}).where('created_on' => count_fourteen ).to_a
@thirty_day_count =Issue.joins(:project).where(projects: {identifier: params[:project_id]}).where('created_on' => count_thirty ).to_a

# Counts resolved and closed issues within the project
@closed_count = Issue.joins(:project).where(projects: {identifier: params[:project_id]}).where('status_id' => 5 ).to_a
@resolved_count = Issue.joins(:project).where(projects: {identifier: params[:project_id]}).where('status_id' => 3 ).to_a

@aika = Issue.joins(:project).where(projects: {identifier: params[:project_id]}).to_a

  end

private

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end
end
