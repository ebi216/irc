#!/usr/bin/ruby

require 'beebotte'
require 'json'
require 'syslog'

Syslog.open(__FILE__)
Syslog.log(Syslog::LOG_INFO, 'Start script.', )

token = 'token_aHuZe4tx2lxE2p8w'
channel = 'myhome'
resource = 'irc'

ceiling_light = File.join((File.dirname(__FILE__)),'ceiling_light.rb')

scripts = {'ceiling_light'=>ceiling_light}

s = Beebotte::Stream.new({token: token})

begin
	s.connect()
	s.subscribe("#{channel}/#{resource}")
rescue
	Syslog.log(Syslog::LOG_INFO, 'Faild to connect BeeBotte.', )
end
Syslog.log(Syslog::LOG_INFO, 'Connection established', )

s.get { |topic, message|
	data = (JSON.parse(message))['data']

	case data['device']
	when 'ceiling_light' then
		if /on|off/ =~ data['param'] then
			system("#{scripts['ceiling_light']} #{data['param']}")
		end
	end
}
