# frozen_string_literal: true

require 'telegram/bot'
require 'colorize'
require 'awesome_print'
require 'multi_json'

module Webhook
  def self.set(token, certificate_file)
    webhook(:set, token, certificate_file)
  end

  def self.reset(token, certificate_file)
    webhook(:reset, token, certificate_file)
  end

  def self.certificate(certificate_file)
    # WARNING
    # Note that setWebhook action by the bot instance (settings.bot)
    # that OWN the token (#singleBotManagement)
    # This means that to manage multiple bots, this app would manage and
    # array of bot (#multipleBotManagement)
    if certificate_file.nil?
      puts 'no certificate file?'.yellow
      nil
    else
      puts "certificate file: #{certificate_file}".yellow
      Faraday::UploadIO.new(
        File.expand_path(certificate_file),
        'application/x-pem-file'
      )
    end
  end

  def self.print_error_and_die(error, token)
    warn "ERROR. Telegram Server refuse request for token: #{token}".red
    warn "reason: #{error.message}".red
    exit!
  end

  def self.print_success(resp)
    puts "ok: #{resp['ok']}, result: #{resp['result']},".yellow
    puts "description: #{resp['description']}".yellow
  end

  def self.client(token)
    # create bot from given token
    Telegram::Bot::Client.new(token)
  end

  # to set webhook   ->  action = :set
  # to unset webhook -> action = :reset
  def self.webhook(action, token, pem)
    raise "action #{action} not allowed" unless %i[set reset].include? action

    puts "\n#{action == :set ? '' : 're'}setting webhook: #{Server.url(token)}"

    # telegram server feedbacks exception handler
    begin
      url = action == :set ? Server.url(token) : ''
      print_success(
        client(token).api.set_webhook(url: url, certificate: certificate(pem))
      )
    rescue StandardError => e
      print_error_and_die(e, token)
    end
  end

  private_class_method :webhook, :certificate,
                       :print_error_and_die, :print_success
end
