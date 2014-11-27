class ApplicationController < ActionController::Base
  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_host
  before_filter :mailer_set_url_options

  def zz(opts = nil)
    Rails.logger.info "--- #{opts.inspect}"
  end

  def check_ajax
    return true if request.xhr?
    render text: "This request should be used only through Ajax.", status: :bad_request
    false
  end

  def on_hold
    @configuration ||= ::Configuration.instance
    #return redirect_to(front_home_path) unless @configuration.website_on_hold
    #@body_classes << "on-hold"
    render layout: "front", template: "front/base/on_hold"
  end

  def resend_confirmation_instructions
    return head(:bad_request) unless request.xhr? || params.blank?
    p = params[:nomodel] || params
    model = p[:resource_name].constantize
    model.find_for_authentication(email: p[:email]).send_confirmation_instructions
    render text: 'ok'
  end

  def send_reset_password_instructions
    return head(:bad_request) unless request.xhr? || params.blank?
    p = params[:nomodel] || params
    model = p[:resource_name].constantize
    model.find_for_authentication(email: p[:email]).send_reset_password_instructions
    render text: 'ok'
  end

private
  def check_host
    return true unless on_production_site?
    if Figaro.env.site_tld != request.host
      return redirect_to("http://#{Figaro.env.site_tld}#{request.path}", status: 301)
    end
    true
  end

  def check_on_hold_status
    return true unless on_production_site?
    @configuration ||= ::Configuration.instance
    on_hold_page_requested = "front/base" == params[:controller].to_s && "on_hold" == params[:action].to_s
    if @configuration.website_on_hold?
      if current_admin
        if false
          if "front/products" == params[:controller] && "show" == params[:action] #TODO
            return true
          else
            if (p = Product.active.first)
              return redirect_to(front_product_path(id: p))
            end
            return redirect_to(on_hold_path) unless on_hold_page_requested
          end
        else
          # flash[:warning] = "Attention #{current_admin.first_name}, le site est actuellement fermé au public." # DEV NOTE: too tired by this!
          return redirect_to(front_home_path) if on_hold_page_requested
        end
      else
        return redirect_to(on_hold_path) unless on_hold_page_requested
      end
    elsif on_hold_page_requested
      return redirect_to(front_home_path)
    end
  end

  def detect_locale
    # 1. Check HTTP language prefs header (usually set by browser)
    langs = request.headers['Accept-Language'].to_s.split(',').map { |pref|
      code, ratio = pref.split(/\s*;\s*q\s*=\s*/, 2).map(&:strip)
      ratio = 1 if ratio.blank?
      # We ignore wildcards and strip country-code variants for now, focusing on generic languages.
      '*' == code || code.blank? ? nil : [code.split('-').first.to_sym, ratio.to_f]
    }.compact.sort_by(&:last).reverse.map(&:first).uniq
    loc = (langs & I18n.available_locales).first

    # 2. If locale isn't available or blank, revert to default locale (as per app config)
    loc.blank? || !I18n.available_locales.include?(loc.to_sym) ? I18n.default_locale.to_s : loc.to_s
  end

  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  def set_locale(with_redirect = false)
    loc = params[:locale].to_s
    cookie_loc = session[:desired_locale].to_s
    if loc.present? && I18n.available_locales.include?(loc.to_sym)
      I18n.locale = loc.to_sym
      session[:desired_locale] = loc if loc != cookie_loc
    else
      requested_loc = cookie_loc.present? && I18n.available_locales.include?(cookie_loc.to_sym) ? cookie_loc : detect_locale
      I18n.locale = requested_loc.to_sym
      params[:locale] = requested_loc
      if with_redirect && request.get?
        return redirect_to(current_url(params.except(*request.path_parameters.keys)))
      end
    end
    true
  end
end
