class PluginDecorator < Draper::Decorator
  delegate_all

  def status
    if processing?
      I18n.t("terms.processing")
    elsif installed?
      I18n.t("terms.installed")
    else
      I18n.t("terms.not_installed")
    end
  end

  def to_hash
    {
      is_installed: installed?,
      is_processing: processing?,
      uninstall_button: "#plugin-modal-#{gem_name}",
      name: gem_name,
      authors: authors,
      summary: summary,
      api_version: api_version,
      category: category,
      status: status,
      installed_version: installed_version,
      latest_version: latest_version,
      is_latest_version: latest_version?,
      rubygems_org_page: rubygems_org_page
    }
  end
end
