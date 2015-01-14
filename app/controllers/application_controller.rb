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
    return unless session[:password]
    @current_user ||= User.new(name: session[:user_name]).authenticate(session[:password])
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
    I18n.locale = locale_from_params || locale_from_session || locale_from_http_accept_lang || I18n.default_locale
  end

  def locale_from_params
    if params[:lang] && available_locales.include?(params[:lang])
      session[:prefer_lang] = params[:lang]
      params[:lang]
    else
      nil
    end
  end

  def locale_from_session
    session[:prefer_lang]
  end

  def locale_from_http_accept_lang
    # NOTE: ignoring q=xxx in request header for now
    return nil if request.env["HTTP_ACCEPT_LANGUAGE"].blank?

    langs = request.env["HTTP_ACCEPT_LANGUAGE"].gsub(/q=[0-9.]+/, "").gsub(";","").split(",")
    prefer = langs.find { |lang| available_locales.include?(lang) }

    unless prefer
      prefer = :en if langs.find{ |lang| lang.match(/^en/) }
    end

    prefer
  end

  def available_locales
    @available_locales ||= I18n.available_locales.map(&:to_s)
  end

  def file_tail(path, limit = 10)
    return [] unless path
    return [] unless File.exists? path
    reader = FileReverseReader.new(File.open(path))
    return [] if reader.binary_file?
    reader.tail(limit)
  end
end
