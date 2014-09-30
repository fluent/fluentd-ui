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
end
