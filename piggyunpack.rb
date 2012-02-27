#!/usr/bin/env ruby
name='9bEZg'
`curl http://i.imgur.com/#{name}.png | convert - -compress none #{name}.ppm`
ppm = File.open("#{name}.ppm")
3.times { ppm.readline }
enc = ppm.read.split(' ').map { | x | x.to_i }
bytes = 0.upto(enc.length / 3 - 1).map { | x |
    (enc.shift & 7) << 5\
  | (enc.shift & 3) << 3\
  | enc.shift & 7
}.pack('C*')
name = bytes.slice!(0, bytes.slice!(0, 1).unpack('C')[0])
out = File.open("/tmp/#{name}", "w")
out << bytes[0, bytes.slice!(0, 8).unpack('q')[0]]
`mplayer /tmp/#{name}`
