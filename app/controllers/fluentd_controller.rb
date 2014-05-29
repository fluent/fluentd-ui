class FluentdController < ApplicationController
  before_action :find_fluentd, only: [:edit, :update, :destroy]

  def index
    @fluentds = Fluentd.all
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
    redirect_to fluentd_index_path
  end

  def edit
  end

  def update
    # TODO: should restart if changed file path? or just do "dirty" flagged?
    @fluentd.update_attributes(fluentd_params)
    unless @fluentd.save
      return render :edit
    end
    redirect_to fluentd_index_path
  end
  
  def destroy
    @fluentd.agent.stop if @fluentd.agent.running?
    @fluentd.destroy
    redirect_to fluentd_index_path
  end

  private

  def find_fluentd
    @fluentd = Fluentd.find(params[:id])
  end

  def fluentd_params
    params.require(:fluentd).permit(:log_file, :pid_file, :config_file, :variant, :api_endpoint)
  end
end
