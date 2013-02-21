#!/usr/bin/env ruby
# piggyunpack does the following things:
#
#  1. Downloads an image from the internet.
#  2. Converts the image to a ppm formatted image (http://en.wikipedia.org/wiki/Netpbm_format)
#  3. Ignores the header information
#  4. Takes the LSB (http://en.wikipedia.org/wiki/Least_significant_bit) of the image data, then
#     repackages it.
#  5. Writes that file to disk.
#  6. Plays the file using mplayer.


#
# ---------------------------------------------------------
#  Step 1: Download the image from the internet using curl
# ---------------------------------------------------------
name='9bEZg'
`curl http://i.imgur.com/#{name}.png | convert - -compress none #{name}.ppm`

#                                       ||^
# -------------------------------       |^|
#  Step 2: Convert to ppm format        ^||
# -------------------------------       |^|
#                                       ||^
#                    Using ImageMagick, ^^^ take the image from the standard
#                    input and then convert it to ppm format.

# Now open up the image created above in Ruby.
ppm = File.open("#{name}.ppm")


#
# --------------------------------------
#  Step 3: Ignore the first three lines 
# --------------------------------------
3.times { ppm.readline }

# ppm.read takes all the bytes, split puts it into a huge array, and the
# map then converts things to integers, since ppm reads in unformatted text
# not knowing if it's a number of not.
enc = ppm.read.split(' ').map { | x | x.to_i }

#
# ------------------------------------------------------------
#  Step 4: Takes the LSB of the image data, then repackage it
# ------------------------------------------------------------
# This is the trickiest.  It goes over the entire array previously
# made.  The array is enc.length numbers long.  Each element in the array
# is actually three numbers corresponding to a single pixel on the screen.
#
# Each three number triplet is the Red, Green, and Blue part of the image,
# done (I believe addititively).  If you've worked with HTML you've probably
# seen these before, numbers like #FF0000 meaning "bright red, all red".
#
# Since each pixel is three numbers we consider three of them at a time.
#
# We take the lower 3 bits of red, the lower 2 of green, and the lower 3 of blue
# and then move that data over.  Here is the best that ASCII can provide:
#
# -------------------------------------------------
# Step 4a. Getting the data from the Red Channel
# -------------------------------------------------
# rrrrrRRR << Lower three bits from RED
#      |||
#     ///     1 Shift to the left
#    ///      2 Shifts to the left
#   ///       3 Shifts to the left
#  ///        4 Shifts to the left
# ///         5 Shifts to the left
# |||
# RRR..... << Byte of the final file
#
# 
# -------------------------------------------------
# Step 4b. Getting the data from the GREEN Channel
# -------------------------------------------------
# ggggggGG << Lower two bits of GREEN
#       || 
#      //     1 Shift to the left 
#     //      2 Shifts to the left
#    //       3 Shifts to the left
#    ||
# RRRGG... << Byte of the final file
#
#
# -------------------------------------------------
# Step 4c. Getting the data from the BLUE Channel
# -------------------------------------------------
# bbbbbBBB << Lower three bits of BLUE
#      |||
#      |||    (no shifts at all)
#      |||
# RRRGGBBB << Byte of the final file
#
#
bytes = 0.upto(enc.length / 3 - 1).map { | x |
    (enc.shift & 0b00000111) << 5\
  | (enc.shift & 0b00000011) << 3\
  | (enc.shift & 0b00000111) 
}.pack('C*')

# Now the array "bytes" has all the image data from above
# transformed by this logic.  It will be 1/3 the size of the image, since
# for every Red, Blue, and Green Byte, it sliced off enough bits to form
# 1 Single Byte. That means that if the first color was say,
#
# RGB: (91%, 49%, 31%) we can convert these to bytes (a number between 0
# and 255) like so:
#
# 0.91 * 255 = 232.05 ~= 232
# 0.49 * 255 = 124.95 ~= 125
# 0.31 * 255 = 79.05 ~= 79
#
# Ok, so we can also call this (232, 125, 79).  Now in computer terms, we
# can convert this to binary.
#
# 232 = 0b11101000
# 125 = 0b11111101
#  79 = 0b10011111
#
# Let's use our rules above. 
#
#  Lowest three from Red  = 000
#  Lowest two from Green  =    01
#  Lowest three from Blue =      111
#
# So our final byte will be 00001111 = 0xFF = 15.

# We have a higher order format that we imposed with the packer.
# Here is a block diagram:
#
# +-+--------+--------+----------- ~ ~ ---+
# |F|FileName|FileSize|FileData...     ...|
# +-+--------+--------+----------- ~ ~ ---+
#
# Where 
#   F is the length of the file name 
#   FileName is the name of the file that was encoded
#   FileSize is a 64 bit number that is the length of 
#    the encoded file
#   FileData is the binary data of the original file.

# To get the name we first take the first byte, convert it to
# a number, and then use that number as the second parameter to
# our slice operation to get the name of the file.
#
#                     +-- The length of the filename ---+
#                     |                                 |
name = bytes.slice!(0, bytes.slice!(0, 1).unpack('C')[0])
#     |                                                 |
#     +--- Extracting the filename, and reducing the ---+
#          size of the array, in one go.

#
# -------------------------------------------------
#  Step 5: Write that file to disk.
# -------------------------------------------------
#
# Create a file in the temp directory that has the name
# of the original file.
out = File.open("/tmp/#{name}", "w")

#               +--- The FileSize of the data ---+
#               |                                |
out << bytes[0, bytes.slice!(0, 8).unpack('q')[0]]
#      |                                         |
#      +-- Extracting that many bytes, and put --+
#          it into the file.

# Close the file.
out.close

#
# -------------------------------------------------
#  Step 6: Play the file using mplayer.
# -------------------------------------------------
# 
`mplayer /tmp/#{name}`
