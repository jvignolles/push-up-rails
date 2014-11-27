# encoding: utf-8
class DeviseBackgrounder
  def self.confirmation_instructions(record, options = {})
    new(:confirmation_instructions, record.email_info(:confirmation_token))
  end

  def self.reset_password_instructions(record, options = {})
    new(:reset_password_instructions, record.email_info(:reset_password_token))
  end

  def self.unlock_instructions(record, options = {})
    new(:unlock_instructions, record.email_info(:unlock_token))
  end

  def initialize(method, h)
    @method, @h = method, h
  end

  def deliver
    Notifier.delay.send(@method, @h)
  end
end

