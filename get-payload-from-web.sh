#!/bin/bash
#
# This script, designed to work with ubuntu (but could easily work with
# OS X or another variety of linux if you remove the apt-get line), will
# get the payload that is used in the piggypack.rb script. 
#
# It does the following:
#
#  1. Makes sure you have gcc, ffmpeg, wget, imagemagick, and python.
#
#  2. Creates a working directory to do everything from.
#
#  3. Downloads a python script, youtube-dl that downloads
#     videos from youtube and saves them to disk.
#
#  4. Download a specific youtube id and extract the audio
#     from it, resulting in an aac file.
#
#  5. Download the 3GPP reference encoder from codingtechnologies.com
#     (snagged before they were bought by Dolby).
#
#  6. Unzips the reference encoder, compiles it.
#
#  7. Waits until the youtube video is downloaded and converted.
#
#  8. Converts the aac to a 48Khz WAV file (needed by the
#     reference encoder).
#
#  9. Generates a mono 12Khz 3GPP file, puts it into the 
#     top directory.
#
# 10. Get the original cat image (see http://qaa.ath.cx/PiggyPack.html)
#
# 11. Convert it to ppm.
#

ytid=dQw4w9WgXcQ
top=$PWD
base=$top/temp
cat=zJ1cx.png



#
# Step 1: Makes sure you have gcc, ffmpeg, wget, and python.
#
sudo apt-get install python gcc ffmpeg wget imagemagick



#
# Step 2: Creates a working directory to do everything from.
#
[ -e $base ] || mkdir $base
cd $base



#
# Step 3: Downloads a python script, youtube-dl that downloads
#         videos from youtube and saves them to disk.
#
if [ ! -e youtube-dl ]; then
  wget "https://github.com/rg3/youtube-dl/blob/master/youtube-dl?raw=true"
  mv "youtube-dl?raw=true" youtube-dl
  chmod +x youtube-dl
fi



#
# Step 4: Download a specific youtube id and extract the audio
#         from it, resulting in an aac file.
#
[ -e ${ytid}.aac ] || ./youtube-dl --extract-audio $ytid &



#
# Step 5: Download the 3GPP reference encoder from codingtechnologies.com
#         (snagged before they were bought by Dolby).
#
if [ ! -e 26411-800-ANSI-C_source_code.zip ]; then
  wget vukkake.com/26411-800-ANSI-C_source_code.zip



  #
  # Step 6: Unzips the reference encoder, compiles it.
  #
  unzip 26411-800-ANSI-C_source_code.zip
  cd 3GPP_enhanced_aacPlus_etsiopsrc_200907/ETSI_aacPlusenc
  make
  cp enhAacPlusEnc $base
  cd $base
fi 



#
# Step 7: Waits until the youtube video is downloaded and converted.
#
while [ ! -e ${ytid}.aac ]; do
  sleep 1
done



#
# Step 8: Converts the aac to a 48Khz WAV file (needed by the
#         reference encoder).
#
[ -e ${ytid}.wav ] || ffmpeg -i ${ytid}.aac -ar 48000 -ac 2 ${ytid}.wav



#
# Step 9: Generates a mono 12Khz 3GPP file, puts it into the 
#         top directory.
#
[ -e $top/astley.3gp ] || ./enhAacPlusEnc ${ytid}.wav $top/astley.3gp 12000 m



#
# Step 10: Get the original cat image.
#
[ -e $cat ] || wget http://i.imgur.com/$cat



#
# Step 11: Convert it to ppm.
#
[ -e $top/astley.ppm ] || convert $cat -compress None $top/astley.ppm
