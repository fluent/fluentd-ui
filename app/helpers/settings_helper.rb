module SettingsHelper
  def field(form, key, opts = {})
    html = '<div class="form-group">'

    field_resolver(form.object.column_type(key), html, form, key, opts)

    html << "</div>"
    html.html_safe
  end

  private
  def field_resolver(type, html, form, key, opts)
    case type
    when :hidden
      html << form.hidden_field(key)
    when :boolean, :flag
      boolean_field(html, form, key, opts)
    when :choice
      choice_field(html, form, key, opts)
    when :nested
      nested_field(html, form, key, opts)
    else
      other_field(html, form, key, opts)
    end
  end

  def nested_field(html, form, key, opts = {})
    klass    = child_data(form, key)[:class]
    options  = child_data(form, key)[:options]
    children = form.object.send(key) || {"0" => {}}

    children.each_pair do |index, child|
      html << open_nested_div(options[:multiple])
      html << append_and_remove_links if options[:multiple]
      html << h(form.label(key))
      html << nested_fields(form, key, index, klass, child)
      html << "</div>"
    end
  end

  def open_nested_div(multiple)
    %Q!<div class="js-nested-column #{ multiple ? "js-multiple" : "" } well well-sm">!
  end

  def nested_fields(form, key, index, klass, child)
    nested_html = ""
    form.fields_for("#{key}[#{index}]", klass.new(child)) do |ff|
      klass::KEYS.each do |k|
        nested_html << field(ff, k)
      end
    end

    nested_html
  end

  def append_and_remove_links
    %Q!<a class="btn btn-xs btn-default js-append">#{icon('fa-plus')}</a> ! +
    %Q!<a class="btn btn-xs btn-default js-remove" style="display:none">#{icon('fa-minus')}</a> !
  end

  def child_data(form, key)
    form.object.class.children[key]
  end

  def choice_field(html, form, key, opts = {})
    html << h(form.label(key))
    html << " " # NOTE: Adding space for padding
    html << form.select(key, form.object.values_of(key), opts)
  end

  def boolean_field(html, form, key, opts = {})
    html << form.check_box(key, {}, "true", "false")
    html << " " # NOTE: Adding space for padding
    html << h(form.label(key))
  end

  def other_field(html, form, key, opts = {})
    html << h(form.label(key))
    html << form.text_field(key, class: "form-control")
  end
end
