module ApplicationHelper
  def need_restart?
    Plugin.gemfile_changed?
  end

  def installing_gem?
    GemInstaller::WORKING.present?
  end

  def link_to_other(text, path)
    if current_page?(path)
      content_tag(:strong, text)
    else
      link_to text, path
    end
  end
end
