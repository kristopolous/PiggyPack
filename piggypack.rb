#!/usr/bin/env ruby
# piggypack does the following things:
# 
#  1. Takes a file, called the "payload" file
payload_name = "astley.3gp"
overlay_name = "astley.ppm"
out = File.open("binary.pgm", "w")
handle = File.open(payload_name, "r")
overlay_handle = File.open(overlay_name, "r")

3.times do out << overlay_handle.readline + "\n"; end
bytes = handle.read

# The length of the file name (8B)
# the payload itself
# The length of the file (8B)
# the file itself
numbers = [
  payload_name.length,
  payload_name.unpack("C*"),
  [bytes.length].pack('q*').unpack('C*'),
  bytes.unpack("C*")
].flatten

len = bytes.length

offset = 0
loop {
  begin
    line = overlay_handle.readline
  rescue
    break
  end
  break unless line
  line = line.split(' ').map{ | x | x.to_i }

  0.upto(line.length / 3 - 1) { | x |
    if offset < numbers.length
      byte = numbers[offset]
      pixel = x * 3
      # xxx0 0000 Red channel gets msb top 3 bits as the lsb 
      line[pixel] = line[pixel] & 0xF8 | ((byte >> 5) & 0x7)
      # 000x x000 Green gets the next 2
      line[pixel + 1] = line[pixel + 1] & 0xFC | ((byte >> 3) & 0x3)
      # 0000 0xxx Blue gets lsb 3
      line[pixel + 2] = line[pixel + 2] & 0xF8 | (byte & 0x7)

      offset += 1
    end
  }
  out << line.join(' ') + "\n"
}
out << "\n"

out.close

`convert binary.pgm binary.png`
