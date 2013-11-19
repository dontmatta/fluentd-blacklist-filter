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

Drop the <tt>out_bot_filter.rb</tt> file into your td-agent/1.1.17/lib/ruby/gems/1.9.1/gems/fluentd-0.10.39/lib/fluent/plugin directory and restart the service.
Put the Gemfile inside the td-agent/1.1.17/lib/ruby/gems/1.9.1/gems/fluentd-0.10.39/ directory and run bundle.
Put the filters directory on the same level as the plugin directory, with the ip_addresses.txt file in there.

Profit!
 
