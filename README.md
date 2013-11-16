Fluentd Blacklist Filter
========================

This non-buffered output filter for fluentd will filter web events based on blacklisted ip addresses.  It is intended to ignore traffic and events sent by bots/crawlers.

**Usage:**

Alter your td-agent.conf file to have these directives:

	<match your.event.tag>
		type bot_filter
	</match>
	<match filtered>
		type stdout
	</match>

Drop the <tt>out_bot_filter.rb</tt> file into your td-agent/plugin directory and restart the service.

Profit!
 
