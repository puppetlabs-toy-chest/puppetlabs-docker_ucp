require 'shellwords'

module Puppet::Parser::Functions
  # Transforms a hash into a string of docker swarm init flags
  newfunction(:dtr_install_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []

    if opts['dtr_external_url'].to_s != 'undef'
      flags << "--dtr-external-url '#{opts['dtr_external_url']}'"
    end
    
    if opts['dtr_version'].to_s != 'undef'
      flags << @version	
    end     
    
    if opts['ucp_node'].to_s != 'undef'
      flags << "--ucp-node '#{opts['ucp_node']}'"
    end
   
    if opts['ucp_username'].to_s != 'undef'
      flags << "--ucp-username '#{opts['ucp_username']}'"
    end  
     
    if opts['ucp_password'].to_s != 'undef'
      flags << "--ucp-password '#{opts['ucp_password']}'"	    
    end

    if opts['ucp_insecure_tls'].to_s != 'false'
      flags << '--ucp-insecure-tls'
    end
    
    if opts['dtr_ucp_url'].to_s != 'undef'
      flags << "--ucp-url '#{opts['dtr_ucp_url']}'"
    end

    if opts['replica_id'].to_s != 'undef'
      flags << "--replica-id '#{opts['replica_id']}'"	     
    end
    
    if opts['ucp_ca'].to_s != 'undef'
      flags << "--ucp-ca '#{opts['ucp_ca']}'"
    end  

    flags.flatten.join(" ")
  end
end
