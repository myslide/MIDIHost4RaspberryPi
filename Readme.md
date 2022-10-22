## The Power facility
 The hardware is adapted from Pimorony ONOFFShim. Use the software according @https://github.com/pimoroni/clean-shutdown
 I used the available PMOSFET. The power cable should have low resistance to ensure 5 Volts at the PMOS source. 

## The MIDI facility
All that is needed for MIDI is a serial signal with the correct baudrate (31250 Bps).

i.e. this works for Raspberry Pi Zero WH:
https://youtu.be/RbdNczYovHQ

sudo raspi-config
Interface Options->disable Serial login shell. enable serial Interface. 

remove in boot/cmdline.txt console=serial0,115200 if exists.
Edit the /boot/config.txt and add:

	enable_uart=1
	dtoverlay=pi3-miniuart-bt
	dtoverlay=midi-uart0

- make sure, the alsa-utils are instelled:
sudo apt-get install alsa-utils

### install the ttymidi from github:
git clone https://github.com/cjbarnes18/ttymidi.git

#set up the MIDI baudrate:
ttymidi -s /dev/ttyAMA0 -b 38400 &

### show the available alsa devices:
{ aconnect -iol }

->result:
...
client 128: 'ttymidi'...
	0 'MIDI out  '
	1 'MIDI in  '

ex: connect 128(transmitter) out to 20 (an available MIDI USB device as receiver)
128 represents the midiuart, 20 is the port of my MIDI USB converter  
aconnect 128:0 20:0

oder durchleiten von midi uart in auf midiuart out
aconnect 128:0 128:1

### how to play a midi file(Taken from http://siliconstuff.blogspot.com/2012/08/ttymidi-on-raspberry-pi.html):

aplaymidi -p 128:1 your_midid_file.mid will send a MIDI file to the MIDI out.

### create a script "startmidi.sh" in order to auto startup:

	#!/bin/sh
	#cleanup for sure
	aconnect -x
	logger "startmidi.sh now"
	#setup the MIDI specific baudrate
	/home/pi/ttymidi/ttymidi -s /dev/ttyAMA0 -b 38400 &
	#echo set baudrate was done
	logger "midi baudrate set"
	sleep 3
	#echo now connect the midi
	#echo midi in midi out
	aconnect 128:0 128:1
	#echo usb to midi
	#connect the USB midi in to MIDI Out
	#error thrown if usb device not connected
	aconnect 20:0 128:1
	logger "startmidi.sh done"

Set the execution permissions:
	chmod +x startmidi.sh

Keep in mind, these script will be called by root at the startup time. So make sure, the path to ttymidi and startmidi.sh points to the correct location!
#call these script in the autostart:
/etc/rc.local

	...
	logger "startmidi"
	/home/pi/startmidi.sh &
	exit 0#

	#display log messages:
	more /var/log/messages

Issue:The USB MIDI device will be connected if it is present at startup time.
TODO: create a service to indicate the insertion of an appropriate USB device and connect it to the ttymidi port.

## The Hardware Schematic and PCB
The schema and PCB is designed in DesignSpark. Could not find a way to publish it without explicit part library path informations. So only the pdf output is published here.