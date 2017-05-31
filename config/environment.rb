# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  user_name: "apikey",
  password: "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",
  # user_name: ENV['SENDGRID_USERNAME'],
  # password: ENV['SENDGRID_PASSWORD'],
  # domain: '159.203.97.63',
  server: "smtp.sendgrid.net",
  port: 587
  # authentication: 'login',
  # enable_starttls_auto: true
}
