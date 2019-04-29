# frozen_string_literal: true

require 'rack'
require 'multi_json'
require_relative '../lib/loader'

class WebhookRouter
  include Loader
  #
  # load bots in memory. return a lookup table
  # to retrieve object method :update, from a passed token as key
  #
  @lookup = Loader.lookup

  #
  # HTTP REQUEST
  #
  def self.call(env)
    request = Rack::Request.new(env)

    return unless request.post?

    # deserialize: from JSON to hash
    body = MultiJson.load request.body.read

    # get token from path string, removing initial '/' and suffix,
    # afterward symbolize
    token = request.path.gsub(%r{^.*\/}, '').to_sym

    #
    # HTTP POST /:token
    #
    webhook token, body
  end

  ################################
  # HTTPS POST webhook endpoint
  # token as symbol, data as hash
  ################################
  def self.webhook(token, data)
    # remove suffix from token

    # retrieve name, method object pair from lookup table
    bot = @lookup[token]

    if bot
      # SUCCESS: token found in look-up table

      # routing dispatch: call object method
      bot[:method].call data

      # WARNING: it's better to do not write/log tokens in clear on a log files
      puts "#{time_now},#{bot[:name]},#{data['update_id']}".green
      [200, {}, []]
    else
      # WARNING: token not found in look-up table!
      warn "WARNING. unexpected/unknown token: #{token}".red
      [400, {}, []]
    end
  end

  private_class_method :webhook
end
