$resolved_gems = {}

def cleanup_operand(val)
  val.gsub(%r{[^~=<>]}, '')
end

def cleanup_version(val)
  val.gsub(%r{[\s~=<>]}, '')
end

def upper_border(val)
  val = cleanup_version(val).split('.')
  val.pop
  val.push(val.pop.to_i + 1)
  val.join('.')
end

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
def pack_version(version)
  if version[:exact].size > 1
    version[:errors] = version[:errors].push("#{version[:name]}: Multiple versions given, impossible to choose")
    return
  elsif version[:exact].size == 1
    version[:exact] = version[:exact].first

    res = (version[:lt] + version[:gt]).each_with_object(version[:errors]) do |ver, err|
      next if eval "'#{version[:exact]}' #{cleanup_operand(o)} '#{cleanup_version(o)}'", __FILE__, __LINE__ + 1

      err << "#{version[:name]}: #{version[:exact]} version does not match #{ver} condition"
    end

    version[:errors] = res unless res.empty?
    return
  end

  version[:lt] = version[:lt].map do |o|
    next o unless cleanup_operand(o) == '<='

    "< #{cleanup_version(o)}.1"
  end
  version[:lt] = version[:lt].min { |a, b| cleanup_version(a) <=> cleanup_version(b) }

  version[:gt] = version[:gt].map do |o|
    next o unless cleanup_operand(o) == '>'

    ">= #{cleanup_version(o)}.1"
  end
  version[:gt] = version[:gt].max { |a, b| cleanup_version(a) <=> cleanup_version(b) }
end

def resolve_gem(name, *args)
  $resolved_gems[name] = Hash.new { [] } unless $resolved_gems.key?(name)

  $resolved_gems[name][:name] = name

  args.each do |arg|
    next unless arg.is_a? String
    next if arg.empty?

    case arg
    when %r{~>}
      $resolved_gems[name][:gt] = $resolved_gems[name][:gt] + [">=#{cleanup_version(arg)}"]
      $resolved_gems[name][:lt] = $resolved_gems[name][:lt] + ["<#{upper_border(arg)}"]
    when %r{<}
      $resolved_gems[name][:lt] = $resolved_gems[name][:lt] + [arg]
    when %r{>}
      $resolved_gems[name][:gt] = $resolved_gems[name][:gt] + [arg]
    else
      $resolved_gems[name][:exact] = $resolved_gems[name][:exact] + [arg]
    end
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

resolve_gem 'activerecord'
resolve_gem 'awesome_print'
resolve_gem 'colorizer'
resolve_gem 'colorizer'
resolve_gem 'colorizer'

resolve_gem 'faraday'
resolve_gem 'faraday_middleware'

resolve_gem 'multi_json'
resolve_gem 'mysql2'
# fast JSON processing
resolve_gem 'oj'

# fast event machine rack server
resolve_gem 'rack'
resolve_gem 'thin'

# Telegram Bot API for Rubysts
resolve_gem 'telegram-bot-ruby'

Dir.glob('app/**/Gemfile').each do |file|
  instance_eval File.read(file)
end

source 'https://rubygems.org' do
  $resolved_gems.each { |_k, v| pack_version(v) }

  if $resolved_gems.any? { |_k, v| v.key? :errors }
    raise $resolved_gems.values.map { |g| g[:errors] }.flatten.compact.join("\n")
  end

  $resolved_gems.each do |name, opts|
    params = []

    if opts.key? :exact
      params << opts[:exact]
    else
      params << opts[:gt] if opts.key? :gt
      params << opts[:lt] if opts.key? :lt
    end

    gem name, *params
  end
end
