module SettingsHelper
  def field(form, key, opts = {})
    html = '<div class="form-group">'
    html << h(form.label(key))
    html << " " # NOTE: Adding space for padding

    case form.object.column_type(key)
    when :boolean, :flag
      html << form.check_box(key, {}, "true", "false")
    when :choice
      html << form.select(key, form.object.values_of(key), opts)
    when :nested
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
      html << form.text_field(key)
    end

    html << "</div>"
    html.html_safe
  end
end
