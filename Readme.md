
# About the MIDIHost4RaspberryPi Project
As I added a modern Keyboard to my Synthesizers from the 90's, I realized the gap between the MIDI interfaces: The standard MIDI interface contains a In and Out,sometimes a Through port with a 5 pin DIN socket. The modern equipment contains a USB Connector or it is "wired" by Bluetooth or (W)LAN. 

How to bring it together? 

A RaspberryPi is popular and is used allready in these task. Unfortunally, the RaspianOS - as all LINUX derivates- does not like a hard power off. The command "shutdown -h now" ensures, that the used storage devices will not end up in a memory corruption. 

I know 2 solutions:
1. Shut down the device in the correct manner->type in the shutdown command or 
2. set up the RaspbianOS to run in RAM as a mirror of the SDCard image.

This project uses version (1). Software updates are easy to manage via ssh and are persistent. The MIDIHost4RaspberryPi should be able to work in headless mode. The shutdown is controlled by the clean-shutdown software in addition to the appropriate hardware. 

Both functions, power and standard MIDI interface are put together in one schematic with some electronic parts, that I had available. The MIDIHost4RaspberryPi had to fit into a case of an cheap USB Hub. So I used a RaspberryPi Zero W with an extra WLAN antenna connection and an extra small PCB for the standad MIDI Interface and the power on/off switch facility.


## The Power facility
 The hardware is adopted from the Pimorony ONOFFShim. Use the software according https://github.com/pimoroni/clean-shutdown
 I used the available PMOSFET. The power cable should have low resistance to ensure 5 Volts at the PMOSFET source. 

## The MIDI facility
Standard MIDI requires is a serial signal with the correct baudrate (31250 Bps).

i.e. this works for Raspberry Pi Zero WH:
https://youtu.be/RbdNczYovHQ
#### The Hardware
You can realize a MIDI Interface in many variants. I used the TTL Latch 74LS125, as one gate is required for the ONOffShim too. "MIDISchaltplan-Project.pdf" shows the schematic. 
The schema and PCB is designed in DesignSpark. I could not find a way to publish it without explicit part library path informations. So only the pdf output is published here.

Feel free to realize and customize all the electronic stuff to your needs and skills!

#### The software configuration

sudo raspi-config
Interface Options->disable Serial login shell. enable serial Interface. 

remove in boot/cmdline.txt console=serial0,115200 if exists.
Edit the /boot/config.txt and add:

	enable_uart=1
	dtoverlay=pi3-miniuart-bt
	dtoverlay=midi-uart0


- make sure, the alsa-utils are instelled:
> sudo apt-get install alsa-utils

- install the ttymidi from github:
> git clone https://github.com/cjbarnes18/ttymidi.git

- set up the MIDI baudrate:
> ttymidi -s /dev/ttyAMA0 -b 38400 &

- show the available alsa devices:
>  aconnect -iol

->result:
...
client 128: 'ttymidi'...
	0 'MIDI out  '
	1 'MIDI in  '

ex: connect 128(transmitter) out to 20 (an available MIDI USB device as receiver)
128 represents the midiuart, 20 is the port of my MIDI USB converter:

aconnect 128:0 20:0

or connect midi uart in to midiuart out:

aconnect 128:0 128:1

#### how to play a midi file
(Taken from http://siliconstuff.blogspot.com/2012/08/ttymidi-on-raspberry-pi.html):

	aplaymidi -p 128:1 your_midid_file.mid 

will send a MIDI file to the MIDI out.

#### create a script "startmidi.sh" in order to auto startup:

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

- Issue: The USB MIDI device will be connected if it is present at startup time.

- TODO: create a service to indicate the insertion of an appropriate USB device and connect it to the ttymidi port.
- TODO: Control the MIDIHost4RaspberryPi remote via Web interface.
