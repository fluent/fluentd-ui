class FluentdFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def field(key, options = {})
    plugin_class = object.class
    content_tag(:div, class: "form-group") do
      if plugin_class._sections[key]
        render_section(key, options)
      else
        resolve_field(key, options)
      end
    end
  end

  private

  def resolve_field(key, options = {})
    plugin_class = object.class
    column_type = plugin_class.column_type(key)
    case column_type
    when :enum
      enum_field(key, options)
    when :bool
      bool_field(key, options)
    else
      if key.to_sym == :log_level
        log_level_field(key, options)
      else
        other_field(key, options)
      end
    end
  end

  def enum_field(key, options)
    label(key, nil, data: { toggle: "tooltip", placement: "right" }, title: object.desc(key)) +
      select(key, object.list_of(key), options, { class: "enum" })
  end

  def bool_field(key, options)
    check_box(key, options, "true", "false") + " " +
      label(key, nil, data: { toggle: "tooltip", placement: "right" }, title: object.desc(key))
  end

  def other_field(key, options)
    return unless object.respond_to?(key)
    label(key, nil, data: { toggle: "tooltip", placement: "right" }, title: object.desc(key)) +
      text_field(key, class: "form-control", **options)
  end

  def log_level_field(key, options)
    return unless object.respond_to?(key)
    label(key, nil, data: { toggle: "tooltip", placement: "right" }, title: object.desc(key)) +
      select(key, Fluent::Log::LEVEL_TEXT, { include_blank: true }, { class: "form-control" })
  end

  def render_section(key, options)
    section_class = object.class._sections[key]
    children = object.__send__(key) || { "0" => {} }
    html = ""

    children.each do |index, child|
      html << content_tag("div", class: "js-nested-column #{section_class.multi ? "js-multiple" : ""}") do
        _html = ""
        _html << append_and_remove_links if section_class.multi
        _html << label(key, nil, data: { toggle: "tooltip", placement: "right" }, title: object.desc(key))
        _html << section_fields(key, index, section_class, child)
        _html.html_safe
      end
    end
    html.html_safe
  end

  def section_fields(key, index, section_class, child)
    section = section_class.new(child)
    fields("#{key}[#{index}]", model: section) do |section_form|
      html = ""
      section_class._types.keys.each do |section_key|
        html << section_form.field(section_key)
      end
      html.html_safe
    end
  end

  def append_and_remove_links
    %Q!<a class="btn btn-xs btn-default js-append">#{icon('fa-plus')}</a> ! +
    %Q!<a class="btn btn-xs btn-default js-remove" style="display:none">#{icon('fa-minus')}</a> !
  end

  def icon(classes, inner=nil)
    %Q!<i class="fa #{classes}">#{inner}</i> !.html_safe
  end
end
