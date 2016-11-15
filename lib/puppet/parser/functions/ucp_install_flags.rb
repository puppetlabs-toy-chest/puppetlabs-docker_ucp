module Puppet::Parser::Functions
  newfunction(:ucp_install_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []
    
    if opts['admin_username'].to_s != 'undef'
      flags << "--admin-username '#{opts['admin_username']}'"
    end      
    
    if opts['admin_password'].to_s != 'undef'
      flags << "--admin-password '#{opts['admin_password']}'"
    end      

    if opts['host_address'] && opts['host_address'].to_s != 'undef'
      flags << "--host-address '#{opts['host_address']}'"
    end

    unless opts['tracking']
      flags << '--disable-tracking'
    end

    unless opts['usage']
      flags << '--disable-usage'
    end

    if opts['version'] && opts['version'].to_s != 'undef'
      flags << "--image-version '#{opts['version']}'"
    end

    if opts['swarm_port'] && opts['swarm_port'].to_s != 'undef'
      flags << "--swarm-port '#{opts['swarm_port']}'"
    end

    if opts['controller_port'] && opts['controller_port'].to_s != 'undef'
      flags << "--controller-port '#{opts['controller_port']}'"
    end

    if opts['preserve_certs']
      flags << '--preserve-certs'
    end

    if opts['external_ca']
      flags << '--external-ucp-ca'
    end

    if opts['swarm_scheduler']
      case opts['swarm_scheduler']
      when 'binpack'
        flags << '--binpack'
      when 'random'
        flags << '--random'
      end
    end

    multi_flags = lambda do |values, format|
      filtered = [values].flatten.compact
      filtered.map { |val| sprintf(format, val) }
    end

    [
      ["--dns '%s'",        'dns_servers'],
      ["--dns-search '%s'", 'dns_search_domains'],
      ["--dns-opt '%s'",    'dns_options'],
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
