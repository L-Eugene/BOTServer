require_relative 'config'

module Proxy
  include Config

  def self.start
    shell_command :start
  end

  def self.restart
    shell_command :restart
  end

  def self.stop
    shell_command :stop
  end

  #
  # HTTPS configuration for nginx config
  #
  def self.config
    format(
      File.read("#{Config.templates_directory}/proxy_config.template"),
      port: port,
      host: host,
      certificate_file_pem: certificate_file_pem,
      certificate_file_key: certificate_file_key
    )
  end

  def self.shell_command(action)
    format(File.read("#{Config.templates_directory}/proxy.sh.template"), action: action)
  end

  private_class_method :shell_command
end
