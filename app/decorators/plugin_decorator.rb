class PluginDecorator < Draper::Decorator
  delegate_all

  def status
    if installed?
      I18n.t("terms.installed")
    elsif processing?
      I18n.t("terms.processing")
    else
      I18n.t("terms.not_installed")
    end
  end
end
