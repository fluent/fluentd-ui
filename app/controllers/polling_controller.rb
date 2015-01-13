class PollingController < ApplicationController
  def alerts
    alerts = []

    %w{ installing uninstalling }.each do |action|
      send("#{action}_gems").each do |plugin|
        target = plugin.gem_name.dup
        target << "(#{plugin.version})" if plugin.version
        alerts << {
          text: I18n.t("terms.#{action}", target: target)
        }
      end
    end

    render json: alerts
  end
end
