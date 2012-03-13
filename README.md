# PiggyPack

Digital Steganography For Fun And Profit

This is a very rough implementation of lsb image steganography. The ideal
goal was outlined in [this reddit post](http://www.reddit.com/r/programming/comments/q75bz/hiding_things_out_in_the_open/c3vcef3)::

  "A nominal, simple way to piggy back on image uploaders in order to post files of modest size ... I want to explore what that workflow and interfacing would feel like."

In [the thread](http://www.reddit.com/r/programming/comments/q75bz/hiding_things_out_in_the_open/c3vcef3) a number of other projects were highlighted that do similar things already:

 * [FireSteg](https://addons.mozilla.org/en-US/firefox/addon/firesteg/): "A steganography sidebar extension, letting you hide files inside images for covert sharing."

 * [steghide](http://steghide.sourceforge.net/): ... is a steganography program that is able to hide data in various kinds of image- and audio-files. The color- respectivly sample-frequencies are not changed thus making the embedding resistant against first-order statistical tests.

 * [CameraShy](http://sourceforge.net/projects/camerashy/): ... is the only steganographic tool that automatically scans for and delivers decrypted content straight from the Web

 * [File-Encryptor](https://github.com/skaushik92/File-Encryptor). Here's the [description](http://kaushikshankar.com/projects.php#encryption), [reddit thread](http://www.reddit.com/r/programming/comments/k3vg1/my_program_to_share_files_by_sharing_images/) and [citation](http://www.reddit.com/r/programming/comments/q75bz/hiding_things_out_in_the_open/c3vg1hd) where I found out about it.

There's some academic work too:

 * "Jessica Fridrich holds seven patents for reliable detection of least significant bit steganography". [citation](http://www.reddit.com/r/programming/comments/q75bz/hiding_things_out_in_the_open/c3vfna6)

 * "There was a paper about 10 years ago that looked into the idea raised at the end of the article. They crawled the internet and checked images for statistical indications of steganographic techniques, and the only positive hit was an example image used page about steganography. I believe it was this one: https://www.citi.umich.edu/techreports/reports/citi-tr-01-11.pdf but I haven't had a chance to read through it." [citation](http://www.reddit.com/r/programming/comments/q75bz/hiding_things_out_in_the_open/c3vdekm). Also, see http://www.citi.umich.edu/u/provos/stego/ as [cited here](http://www.reddit.com/r/programming/comments/q75bz/hiding_things_out_in_the_open/c3vaw9t)

The article on the technique itself can be found [here](http://qaa.ath.cx/PiggyPack.html).

## Related Work

A number of people have contacted me and made projects inspired from this.

 * Austin Hamman's [stegano.js](https://github.com/tuseroni/stegano.js) is a javascript version for the browser; using base64 encoders, canvas, and a few other nice tricks.  I've thought hard about the problem myself and have run into the same walls that he discloses; primarily that b64encoded data, embedded in an iframe say, "iframe src=data:..." can't do some file-name hinting, like "content-disposition: attachment; filename=" in HTTP. 
