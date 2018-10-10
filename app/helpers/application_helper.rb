# coding: utf-8

module ApplicationHelper
  def has_td_agent_system?
    File.exist?("/etc/init.d/td-agent") || File.exist?("/opt/td-agent/embedded/bin/fluentd")
  end

  def fluentd_ui_logo
    image_tag(ENV["FLUENTD_UI_LOGO"] || "/fluentd-logo-right-text.png")
  end

  def fluentd_status_icon
    return unless Fluentd.instance
    Fluentd.instance.agent.running? ? icon('fa-circle running') : icon('fa-circle stopped')
  end

  def fluentd_status_message
    return unless Fluentd.instance
    Fluentd.instance.agent.running? ? I18n.t('messages.fluentd_status_running') : I18n.t('messages.fluentd_status_stopped')
  end

  def language_name(locale)
    # NOTE: these are fixed terms, not i18n-ed
    {
      en: "English",
      ja: "日本語",
    }[locale] || locale
  end

  def link_to_other(text, path, **options)
    if current_page?(path)
      # NOTE: sb-admin set style for element name instead of class name, such as ".nav a". So use "a" element even if it isn't a link.
      content_tag(:a, text, class: "current")
    else
      link_to text, path, class: "nav-link"
    end
  end

  def icon(classes, inner=nil)
    %Q!<i class="fa #{classes}">#{inner}</i> !.html_safe
  end

  def page_title(title, &block)
    content_for(:page_title) do
      title
    end
    page_head(title, &block) unless content_for?(:page_head)
  end

  def page_head(head, &block)
    content_for(:page_head) do
      head.html_safe + block.try(:call).to_s
    end
  end

  def add_javascript_pack_tag(name, **options)
    content_for(:additional_javascript_pack_tag) do
      javascript_pack_tag(name, **options)
    end
  end
end
