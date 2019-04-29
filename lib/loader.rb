require 'telegram/bot'
require 'colorize'
require 'awesome_print'

require_relative 'utilities'
require_relative 'config'
require_relative 'tokens'

module Loader
  include Config
  include Tokens

  #
  # create_lookup
  #
  # scan in the bot config files
  # extracting bots entry with a valid token
  #
  # return an hash lookup table where
  # key is the bot token, value is the pair:
  # bot name, update method handler
  #
  def self.lookup
    config_filename = Config.tokens_config_file

    bots = Tokens.select_valid_tokens(config_filename)

    # lookup_table is a key/value hash
    bots.each_with_object({}) do |app, lookup|
      # ap app
      # load the bot source code
      name = app[:name]
      token = app[:token]

      app = load_instantiate_bot(name, Config.app_directory)

      #
      # TRICKY!
      # Instantiating a method object
      #
      update = app.method(:update)

      # insert item in the lookup table
      # key is the token as symbol, value is the pair bot name + update method object
      lookup[token.to_sym] = { name: name, method: update }
    end
  end

  #################
  # load_create_bot
  #
  # gived a bot app class filename
  # return the instance of a bot
  #
  def self.load_instantiate_bot(name, path = '.')
    # 'HelloBot' -> './hellobot.rb'
    bot_filename = downcase_filename(name, path)

    # load in memory app source file: './hellobot.rb'
    load bot_filename

    # '@HelloBot' -> 'HelloBot'
    class_name = remove_tilde(camelize_as_class(name))

    # create class symbol from a string
    bot_class = Kernel.const_get(class_name)

    # return a new instance
    bot_class.new
  end

  private_class_method :load_instantiate_bot
end
