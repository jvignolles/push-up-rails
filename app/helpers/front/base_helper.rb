module Front::BaseHelper
  def format_html(html)
    html.gsub(/<\/?p[^>]*>/, "").html_safe
  end

  def slices_for(list, div)
    return [list] if 1 >= div || 1 >= list.size
    step = list.size / div.to_f
    if step == step.to_i
      return list.each_slice(step).inject([]) { |acc, x| acc << x; acc }
    end
    current_step = step.ceil
    result = []
    index = 0
    count = list.size
    remain = div
    while index < count do
      result << list[index, current_step]
      index += current_step
      remain -= 1
      if 0 < remain && 0 == (count - index) % remain
        current_step = step.floor
        remain = 0
      end
    end
    result
  end

  # Exemples:
  # opts = { kind: :update, icon: :none }
  # opts = { kind: :submit, icon: :calendar }
  def submit_button(opts = {})
    opts = { form: opts } if opts.is_a? SimpleForm::FormBuilder
    opts.symbolize_keys!
    model = opts[:form].object.class.name.underscore
    key = opts[:kind]
    key ||= (obj = opts[:form].object) && obj.new_record? ? "submit" : "update"
    opts[:icon] ||= ("create" == key ? "plus" : "ok")
    text = I18n.t("helpers.submit.#{model}.#{key}", :default => [:"helpers.submit.defaults.#{key}", 'Valider'])
    capture_haml do
      haml_tag :div, :class => "form-group" do
        haml_tag :div, :class => "form-field form-field-label" do
          haml_tag :button, :type => :submit, :class => "btn btn-primary btn-large btn-deco btn-submit" do
            haml_concat text
            unless :none == opts[:icon]
              haml_concat icon("#{opts[:icon]}")
            end
          end
          if block_given?
            haml_tag :div, :class => "form-submit-inline" do
              yield
            end
          end
        end
      end
    end
  end
end
