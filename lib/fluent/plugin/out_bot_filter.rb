require 'rubygems'
require 'dalli'

class BotFilterOutput < Fluent::Output
  Fluent::Plugin.register_output('bot_filter', self)

  MC_KEY = 'ip_addresses'

  def configure(conf)
    super
  end
	
  def start
    super
  end

  def shutdown
    super
  end

  def passFilter(record)
    return true if (!record.has_key?("log") || !record["log"].has_key?("ip_address") || record["log"]["ip_address"].to_s.strip.length < 1)

    @dc = Dalli::Client.new('localhost:11211', {:namespace => "commerce", :compress => true}) if (defined?(@dc)).nil?
    if !(blocked_ips = @dc.get(MC_KEY))
      filters_dir = File.expand_path File.dirname(__FILE__) + "/../filters"
      blocked_ips = File.open(filters_dir + "/ip_addresses.txt", "rb").read 
      @dc.set(MC_KEY, blocked_ips)    
    end
    !blocked_ips.include?(record["log"]["ip_address"]+"\n")  
  end

  def emit(tag, es, chain)
    es.each do |time,record|
      $stderr.puts "Record: " + record.to_s
      next unless passFilter(record)
      Fluent::Engine.emit("filtered", time, record)
      $stderr.puts "Passed!"
    end

    chain.next
  end

end
