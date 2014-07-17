module SettingsHelper
  def field(form, key, opts = {})
    html = '<div class="form-group">'

    case form.object.column_type(key)
    when :boolean, :flag
      html << form.check_box(key, {}, "true", "false")
      html << " " # NOTE: Adding space for padding
      html << h(form.label(key))
    when :choice
      html << h(form.label(key))
      html << " " # NOTE: Adding space for padding
      html << form.select(key, form.object.values_of(key), opts)
    when :nested
      html << h(form.label(key))
      child_data = form.object.class.children[key]
      klass = child_data[:class]
      children = form.object.send(key) || {"0" => {}}
      children.each_pair do |index, child|
        # TODO: allow append/delete for multiple child
        form.fields_for("#{key}[#{index}]", klass.new(child), class: "nested-column #{child_data[:multiple] ? "multiple" : ""} well well-sm") do |ff|
          klass::KEYS.each do |k|
            html << field(ff, k)
          end
        end
      end
    else
      html << h(form.label(key))
      html << form.text_field(key, class: "form-control")
    end

    html << "</div>"
    html.html_safe
  end
end
