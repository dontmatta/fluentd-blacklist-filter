class BotFilterOutput < Fluent::Output
  Fluent::Plugin.register_output('bot_filter', self)

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
    !@blocked_ips.include?(record["log"]["ip_address"]+"\n")  
  end

  def get_blocked_ips
    if (defined?(@blocked_ips)).nil?
      begin
        filters_dir = File.expand_path File.dirname(__FILE__) + "/../filters"
        @blocked_ips = File.open(filters_dir + "/ip_addresses.txt", "rb").read
      rescue        
        @blocked_ips = ''
        return false        
      end
    end
    return true
  end

  def emit(tag, es, chain)
    if !get_blocked_ips
      Fluent::Engine.emit("fluentd.warn", Time.now.to_i, {"log" => "The ip_addresses.txt file could not be found"})
    end

    es.each do |time,record|
      next unless passFilter(record)
      Fluent::Engine.emit("filtered", time, record)
    end

    chain.next
  end

end
