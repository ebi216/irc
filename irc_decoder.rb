#!/usr/bin/ruby

path = ARGV[0]

t_max = 500
t_min = 350

data = []
data_bin = []

f = open(path,'r')
f.each do |line|
	if (/^pulse / =~ line) then
		if (data.length % 2) != 1 then
			puts 'Error'
			break
		end
	elsif (/^space / =~ line) then
		if (data.length % 2) != 0 then
			puts 'Error'
			break
		end
	else
		next
	end

	duration = (line.sub(/^(pulse|space) /,'')).to_i
	coefficient = 0
	[1,3,4,8].each do |i|
		t = duration / i
		if t_min <= t and t <= t_max then
			coefficient = i
		end
	end
	data.push(coefficient)
end


i = 1
while i < data.length do
	if data[i] == 8 then
		i = i + 1
		if data[i] == 4 then
			data_bin.push(2)  #'2' means "Leader"
		else
			data_bin.push(3)  #'3' means "Error"
		end
	elsif data[i] == 1 then
		i = i + 1
		if data[i] == 1 then
			data_bin.push(0)
		elsif data[i] == 3 then
			data_bin.push(1)
		else
			data_bin.push(3)
		end
	else
		data_bin.push(3)
		i = i + 1
	end
	i = i + 1
end


for frame in (data_bin.join).split('2')
	if frame.empty? then
		next
	end

	frame = frame.sub(/3$/,'')
	if frame.include?('3') then
		next
	end

	octed_list = frame.scan(/.{1,8}/)
	puts octed_list.join(' ')

	hex_list = []
	for octed in octed_list
		integer = (octed.ljust(8,'0')).to_i(2)
		hex_list.push(integer.to_s(16))
		#hex_list.push(printf('%02x',integer))
	end
	puts hex_list.join(' ')
end
