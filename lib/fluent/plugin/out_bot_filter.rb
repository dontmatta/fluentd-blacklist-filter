class BotFilterOutput < Fluent::Output
  Fluent::Plugin.register_output('bot_filter', self)
  
  FILTER_FILES = {
    'ip' => 'ip_addresses.txt',
    'bot_sub' => 'bot_sub_strings.txt',
    'bot_full' => 'bot_full_strings.txt',
    'non_bots' => 'non_bots.txt'
  }

  def configure(conf)
    super
  end
	
  def start
    super
    if (defined?(@values)).nil?
      @values = {}     
      filters_dir = File.expand_path File.dirname(__FILE__) + "/../filters"
      FILTER_FILES.each do |k,v|
        next if @values.has_key?(k)
        begin
          @values[k] = File.open(filters_dir + "/" + v, "rb").read
          @values[k] = @values[k].split("\n").map { |s| Regexp.new(Regexp.quote(s.strip)) } if k == "bot_sub"
        rescue
          Fluent::Engine.emit("fluent.warn", Time.now.to_i, {"log" => "The " + v + " file could not be read"})
        end
      end # each
    end # if @values.nil    
  end

  def shutdown
    super
  end
  
  def passFilters(record)
    return true if (defined?(@values)).nil? || (!record.has_key?("log") || !record["log"].has_key?("ip_address") || record["log"]["ip_address"].to_s.strip.length < 1)
    return false if !record["log"].has_key?("user_agent") 
    return false if record["log"]["user_agent"].to_s.strip.length < 1 # bot if no user-agent
    
    # check for ip's
    return false if @values.has_key?("ip") && @values["ip"].include?(record["log"]["ip_address"]+"\n")
    
    # check for non-bots
    return true if @values.has_key?("non_bots") && @values["non_bots"].include?(record["log"]["user_agent"]+"\n")
    
    # check for bots (full string)
    return false if @values.has_key?("bot_full") && @values["bot_full"].include?(record["log"]["user_agent"]+"\n")

    # check for bots (substring)
    if @values.has_key?("bot_sub")
      @values["bot_sub"].each do |sub_str|        
        return false if record["log"]["user_agent"] =~ sub_str
      end
    end

    return true
  end

  def emit(tag, es, chain)    
    es.each do |time,record|
      next unless passFilters(record)
      begin 
        # convert invalid post_id's
        record["log"]["post_id"] = record["log"]["post_id"].to_i.to_s if record["log"]["post_id"].to_s.strip.length > 0
      rescue
      end
      Fluent::Engine.emit("filtered", time, record)
    end

    chain.next
  end

end
