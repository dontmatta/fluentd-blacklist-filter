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
    return true if (!record.has_key?("log") || !record["log"].has_key?("ip_address"))
    $stderr.puts "Filtering on " + record["log"]["ip_address"]
     
    blocked_ips = "63.229.62.0\n63.229.62.1\n"
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
