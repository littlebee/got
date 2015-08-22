# got
God of Thunder (and lightning)

This is a Ruby program I wrote that runs on a Raspberry PI for a friend's art project.  http://recreationallightandmagic.com/nimbus-our-cloud-city-bus/

It simply watches for one of three buttons pressed and sequences relays (120V 25A SSR) with strobes connected to them (lightning button), or play a random media file from one of two directories (thunder and god buttons).   

I used https://github.com/jwhitehorn/pi_piper to interface Ruby with the Raspberry's GPIO.  

For playing media files, it simply shells out to mpg321.   See, http://www.raspberrypi-spy.co.uk/2013/06/raspberry-pi-command-line-audio/  for how to setup command line audio and test it from ssh.  You may need to run alsa mixer to set the volume higher.




