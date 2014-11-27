class ImageWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 3, :queue => :image

  def perform(id, kind, options = {})
    options ||= {}
    options.symbolize_keys!
    if (image = Image.find_by_id(id))
      if "destroy" == kind
        image.destroy_and_process!(now: true)
      elsif "manipulations" == kind
        image.manipulations = options[:manipulations] if options[:manipulations].present?
        image.save_and_process!(now: true)
      end
    end
  end
end
