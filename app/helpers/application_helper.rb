module ApplicationHelper
  def need_restart?
    Plugin.gemfile_changed?
  end

  def installing_gem?
    installing_gems.length > 0
  end

  def installing_gems
    GemInstaller::WORKING || []
  end

  def uninstalling_gem?
    uninstalling_gems.length > 0
  end

  def uninstalling_gems
    GemUninstaller::WORKING || []
  end

  def has_alert?
    installing_gem? || uninstalling_gem?
  end

  def alerts
    alerts = []
    if installing_gem?
      #GemInstaller::WORKING.each do |plugin|
      Plugin.installed.each do |plugin|
        # TODO: i18n
        alerts << alert_line("fa-spinner fa-spin", "Installing #{plugin.gem_name} (#{plugin.version})")
      end
    end
      Plugin.installed.each do |plugin|
        # TODO: i18n
        alerts << alert_line("fa-spinner fa-spin", "Installing #{plugin.gem_name} (#{plugin.version})")
      end
    alerts
  end

  def alert_line(icon_class, text)
    %Q|<li><a><div>#{icon icon_class} <span>#{text}</span></div></a></li>|.html_safe
  end

  def link_to_other(text, path)
    if current_page?(path)
      content_tag(:strong, text)
    else
      link_to text, path
    end
  end

  def icon(classes, inner=nil)
    %Q!<i class="fa #{classes}">#{inner}</i>!.html_safe
  end

  def page_title(title)
    content_for(:page_title) { title }
    page_head(title) unless content_for?(:page_head)
  end

  def page_head(head)
    content_for(:page_head) { head }
  end
end
