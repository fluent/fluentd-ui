class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user
  helper_method :current_locale
  before_action :login_required
  before_action :set_locale

  def current_user
    return unless session[:remember_token]
    @current_user ||= LoginToken.active.find_by(token_id: session[:remember_token]).try(:user)
  end

  def login_required
    return true if current_user
    redirect_to new_sessions_path
  end

  def current_locale
    I18n.locale
  end

  private

  def find_fluentd
    @fluentd = Fluentd.find(params[:fluentd_id])
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
end
