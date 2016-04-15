class Rack::Attack
  Rack::Attack.blacklist('block <ip>') do |req|
    Iptables.match? req.ip
  end
end
