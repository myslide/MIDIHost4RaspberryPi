#!/bin/sh
#mysli 20221006
#this script wires the individual MIDI devices 
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
