#!/bin/bash

#set jack_out and jack_in as default sink and source respectively
#this redirects any new sound source (aka "sounds") and input to jack
pacmd set-default-sink jack_out
pacmd set-default-source jack_in

#let's get all the active sinks
inputs=$(pacmd list-sink-inputs | grep index | awk '{print $2}')

#let's move current active sinks to jack_out
for i in $inputs
do 
	pacmd move-sink-input $i jack_out &> /dev/null
done
