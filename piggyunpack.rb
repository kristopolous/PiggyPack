#!/usr/bin/env ruby
name='9bEZg'
`curl http://i.imgur.com/#{name}.png | convert - -compress none #{name}.ppm`
handle = File.open("#{name}.ppm", "r")
3.times do handle.readline;end
enc = handle.read.split(' ').map { | x | x.to_i }
bytes = 0.upto(enc.length / 3 - 1).map { | x |
    (enc.shift & 0x7) << 5\
  | (enc.shift & 0x3) << 3\
  | (enc.shift & 0x7)
}.pack('C*')
name = bytes.slice!(0, bytes.slice!(0,1)[0])
out = File.open("/tmp/#{name}", "w")
out << bytes[0, bytes.slice!(0, 8).unpack('q')[0]]
`mplayer /tmp/#{name}`
