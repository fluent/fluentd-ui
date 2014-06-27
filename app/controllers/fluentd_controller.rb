class FluentdController < ApplicationController
  before_action :find_fluentd, only: [:show, :edit, :update, :destroy, :log]
  before_action :check_fluentd_exists, only: [:edit, :log]

  def show
  end

  def new
    @fluentd = Fluentd.new(variant: params[:variant] || "fluentd")
    @fluentd.load_settings_from_agent_default
  end

  def create
    @fluentd = Fluentd.new(fluentd_params)
    unless @fluentd.save
      return render :new
    end
    redirect_to root_path
  end

  def edit
  end

  def update
    # TODO: should restart if changed file path? or just do "dirty" flagged?
    @fluentd.update_attributes(fluentd_params)
    unless @fluentd.save
      return render :edit
    end
    redirect_to root_path
  end
  
  def destroy
    @fluentd.agent.stop if @fluentd.agent.running?
    @fluentd.destroy
    redirect_to root_path
  end

  def log
  end

  def raw_log
    render text: @fluentd.agent.log, content_type: "text/plain"
  end

  private

  def find_fluentd
    @fluentd = Fluentd.factory
  end

  def fluentd_params
    params.require(:fluentd).permit(:log_file, :pid_file, :config_file, :variant, :api_endpoint)
  end

  def check_fluentd_exists
    unless find_fluentd
      redirect_to root_path
    end
  end
end
