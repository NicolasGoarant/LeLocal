# config/environments/development.rb
require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Recharge le code sans redémarrer le serveur
  config.enable_reloading = true

  # Ne pas eager-load en dev
  config.eager_load = false

  # Afficher les erreurs complètes
  config.consider_all_requests_local = true

  # Server-Timing dans les réponses
  config.server_timing = true

  # --- Caching ---
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "cache-control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Fichiers uploadés en local (Active Storage)
  config.active_storage.service = :local

  # --- MAILER (Gmail SMTP) ---
  # Assure-toi d’avoir exporté:
  #   export SMTP_USERNAME="nicolas.goarant35@gmail.com"
  #   export SMTP_PASSWORD="mot de passe d’application"
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              "sandbox.smtp.mailtrap.io",
    port:                 2525,
  # domain:               "mailtrap.io",
    user_name:            ENV["SMTP_USERNAME"],
    password:             ENV["SMTP_PASSWORD"],
    authentication:       :login,
    enable_starttls_auto: true,
    open_timeout:         5,
    read_timeout:         5
  }
  # URLs générées dans les mails (liens)
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Dépréciations
  config.active_support.deprecation = :log

  # Erreur si migrations en attente
  config.active_record.migration_error = :page_load

  # Logs des requêtes SQL plus parlants
  config.active_record.verbose_query_logs = true
  config.active_record.query_log_tags_enabled = true

  # Logs des jobs
  config.active_job.verbose_enqueue_logs = true

  # Annoter les vues avec le nom du fichier source
  config.action_view.annotate_rendered_view_with_filenames = true

  # Erreur si before_action pointe sur une action inexistante
  config.action_controller.raise_on_missing_callback_actions = true

  # Optionnel : mieux voir les emails en dev dans les logs
  config.action_mailer.logger = ActiveSupport::Logger.new($stdout)
  config.action_mailer.logger.level = Logger::INFO
end


