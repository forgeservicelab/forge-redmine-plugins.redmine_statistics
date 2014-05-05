Redmine::Plugin.register :redmine_statistics do
  name 'Statistics for FORGE Support project'
  author 'Ilkka Koutonen'
  description 'This plugin shows issue statistics from FORGE Support project'
  version '0.0.3'

menu :project_menu, :stats, { :controller => 'redmine_statistics', :action => 'index' }, :caption => 'Statistics', :after => :activity, :param => :project_id

project_module :stats do
    permission :view_stats, :stats => :index
  end

end

