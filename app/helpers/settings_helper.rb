module SettingsHelper
  def field(form, key, opts = {})
    html = '<div class="form-group">'

    case form.object.column_type(key)
    when :hidden
      return form.hidden_field(key)
    when :boolean, :flag
      html << form.check_box(key, {}, "true", "false")
      html << " " # NOTE: Adding space for padding
      html << h(form.label(key))
    when :choice
      html << h(form.label(key))
      html << " " # NOTE: Adding space for padding
      html << form.select(key, form.object.values_of(key), opts)
    when :nested
      child_data = form.object.class.children[key]
      klass = child_data[:class]
      options = child_data[:options]
      children = form.object.send(key) || {"0" => {}}
      children.each_pair do |index, child|
        html << %Q!<div class="js-nested-column #{options[:multiple] ? "js-multiple" : ""} well well-sm">!
        if options[:multiple]
          html << %Q!<a class="btn btn-xs btn-default js-append">#{icon('fa-plus')}</a> !
          html << %Q!<a class="btn btn-xs btn-default js-remove" style="display:none">#{icon('fa-minus')}</a> !
        end
        html << h(form.label(key))
        form.fields_for("#{key}[#{index}]", klass.new(child)) do |ff|
          klass::KEYS.each do |k|
            html << field(ff, k)
          end
        end
        html << "</div>"
      end
    else
      html << h(form.label(key))
      html << form.text_field(key, class: "form-control")
    end

    html << "</div>"
    html.html_safe
  end
end
