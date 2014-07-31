class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user
  helper_method :current_locale
  helper_method :installing_gem?, :installing_gems, :uninstalling_gem?, :uninstalling_gems
  helper_method :fluentd_ui_title, :fluentd_ui_brand, :fluentd_run_user
  helper_method :file_tail
  helper_method :fluentd_exists?
  before_action :login_required
  before_action :set_locale
  before_action :notice_new_fluentd_ui_available

  private

  def current_user
    return unless session[:succeed_password]
    @current_user ||= User.new(name: "admin").try(:authenticate, session[:succeed_password])
  end

  def login_required
    return true if current_user
    if request.xhr?
      render nothing: true, status: 401
    else
      redirect_to new_sessions_path
    end
  end

  def current_locale
    I18n.locale
  end

  def fluentd_ui_title
    ENV["FLUENTD_UI_TITLE"] || "Fluentd UI"
  end

  def fluentd_ui_brand
    ENV["FLUENTD_UI_BRAND"] || "fluentd"
  end

  def fluentd_run_user
    Fluentd.instance.td_agent? ? "td-agent" : ENV["USER"]
  end

  def installing_gem?
    installing_gems.present?
  end

  def installing_gems
    Plugin.installing
  end

  def uninstalling_gem?
    uninstalling_gems.present?
  end

  def uninstalling_gems
    Plugin.uninstalling
  end

  def fluentd_exists?
    !!Fluentd.instance
  end

  def notice_new_fluentd_ui_available
    if FluentdUI.update_available?
      flash[:info] = I18n.t("messages.available_new_fluentd_ui", version: FluentdUI.latest_version, update_url: misc_information_path, title: fluentd_ui_title)
    end
  end

  def find_fluentd
    @fluentd = Fluentd.instance
  end

  def set_locale
    available = I18n.available_locales.map(&:to_s)
    if params[:lang] && available.include?(params[:lang])
      session[:prefer_lang] = params[:lang]
      I18n.locale = params[:lang]
      return
    end
    if session[:prefer_lang]
      I18n.locale = session[:prefer_lang]
      return
    end

    # NOTE: ignoring q=xxx in request header for now
    return if request.env["HTTP_ACCEPT_LANGUAGE"].blank?
    langs = request.env["HTTP_ACCEPT_LANGUAGE"].gsub(/q=[0-9.]+/, "").gsub(";","").split(",")
    prefer = langs.find {|lang| available.include?(lang) }
    unless prefer
      if langs.find{|lang| lang.match(/^en/)}
        I18n.locale = :en
        return
      end
    end
    I18n.locale = prefer
  end

  def file_tail(path, limit = 10)
    return unless path
    return unless File.exists? path
    reader = FileReverseReader.new(File.open(path))
    return if reader.binary_file?
    reader.tail(limit)
  end
end
