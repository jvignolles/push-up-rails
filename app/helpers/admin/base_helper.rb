module Admin::BaseHelper
  include ImagesHelper

  def custom_page_entries_info(collection)
    if collection.length <= 0
      I18n.t("will_paginate.page_entries_info.single_page.zero")
    elsif 1 == collection.length
      I18n.t("will_paginate.page_entries_info.single_page.one")
    else
      I18n.t("will_paginate.page_entries_info.single_page.other", { count: collection.length })
    end
  end

  def delete_link(url, name = nil)
    title = name.blank? ? "Supprimer cet élément ?" : "Supprimer « #{name} » ?"
    link_to icon("trash"), url, class: "btn btn-default btn-icon js-deleter", title: title
  end

  def export_filename(prefix)
    "export_#{prefix}_#{Time.now.strftime('%Y-%m-%d_%H-%M-%s')}.csv"
  end

  def format_address(addr)
    [addr.address, addr.complement, "#{addr.zip_code} #{addr.city_name}", addr.country_name].reject(&:blank?).join("<br />")
  end

  def format_contact(contact)
    contact.civil_name
  end

  def format_validation_status(kind)
    classes = ["label"]
    case kind.to_sym
      when :validated
        classes << "label-success"
      when :waiting
        classes << "label-warning"
      when :refused
        classes << "label-danger"
      when :closed
        classes << "label-danger"
    end
    capture_haml do
      haml_tag :span, t("validation_statuses.labels.#{kind}"), class: classes
    end
  end

  def init_class_infos
    @__model_name_plural = controller_name
    @__model_name_singular = controller_name.singularize
    @__namespaces = params[:controller].split("/").map(&:downcase)
    @__namespaces.pop
    @__namespaces_ = @__namespaces.map { |x| "#{x}_" }.join
    true
  end

  def link_to_icon(name, url, opts = {})
    opts ||= {}
    opts[:class] = (opts[:class] || "").split(" ").reject(&:blank?)
    opts[:class] += ["btn", "btn-default", "btn-icon"]
    opts[:href] = url
    capture_haml do
      haml_tag :a, opts do
        concat icon name
      end
    end
  end

  def mail_to(email, name = "")
    str = name.present? ? "#{name} <#{email}>" : email
    link_to "mailto:#{URI::encode(str)}", title: email do
      haml_concat "#{trunc(email)} "
      haml_concat icon("new-window")
    end
  end

  def preview(obj, display_url = nil)
    return "preview…"
  end

  def sorted_path(path, sort, args = {})
    default = false === args.delete(:default_desc)
    args.merge!(params.inject({}) do |h, (k, v)|
      h[k] = v if k.to_s.start_with?('match_')
      h
    end)
    send(path, args.merge(
        :sort => sort,
        :match => params[:match],
        :desc => (sort == params[:sort] && params.has_key?(:desc) ? !('true' == params[:desc]) : !!default).to_s
    ))
  end

  # Exemples:
  # opts = { form: f, kind: :update, icon: :none }
  # opts = { form: f, kind: :submit, icon: :calendar }
  def submit_button(opts = {})
    opts = { form: opts } if opts.is_a? SimpleForm::FormBuilder
    opts.symbolize_keys!
    model = opts[:form].object.class.name.underscore
    key = opts[:kind]
    key ||= (obj = opts[:form].object) && obj.new_record? ? "submit" : "update"
    opts[:icon] ||= ("create" == key ? "plus" : "ok")
    text = I18n.t("helpers.submit.#{model}.#{key}", default: [:"helpers.submit.defaults.#{key}", 'Valider'])
    capture_haml do
      haml_tag :div, class: "form-group" do
        haml_tag :div, class: "form-field form-field-label" do
          haml_tag :button, type: :submit, class: "btn btn-primary btn-large btn-deco btn-submit", id: opts[:id] do
            haml_concat text
            unless :none == opts[:icon]
              haml_concat icon("#{opts[:icon]}")
            end
          end
          if block_given?
            haml_tag :div, class: "form-submit-inline" do
              yield
            end
          end
        end
      end
    end
  end

  def tab(tabs, name, force = false)
    tab = (tabs || {})[name.to_sym]
    return "" unless tab
    classes = ["tab-pane"]
    classes << "active" if force || @active_tab == name
    haml_tag :div, id: "tab-#{name}", class: classes do
      #haml_tag :div, class: "page-header" do
      #  haml_tag :h1 do
      #    haml_concat icon(tab[:icon]) if tab[:icon].present?
      #    haml_tag(:span, tab[:text], class: "inline-text")
      #  end
      #end
      yield
    end
  end

  def td_admin(admin, edit_url = nil)
    return td_no_admin "Système" unless admin
    kind = admin.class.to_s.underscore
    classes = edit_url ? "" : "link-ext-a"
    edit_url ||= send("edit_admin_#{kind}_path", id: admin.id)
    capture_haml do
      haml_tag :a, href: edit_url, title: admin.full_name, class: classes do
        #image = admin.images.detect { |x| "profile" == x.kind } # DEV NOTE: optimized for includes
        #image = image ? image.img.small.url : "admin/default_admin#{admin.male? ? "_male" : ""}.png"
        #haml_concat(image_tag image_path(image), alt: admin.full_name, class: "td-admin-img")
        haml_tag :span, admin.full_name, class: "name"
      end
    end
  end

  def td_no_admin(text)
    capture_haml do
      #haml_concat(image_tag image_path("admin/default_admin_system.png"), alt: text, class: "td-admin-img")
      haml_tag :span, text, class: "name"
    end
  end
end
