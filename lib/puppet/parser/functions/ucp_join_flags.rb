module Puppet::Parser::Functions
  newfunction(:ucp_join_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []

    if opts['host_address'] && opts['host_address'].to_s != 'undef'
      flags << "--host-address '#{opts['host_address']}'"
    end

    unless opts['tracking']
      flags << '--disable-tracking'
    end

    unless opts['usage']
      flags << '--disable-usage'
    end
    
    if opts['replica'] == true
      flags << '--replica'	    
    end  	    
    
    if opts['version'] && opts['version'].to_s != 'undef'
      flags << "--image-version '#{opts['version']}'"
    end

    if opts['fingerprint'] && opts['fingerprint'].to_s != 'undef'
      flags << "--fingerprint '#{opts['fingerprint']}'"
    end

    if opts['ucp_url'] && opts['ucp_url'].to_s != 'undef'
      flags << "--url '#{opts['ucp_url']}'"
    end

    multi_flags = lambda do |values, format|
      filtered = [values].flatten.compact
      filtered.map { |val| sprintf(format, val) }
    end

    [
      ["--dns '%s'",        'dns_servers'],
      ["--dns-search '%s'", 'dns_search_domains'],
      ["--dns-option '%s'", 'dns_options'],
      ["--san '%s'",        'san'],
    ].each do |(format, key)|
      values    = opts[key]
      new_flags = multi_flags.call(values, format)
      flags.concat(new_flags)
    end

    opts['extra_parameters'].each do |param|
      flags << param
    end

    flags.flatten.join(" ")
  end
end
