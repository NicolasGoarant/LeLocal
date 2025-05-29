{ pkgs }: {
  deps = [
    pkgs.ruby_3_2
    pkgs.postgresql
    pkgs.nodejs
    pkgs.yarn
    pkgs.sqlite
    pkgs.git
    pkgs.openssh
    pkgs.openssl
    pkgs.libxml2
    pkgs.libxslt
    pkgs.pkg-config
    pkgs.imagemagick
    pkgs.which
  ];

  env = {
    RAILS_ENV = "development";
    BUNDLE_PATH = "${pkgs.ruby_3_2}/lib/ruby/gems/3.2.0";
    BUNDLE_BIN = "${pkgs.ruby_3_2}/lib/ruby/gems/3.2.0/bin";
    LANG = "en_US.UTF-8";
    RAILS_LOG_TO_STDOUT = "enabled";
    RAILS_SERVE_STATIC_FILES = "enabled";
  };
}
