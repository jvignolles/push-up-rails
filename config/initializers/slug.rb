# encoding: utf-8
module Slug
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # Defines how the slug for the model is built. Takes one or more field names as slug constituents,
    # possibly followed by an options hash. Slugs are hyphen-separated, ASCII-only strings of letters and
    # numbers obtained by UTF-8 to ASCII//TRANSLIT translation of the slug constituents, with no
    # hyphen repetition. Constituents can be specified as either strings or symbols.
    #
    # Available options:
    #
    # * +scope+: one or more columns (either String or Symbol items) within which to restrict the uniqueness test,
    #     much like ActiveRecord’s.  None by default.
    # * +use_id_prefix+: whether to systematically prefix generated slugs with the primary key or not.  Such
    #     slugs can be used automatically as PK parameters for finders, which is handy.  Defaults to +true+.
    # * +max_len+: the maximum length for the slug.  No default, which imposes no length restriction.
    # * +downcase+: set the slug downcase or not.  Default to +true+.
    def slug(*args)
      return if respond_to?(:slugged_options)

      require 'ascii'

      class_attribute :slugged_options
      class_attribute :slugged_components

      # Normalize options
      options = (args.last.is_a?(Hash) ? args.pop : {}).symbolize_keys
      options[:use_id_prefix] = options.has_key?(:use_id_prefix) ? !!options[:use_id_prefix] : true
      options[:max_len] = options[:max_len].to_i if options.has_key?(:max_len)
      options[:downcase] = options.has_key?(:downcase) ? !!options[:downcase] : true
      # Normalize components
      args.unshift(:id) if options[:use_id_prefix]
      args = args.map(&:to_sym)
      # Store at actual class level
      self.slugged_options = options
      self.slugged_components = args
      send :include, InstanceMethods
      alias_method :to_param, :make_slug
    end
  end

  module InstanceMethods
    def make_slug
      str = Ascii.slug(
        self.slugged_components.map { |sym| send(sym) }.reject(&:blank?).join(' '),
        self.class.slugged_options
      )
      self.class.slugged_options[:downcase] ? str.downcase : str
    end
  end
end

class ActiveRecord::Base
  include Slug
end

