# encoding: utf-8
# Be sure to restart your server when you modify this file.
Premailer::Rails.config.merge!(
  preserve_styles: true,
  remove_ids: true,
  generate_text_part: false,
  remove_comments: true,
  css_to_attributes: true,
)

