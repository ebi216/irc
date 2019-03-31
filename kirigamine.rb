#!/usr/bin/ruby

require 'optparse'

send_irc = File.join((File.dirname(__FILE__)),'send_irc')

t = 400
leader = "#{8 * t} #{4 * t}"
bit = ["#{1 * t} #{1 * t}","#{1 * t} #{3 * t}"]
trailer = "#{1 * t} 8000"
send_buffer = []
repete = 4
interval = 60000

data = 0xc4d3_6480_0000_0000_0c00_0000_0000_2000_0000
data_length = 18


def rev_byte(var)
	a = 0b1010_1010 & var
	b = 0b0101_0101 & var
	var = (a >> 1) | (b << 1)
	a = 0b1100_1100 & var
	b = 0b0011_0011 & var
	var = (a >> 2) | (b << 2)
	a = 0b1111_0000 & var
	b = 0b0000_1111 & var
	var = (a >> 4) | (b << 4)
	return var
end


if ARGV.length != 10 then
	STDERR.print "Error: Too many or too few arguments defined.\n"
	exit(1)
end

opt = OptionParser.new
opt.on('-t', '--temperature VARUE', 'Define temperature from 16 to 31.') { |v|
	if !((16 <= v.to_i) and (v.to_i <= 31)) then
		STDERR.print "Error: Invalid argument.\n"
		exit(1)
	end
	temp = v.to_i - 16
	data = data + ((rev_byte(temp) >> 4) << 84)
}

opt.on('-p', '--power VARUE', 'Define power on or off.') { |v|
	if v !~ /^(on|off)$/ then
		STDERR.print "Error: Invalid argument.\n"
		exit(1)
	end
	if v == 'on' then
		data = data + (1 << 98)
	end
}

opt.on('-s', '--speed VARUE', 'Define wind speed from 0 to 3. 0 means auto.') { |v|
	if !((0 <= v.to_i) and (v.to_i <= 3)) then
		STDERR.print "Error: Invalid argument.\n"
		exit(1)
	end
	data = data + ((rev_byte(v.to_i) >> 6) << 70)
}

opt.on('-d', '--direction VARUE', 'Define wind direction from 0 to 5. 0 means auto.') { |v|
	if !((0 <= v.to_i) and (v.to_i <= 5)) then
		STDERR.print "Error: Invalid argument.\n"
		exit(1)
	end
	
	if v.to_i == 0 then
		direction = 0b10000
	else
		direction = 0b01000 + v.to_i
	end
	data = data + ((rev_byte(direction) >> 3) << 64)
}

opt.on('-m', '--mode VARUE', 'Define mode cooler or heater.') { |v|
	if v !~ /^(cooler|heater)$/ then
		STDERR.print "Error: Invalid argument.\n"
		exit(1)
	end

	case v
	when 'cooler' then
		mode = 0b11
	when 'heater' then
		mode = 0b10
	end
	data = data + (mode << 91)
}

opt.parse(ARGV)


sum = 0
for i in 0..(data_length - 1)
	octed = (data >> (i * 8)) & 0xff
	sum = sum + rev_byte(octed)
end
check = rev_byte(sum & 0xff)
data = data + check


send_buffer.push(leader)

for data_bit in data.to_s(2).scan(/./)
	send_buffer.push(bit[data_bit.to_i])
end
send_buffer.push(trailer)

i = 1
while i < repete
	i = i + 1
	send_buffer += send_buffer
end

system("#{send_irc} #{send_buffer.join(' ')}")
