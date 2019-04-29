source 'https://rubygems.org' do
  gem 'activerecord'
  gem 'awesome_print'
  gem 'colorizer'

  gem 'faraday'
  gem 'faraday_middleware'

  gem 'multi_json'
  gem 'mysql2'
  # fast JSON processing
  gem 'oj'

  # fast event machine rack server
  gem 'rack'
  gem 'thin'

  # Telegram Bot API for Rubysts
  gem 'telegram-bot-ruby'
end

Dir.glob('app/**/Gemfile').each do |file|
  instance_eval File.read(file)
end
