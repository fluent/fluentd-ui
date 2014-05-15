module ApplicationHelper
  def need_restart?
    Plugin.gemfile_changed?
  end
end
