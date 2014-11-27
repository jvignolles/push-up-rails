class Admin::ImagesController < Admin::BaseController
  before_filter :check_parent_model
  before_filter :check_model, except: [:create, :list, :reorder, :upload_form] # :create_remote

  def assist
    return if request.get?
    if params.has_key?(:pad)
      if @image.pad! params[:pad]
        notice = 'L’image a été entourée'
      else
        notice = 'L’image avait déjà les bonnes proportions'
      end
    else
      crop = params[:cropping].to_s.split(',').map(&:to_i)
      if 4 != crop.length || crop[2] <= 0 || crop[3] <= 0
        return redirect_to(parent_url, alert: 'Définition de recadrage invalide')
      end
      dims = @image.actual_dimensions(:prefull)
      if dims[0] == crop[2] && dims[1] == crop[3]
        return redirect_to(parent_url, notice: "L’image avait déjà le bon cadrage")
      end
      @image.crop! *crop
      notice = "L’image a été recadrée"
    end
    redirect_to parent_url, notice: notice
  end

  def copy
    @image.copy!
    redirect_to parent_url, notice: 'L’image a été copiée'
  end

  def create
    create_remote
  end

  # GET method is allowed for cloud behaviour without JS
  def create_remote
    img = {}
    data = {}
    if params[:data].present?
      data = JSON.parse(params[:data]).symbolize_keys
      img = data[:image]
    else
      img = params[:image]
    end
    model = @imageable.class
    former_image = @imageable.respond_to?(:images) ? nil : @imageable.image
    kind = img[:kind]
    kind = model::IMAGE_KINDS.keys.first if kind.blank? && model.const_defined?(:IMAGE_KINDS)
    image = Image.new(imageable: @imageable, kind: kind, legend: img[:legend].to_s, zoomable: (img[:zoomable].present? ? img[:zoomable] : true))
    if Figaro.env.s3_enabled.to_bool
      # Special field for carrierwave_direct's business
      image.img.key = data[:key]
    end
    if request.xhr?
      if image.save_and_process!
        former_image.try :destroy if former_image
        #image[:url] = image.img.url
        return render(json: image, status: :ok)
      end
      Rails.logger.error "[Image Creation Error #{Time.zone.now.xmlschema}] #{image.errors.full_messages}"
      errors = image.errors[:img]
      render json: [{ error: errors }], status: :error
    else
      if image.save_and_process!
        former_image.try :destroy if former_image
        #image[:url] = image.img.url
        if Figaro.env.s3_enabled.to_bool && Figaro.env.js_upload_enabled.to_bool && Figaro.env.js_s3_iframe_enabled.to_bool
          return render(nothing: true)
        end
        return redirect_to({ action: :assist, id: image })
      end
      Rails.logger.error "[Image Creation Error #{Time.zone.now.xmlschema}] #{image.errors.full_messages}"
      redirect_to parent_url, alert: "L’image n’a pas pu être créée"
    end
  end

  def destroy
    @image.destroy_and_process!
    if request.xhr?
      head :ok
    else
      redirect_to parent_url, notice: "L’image a bien été supprimée"
    end
  end

  def highlight
    return head(:unprocessable_entity) unless @imageable.respond_to?(:highlighted_image_id)
    @image = nil if @image.id == @imageable.highlighted_image_id
    cnx = @imageable.class.connection
    cnx.execute %(
      UPDATE #{cnx.quote_table_name @imageable.class.table_name}
      SET highlighted_image_id = #{cnx.quote @image.try(:id)}
      WHERE id = #{cnx.quote @imageable.id}
    )
    @imageable.touch
    js = ["$('#images .thumbnail').removeClass('highlighted').find('i.icon-star').attr('class', 'icon-star-empty');"]
    js << %($("#image_#{params[:id]}").addClass('highlighted').find('i.icon-star-empty').attr('class', 'icon-star');) if @image
    render :text => js.join("\n")
    response.headers['Content-Type'] = 'text/javascript; charset=utf-8'
  end

  def list
    if request.xhr?
      return render(partial: "list", layout: false, locals: { imageable: @imageable, images: @imageable.images })
    end
    redirect_to parent_url
  end

  def reorder
    Image.transaction do
      (params[:image] || []).map(&:to_i).reject { |n| n <= 0 }.each_with_index do |id, index|
        Image.connection.execute "UPDATE images SET position = #{index += 1} WHERE id = #{id.to_i}"
      end
      @imageable.touch
    end
    head :ok
  end

  def update
#TODO strong params
    if @image.update_attributes(strong_params)
      flash[:notice] = 'L’image a été mise à jour'
    else
      flash[:alert] = 'L’image n’a pas pu être mise à jour'
    end
    redirect_to parent_url
  end

  def upload_form
    if request.xhr?
      return render(partial: "upload_form", layout: false, locals: { imageable: @imageable })
    end
    redirect_to parent_url
  end

private
  def check_model
    scope = if @imageable.respond_to?(:images)
      @imageable.images
    else
      Image.where(imageable_type: @imageable.class.name, imageable_id: @imageable.id)
    end
    #i18n_load scope, params[:id]
    @image = scope.where(id: params[:id]).first
    return redirect_to(parent_url, alert: 'Image introuvable') unless @image
  end

  def check_parent_model
    segments = request.path_info.split('/')
    key = ["create", "create_remote"].include?(params[:action]) && params.has_key?(:id) ? :id : params.keys.grep(/_id$/).sort_by { |k| segments.index(params[k]) }.last
    class_segment = if "create" == params[:action]
      -3 # …/klass/parent_id/images
    elsif "create_remote" == params[:action]
      -4 # …/klass/parent_id/images/create_remote
    else
      %w(destroy update list reorder upload_form).include?(params[:action]) ? -4 : -5 # …/klass/parent_id/images/(list|reorder|upload_form|id[/action])
    end
    @imageable = segments[class_segment].classify.constantize.find_by_id(params[key])
    @imageable = @imageable.delegate_images_to if @imageable.respond_to?(:delegate_images_to)
    return redirect_to(parent_url, alert: "Entité conteneur de l’image introuvable") unless @imageable
  end

  def parent_url
    parent = request.url.sub(%r(/images?(?:/\w+)*(?:\?.*)?$), "/edit?tab=images")
    $& ? parent : admin_home_path # Check last match to avoid infinite loop
  end

  def strong_params
    params.require(:image).permit(%(imageable kind legend zoomable assisted img))
  end
  
  helper_method :parent_url
end
