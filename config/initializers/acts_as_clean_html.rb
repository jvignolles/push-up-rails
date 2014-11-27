# encoding: utf-8
module ActsAsCleanHtml
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def acts_as_clean_html(*attr_names)
      clean_markup_attr_names = []
      attr_names = attr_names.reject(&:blank?).map(&:to_sym).select { |attr_name|
        next false if clean_markup_attr_names.include?(attr_name)
        clean_markup_attr_names << attr_name.to_sym
        true
      }
      before_validation { |model|
        attr_names.each { |attr_name|
          model.send("#{attr_name}=", model.send(attr_name).to_s.to_clean_html)
        }
      }
    end
  end
end

class ActiveRecord::Base
  include ActsAsCleanHtml
end

class String
  def to_clean_html(options = {})
    options = { :strip_empty_paragraphs => true }.merge(options)
    # Regular cleanup first: entities, comments, undesirable tags (and sometimes their contents)…
    text = Entities.decode(self)
    text.gsub!(%r((?:<|\&lt;)!--.*?--(?:>|\&gt;))mi, '')
    text.gsub!(FORBIDDEN_BODY_TAGS_REGEX, '')
    text.gsub!(FORBIDDEN_TAGS_REGEX, '')
    # Whitespace-only tags: reduce to one nonbreakable; if surrounded by a simple span, lose the tag.
    text.gsub!(%r((<([a-z:-]+)[^>]*>)[\s ]*(</\2>)), '\1 \3')
    text.gsub!('<span> </span>', ' ')
    # No font families or sizes!
    text.gsub!(%r(\bstyle=(['"]).*?\1)) { |s|
      s.gsub(%r(font-(?:family|size):.*?[;\b]), '')
    }
    # Pure MS Office stripping
    text.gsub!(%r(\s+class="MsoNormal")mi, '')
    # No empty pars!
    text.gsub!(%r(<p>[\s ]*</p>), '') if options[:strip_empty_paragraphs]
    text.gsub!(%r((\r?\n){2,}), '\\1')
    text
  end

private
  FORBIDDEN_BODY_TAGS       = %w(head title script style xml)
  FORBIDDEN_BODY_TAGS_REGEX = Regexp.new("<(#{FORBIDDEN_BODY_TAGS.join('|')})[^>]*>.*?</\\1>", Regexp::IGNORECASE | Regexp::MULTILINE)
  FORBIDDEN_TAGS            = %w(html meta body link)
  FORBIDDEN_TAGS_REGEX      = Regexp.new("</?(?:#{FORBIDDEN_TAGS.join('|')})[^>]*>", Regexp::IGNORECASE | Regexp::MULTILINE)
end

