class Admin::Admins::AdminsController < Admin::BaseController
  include AdminActions # See /app/concerns/admin_actions.rb

  def update
    p = params[model_name.tableize.singularize.to_sym] || {}
    @item.attributes = p
    changed_password = @item.password.present?
    if @item.save
      sign_in(@item, bypass: true) if changed_password && current_admin.id == @item.id
      flash[:notice] = "#{translate_model_name.mb_chars.capitalize} « #{@item.name} » modifié(e)"
      return redirect_to(send("edit_#{namespaces_}#{model_name.tableize.singularize}_path", { id: @item.id }))
    end
    init_view
    render :edit
  end
end
