module Puppet::Parser::Functions
  newfunction(:ucp_uninstall_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []

    if opts['preserve_certs_on_delete']
      flags << '--preserve-certs'
    end

    if opts['preserve_images_on_delete']
      flags << '--preserve-images'
    end

    if opts['ucp_id'] && opts['ucp_id'].to_s != 'undef'
      flags << "--id '#{opts['ucp_id']}'"
    end

    opts['extra_parameters'].each do |param|
      flags << param
    end

    flags.flatten.join(" ")
  end
end
