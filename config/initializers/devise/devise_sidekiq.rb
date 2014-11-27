# encoding: utf-8
# Be sure to restart your server when you modify this file.
module Devise
  module Models
    module Sidekiq
      extend ActiveSupport::Concern

      included do
        # Register hook to send all devise pending notifications.
        # Need to send email after_commit...
        after_commit :send_devise_pending_notifications
      end

    protected
      def send_devise_notification(notification, opts={})
        # If the record is dirty we keep pending notifications to be enqueued
        # by the callback and avoid before commit job processing.
        if changed?
          devise_pending_notifications << [notification, opts]
        # If the record isn't dirty (aka has already been saved) enqueue right away
        # because the callback has already been triggered.
        else
          DeviseBackgrounder.send(notification, self, opts).deliver
        end
      end

      # Send all pending notifications.
      def send_devise_pending_notifications
        devise_pending_notifications.each do |pair|
          DeviseBackgrounder.send(pair[0], self, pair[1]).deliver
        end
        @devise_pending_notifications = []
      end

      def devise_pending_notifications
        @devise_pending_notifications ||= []
      end
    end
  end
end

