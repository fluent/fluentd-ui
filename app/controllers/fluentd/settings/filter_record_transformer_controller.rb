class Fluentd::Settings::FilterRecordTransformerController < ApplicationController
  include SettingConcern

  private

  def target_class
    Fluentd::Setting::FilterRecordTransformer
  end

  def setting_params
    permit_params = target_class.permit_params + [:record]
    params.require(:setting).permit(*permit_params)
  end
end
