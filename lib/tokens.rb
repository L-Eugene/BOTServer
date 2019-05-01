# frozen_string_literal: true

require 'colorize'
require 'telegram/bot'
require 'awesome_print'
require 'yaml'
require_relative 'utilities'
require_relative 'config'

module Tokens
  include Config

  def self.validation_print(status, do_exit = false)
    if status['valid_token']
      puts "Valid token! Bot name: @#{status['telegram_name']}".green
    else
      warn "Not Valid token. #{sanitize(status['telegram_error'])}".red
      exit if do_exit
    end
  end

  #
  # given a token, retrieve bot "username" asking to telegram server
  #
  def self.find_bot_name(token)
    status = verify_token(Telegram::Bot::Client.new(token))

    validation_print(status, true)
    status['telegram_name']
  end

  #
  # check tokens listed in tokens.yml
  # asking Telegram server
  # and updating tokens.yml with retrieved info
  #
  def self.check
    config_filename = Config.tokens_config_file

    result = bots_config(config_filename).map do |hash|
      token = hash.fetch('token')

      puts "\nverifying token: #{token}"

      status = verify_token(Telegram::Bot::Client.new(token))

      validation_print(status)

      hash.merge! status
    end

    # Save updated configuration in .yml file
    File.open(config_filename, 'w') { |f| f.write(yaml_dump(result)) }
    puts "\nupdated config file: #{config_filename}\n".yellow
  end

  def self.show
    "cat #{Config.tokens_config_file}"
  end

  #
  # select_valid_tokens
  #
  # scan the bot config file
  # extracting bots entry with a valid token
  #
  # return an array of bot names
  #
  def self.select_valid_tokens(config_filename)
    bots_config(config_filename).map do |hash|
      status = verify_token(Telegram::Bot::Client.new(hash['token']))
      next unless status['valid_token']

      {
        name: hash.key?('class_name') ? hash['class_name'] : status['telegram_name'],
        token: hash['token']
      }
    end.compact
  end

  # better than YAML.dump
  def self.yaml_dump(bots_config_hash)
    bots_config_hash.to_yaml
  end

  def self.sanitize(string)
    string.tr("\n\"", '')
  end

  #
  # validate the token and get Bot name, description,
  # querying Telegram server
  # token example: '123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11'
  #
  def self.verify_token(bot)
    status = { 'updated_at': time_now }

    # call getMe Telegram Bot API endpoint
    result = bot.api.get_me.fetch('result')
  rescue StandardError => e
    status.merge('valid_token' => false, 'telegram_error' => "\"#{sanitize(e.message)}\"")
  else
    # username is the @BOTNAMEbot
    # first_name is the public descritpion name (may contain blanks),
    #   e.g. "BOT NAME"
    # id is the  internal Telegram ID for the Bot
    status['telegram_name'] = result['username']
    status['telegram_description'] = result['first_name']
    status['telegram_id'] = result['id']
    status['valid_token'] = true
    status
  end

  def self.bots_config(config_filename)
    YAML.safe_load(File.open(config_filename), [Time])
  end

  private_class_method :verify_token, :sanitize, :yaml_dump, :bots_config
end
