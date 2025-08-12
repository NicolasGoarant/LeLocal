if ENV["SMTP_ADDRESS"].present?
  Rails.application.config.action_mailer.delivery_method = :smtp
  Rails.application.config.action_mailer.smtp_settings = {
    address:              ENV.fetch("SMTP_ADDRESS"),
    port:                 ENV.fetch("SMTP_PORT", 587).to_i,
    user_name:            ENV["SMTP_USERNAME"],
    password:             ENV["SMTP_PASSWORD"],
    authentication:       ENV.fetch("SMTP_AUTH", "plain"),
    enable_starttls_auto: ENV.fetch("SMTP_STARTTLS", "true") == "true",
    domain:               ENV.fetch("SMTP_DOMAIN", "herokuapp.com")
  }
end

host = ENV.fetch("MAILER_HOST", "localhost:3000")
Rails.application.routes.default_url_options[:host] = host
Rails.application.config.action_mailer.default_url_options = { host: host }
