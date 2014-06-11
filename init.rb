Redmine::Plugin.register :redmine_statistics do
  name 'Redmine Issue Statistics'
  author 'Ilkka Koutonen'
  description 'This plugin shows issue statistics from Redmine projects'
  version '0.0.5'

menu :project_menu, :stats, { :controller => 'stats', :action => 'index' }, :caption => 'Statistics', :after => :activity, :param => :project_id

project_module :stats do
    permission :view_stats, :stats => :index
  end

end

