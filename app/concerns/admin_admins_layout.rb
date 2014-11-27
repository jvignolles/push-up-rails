module AdminAdminsLayout
  def self.included(base)
    base.send :include, AdminLayout
    base.class_eval do
      layout "admin_admins" # DEV NOTE: can't override 'set_layout' method, so…
      before_filter :init_admin_admins_layout
    end
  end

protected
  def init_admin_admins_layout
    @admin_kind = :personal
    @main_class = :admins
    @page_heading = "Votre compte"
    @breadcrumbs << { name: @page_heading, url: admin_admins_admins_path }
    true
  end
end
