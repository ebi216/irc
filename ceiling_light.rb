#!/usr/bin/ruby

send_irc = File.join((File.dirname(__FILE__)),'send_irc')

t = 400
leader = "#{8 * t} #{4 * t}"
bit = ["#{1 * t} #{1 * t}","#{1 * t} #{3 * t}"]
trailer = "#{1 * t} 8000"
send_buffer = []
repete = 4
interval = 60000

code_list = {
	 on:'11001000 11101000 00100000 10001111 0111',
	off:'11001000 11101000 00100010 10001101 0111'
}


send_buffer.push(leader)

code = (code_list[ARGV[0].to_sym]).gsub(' ','')
for data in code.scan(/./)
	send_buffer.push(bit[data.to_i])
end
send_buffer.push(trailer)

i = 1
while i < repete
	i = i + 1
	send_buffer += send_buffer
end

system("#{send_irc} #{send_buffer.join(' ')}")
