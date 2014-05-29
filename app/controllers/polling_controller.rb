class PollingController < ApplicationController
  def alerts
    alerts = []
    installing_gems.each do |plugin|
      target = plugin.gem_name.dup
      target << "(#{plugin.version})" if plugin.version
      alerts << {
        text: I18n.t('terms.installing', target: target)
      }
    end
    uninstalling_gems.each do |plugin|
      target = plugin.gem_name.dup
      target << "(#{plugin.version})" if plugin.version
      alerts << {
        text: I18n.t('terms.uninstalling', target: target)
      }
    end
    render json: alerts
  end
end
