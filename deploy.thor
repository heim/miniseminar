class Deploy < Thor                                               
  require 'fog'

  desc "start NUMBER_OF_SERVERS", "starts an arbitrary number of servers"   
  def start(amount)
    amount.to_i.times do
      #puts manifest 
      conn = Fog::Compute[:aws]
      puts "Bootstrapping server"
      begin
        server = conn.servers.bootstrap
      rescue
        puts "bootstrap ga en feilmelding"
      end
      conn.reload #hack
      
      server = conn.servers.last unless server #hack
      server.reload #hack
      
      puts "Server #{server.public_ip_address} ready"
      puts "Provisioning server"
      
      out = server.ssh("sudo apt-get -q update")
      puts out.first.stdout
      
      out = server.ssh("sudo apt-get -q -q -y install puppet")
      puts out.first.stdout
      
      server.ssh("echo '#{manifest}' > manifest.pp")
      
      out = server.ssh("sudo puppet manifest.pp")
      puts out.first.stdout
      
      puts "Server #{server.public_ip_address} configured"
    end
  end
  
  desc "stop", "stops all servers"
  def stop
    conn = Fog::Compute[:aws]
    conn.servers.each do |s|
      puts "Destroying: #{s.public_ip_address}"
      s.destroy
    end
  end
  
  private
  def manifest
    f = File.open("puppet/manifest.pp", "r") 
    data = ''
    f.each_line do |line|
      data += line
    end
    data
  end
  


end