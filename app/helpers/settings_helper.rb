module SettingsHelper
  def field(form, key, opts = {})
    html = '<div class="form-group">'

    field_resolver(html, form, key, opts)

    html << "</div>"
    html.html_safe
  end

  private

  def field_resolver(html, form, key, opts)
    plugin_class = form.object.class
    type = plugin_class.column_type(key)
    if type && !@_used_param.key?(key)
      case type
      when :enum
        enum_field(html, form, key, opts)
      when :bool
        bool_field(html, form, key, opts)
      else
        other_field(html, form, key, opts)
      end
      @_used_param[key] = true
    end
    if plugin_class._sections[key] && !@_used_section.key?(key)
      section_field(html, form, key, opts)
      @_used_section[key] = true
    end
  end

  def section_field(html, form, key, opts = {})
    klass = form.object.class._sections[key]
    children = form.object.__send__(key) || { "0" => {} }
    # <parse>/<format> section is not multiple in most cases
    multi = if [:parse, :format].include?(key)
              false
            else
              klass.multi
            end

    children.each do |index, child|
      open_section_div(html, multi) do |_html|
        _html << append_and_remove_links if multi
        _html << h(form.label(key))
        _html << section_fields(form, key, index, klass, child)
      end
    end
  end

  def open_section_div(html, multi)
    html << %Q!<div class="js-nested-column #{ multi ? "js-multiple" : "" } well well-sm">!
    yield html
    html << "</div>"
  end

  def section_fields(form, key, index, klass, child)
    html = ""
    object = klass.new(child)
    form.fields_for("#{key}[#{index}]", object) do |ff|
      klass._types.keys.each do |kk|
        if kk == :type
          html << owned_plugin_type_field(ff, kk, key)
        else
          html << field(ff, kk)
        end
      end
    end
    html
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

  def enum_field(html, form, key, opts = {})
    html << h(form.label(key))
    html << " " # NOTE: Adding space for padding
    html << form.select(key, form.object.list_of(key), opts, { class: "enum" })
  end

  def bool_field(html, form, key, opts = {})
    html << form.check_box(key, {}, "true", "false")
    html << " " # NOTE: Adding space for padding
    html << h(form.label(key))
  end

  def other_field(html, form, key, opts = {})
    return unless form.object.respond_to?(key)
    html << h(form.label(key))
    html << form.text_field(key, class: "form-control")
  end

  def owned_plugin_type_field(form, key, plugin_type)
    registry_type = case plugin_type
                    when :parse
                      "PARSER_REGISTRY"
                    when :format
                      "FORMATTER_REGISTRY"
                    end
    plugin_registry = Fluent::Plugin.const_get("#{registry_type}")
    html = '<div class="form-group">'
    html << form.label(key)
    html << " " # NOTE: Adding space for padding
    html << form.select(key, plugin_registry.map.keys, {}, { class: "owned" })
    html << '</div>'
    html
  end
end
