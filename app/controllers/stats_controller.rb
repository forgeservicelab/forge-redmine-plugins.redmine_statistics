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

    # Retrieves time stats for closed issues via custom SQL queries
    adapter_type = Issue.connection.adapter_name.downcase.to_sym
    case adapter_type
      when :postgresql
        Issue.connection.execute("SET intervalstyle TO postgres_verbose")
        @min_closure = Issue.connection.select_all("SELECT JUSTIFY_HOURS(MIN(issues.updated_on - issues.created_on)) AS duration FROM issues INNER JOIN projects ON projects.id = issues.project_id WHERE issues.status_id = 5 AND issues.updated_on != issues.created_on AND issues.subject != 'Welcome to FORGE Service Lab!' AND projects.identifier = '#{params[:project_id]}'").to_a
        @max_closure = Issue.connection.select_all("SELECT JUSTIFY_HOURS(MAX(issues.updated_on - issues.created_on)) AS duration FROM issues INNER JOIN projects ON projects.id = issues.project_id WHERE issues.status_id = 5 AND issues.updated_on != issues.created_on AND issues.subject != 'Welcome to FORGE Service Lab!' AND projects.identifier = '#{params[:project_id]}'").to_a
        @avg_closure = Issue.connection.select_all("SELECT JUSTIFY_HOURS(AVG(issues.updated_on - issues.created_on)) AS duration FROM issues INNER JOIN projects ON projects.id = issues.project_id WHERE issues.status_id = 5 AND issues.updated_on != issues.created_on AND issues.subject != 'Welcome to FORGE Service Lab!' AND projects.identifier = '#{params[:project_id]}'").to_a
      when :mysql || :mysql2
        @min_closure = Issue.connection.select_all("SELECT TIME_FORMAT(SEC_TO_TIME(MIN(TIME_TO_SEC(TIMEDIFF(issues.updated_on,issues.created_on)))), '%H hours %i minutes %S seconds' ) AS duration FROM issues INNER JOIN projects ON projects.id = issues.project_id WHERE issues.status_id = 5 AND issues.updated_on != issues.created_on AND projects.identifier = '#{params[:project_id]}' AND issues.subject != 'Welcome to FORGE Service Lab!'").to_a
        @max_closure = Issue.connection.select_all("SELECT TIME_FORMAT(SEC_TO_TIME(MAX(TIME_TO_SEC(TIMEDIFF(issues.updated_on,issues.created_on)))), '%H hours %i minutes %S seconds' ) AS duration FROM issues INNER JOIN projects ON projects.id = issues.project_id WHERE issues.status_id = 5 AND issues.updated_on != issues.created_on AND projects.identifier = '#{params[:project_id]}' AND issues.subject != 'Welcome to FORGE Service Lab!'").to_a
        @avg_closure = Issue.connection.select_all("SELECT TIME_FORMAT(SEC_TO_TIME(AVG(TIME_TO_SEC(TIMEDIFF(issues.updated_on,issues.created_on)))), '%H hours %i minutes %S seconds' ) AS duration FROM issues INNER JOIN projects ON projects.id = issues.project_id WHERE issues.status_id = 5 AND issues.updated_on != issues.created_on AND projects.identifier = '#{params[:project_id]}' AND issues.subject != 'Welcome to FORGE Service Lab!'").to_a
    else
      raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
    end

  end

  private

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end
end
