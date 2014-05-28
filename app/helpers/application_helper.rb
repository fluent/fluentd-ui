module ApplicationHelper
  def need_restart?
    Plugin.gemfile_changed?
  end

  def installing_gem?
    installing_gems.length > 0
  end

  def installing_gems
    Plugin::WORKING.find_all do |data|
      data[:type] == :install && data[:state] == :running
    end.map{|data| data[:plugin]} || []
  end

  def uninstalling_gem?
    uninstalling_gems.length > 0
  end

  def uninstalling_gems
    Plugin::WORKING.find_all do |data|
      data[:type] == :uninstall && data[:state] == :running
    end.map{|data| data[:plugin]} || []
  end

  def has_td_agent_system?
    File.exist?("/etc/init.d/td-agent")
  end

  def has_alert?
    installing_gem? || uninstalling_gem?
  end

  def alert_line(icon_class, text)
    %Q|<li><a><div>#{icon icon_class} <span>#{text}</span></div></a></li>|.html_safe
  end

  def link_to_other(text, path)
    if current_page?(path)
      # NOTE: sb-admin set style for element name instead of class name, such as ".nav a". So use "a" element even if it isn't a link.
      content_tag(:a, text, class: "current")
    else
      link_to text, path
    end
  end

  def icon(classes, inner=nil)
    %Q!<i class="fa #{classes}">#{inner}</i> !.html_safe
  end

  def page_title(title)
    content_for(:page_title) { title }
    page_head(title) unless content_for?(:page_head)
  end

  def page_head(head)
    content_for(:page_head) { head }
  end
end
