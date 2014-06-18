class Fluentd::SettingsController < ApplicationController
  before_action :login_required
  before_action :find_fluentd

  def show
    @config = File.read(@fluentd.agent.config_file) # TODO
  end

  def edit
    @config = File.read(@fluentd.agent.config_file) # TODO
  end

  def  update
    File.open(@fluentd.agent.config_file, "w") do |f| # TODO: should update by agent class
      f.write params[:config]
    end
    @fluentd.agent.restart if @fluentd.agent.running?
    redirect_to fluentd_setting_path(@fluentd)
  end

  def in_tail_after_file_choose
    @setting = Fluentd::Setting::InTail.new({
      :path => params[:path],
      :tag => nil,
    })
  end

  def in_tail_after_format
    @setting = Fluentd::Setting::InTail.new(setting_params)
  end

  def in_tail_confirm
    @setting = Fluentd::Setting::InTail.new(setting_params)
    if params[:back]
      return render :in_tail_after_file_choose
    end
  end

  def in_tail_finish
    @setting = Fluentd::Setting::InTail.new(setting_params)
    if params[:back]
      return render :in_tail_after_format
    end

    unless @setting.valid?
      return render "in_tail_after_format"
    end

    if @fluentd.agent.configuration.to_s.include?(@setting.to_conf.strip)
      @setting.errors.add(:base, :duplicated_conf)
      return render "in_tail_after_format"
    end

    File.open(@fluentd.agent.config_file, "a") do |f| # TODO: should update by agent class
      f.write "\n"
      f.write @setting.to_conf
    end
    @fluentd.agent.restart if @fluentd.agent.running?
    redirect_to fluentd_setting_path(@fluentd)
  end

  private

  def setting_params
    {
      :pos_file => "/tmp/fluentd-#{@fluentd.id}-#{Time.now.to_i}.pos",
    }.merge params.require(:setting).permit(:path, :format, *Fluentd::Setting::InTail.known_formats, :tag, :rotate_wait, :pos_file, :read_from_head, :refresh_interval)
  end
end
