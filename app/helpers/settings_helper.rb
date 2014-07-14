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
    else
      html << form.text_field(key)
    end

    html << "</div>"
    html.html_safe
  end
end
