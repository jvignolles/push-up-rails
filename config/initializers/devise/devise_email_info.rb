# encoding: utf-8
# Be sure to restart your server when you modify this file.
module Devise
  module Models
    module EmailInfo
      def email_info(kind, add = nil)
        kind = kind.to_sym
        h = {
          :resource_name => self.class.name.downcase,
          :recipient_email => email,
        }
        f_name = respond_to?('first_name') ? first_name : (respond_to?('firstname') ? firstname : nil)
        h[:recipient_name] = f_name || email.sub(/@.*$/, '')
        if respond_to?('full_name')
          h[:recipient_full_name] = full_name
        elsif respond_to?('name')
          h[:recipient_full_name] = name
        else
          l_name = respond_to?('last_name') ? last_name : (respond_to?('lastname') ? lastname : nil)
          full_name = "#{l_name.to_s.capitalize} #{f_name.to_s.capitalize}".strip
          h[:recipient_full_name] = full_name.blank? ? '' : full_name
        end
        case kind
          when :confirmation_token
            if respond_to?('confirmation_token')
              h[:confirmation_token] = confirmation_token
              if respond_to?('auto_pass')
                h[:auto_pass] = auto_pass
                h[:password] = password if auto_pass
              else
                h[:password] = password
              end
            end
          when :reset_password_token
            h[:reset_password_token] = reset_password_token
          when :unlock_token
            h[:unlock_token] = unlock_token
        end
        h[:confirmed] = respond_to?('confirmed?') && confirmed?
        h.merge!(add) if add.is_a?(Hash)
        h
      end
    end
  end
end

