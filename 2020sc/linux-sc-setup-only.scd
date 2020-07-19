# # #
config linux for supercollider/audio/hardwarei'm using pop_os, but likely same on ubuntu 19.10install linux with no encryption
apt install: ubuntustudio-controls, ffado-dbus-server, ffado-mixer-qt4, ffado-tools
open ubuntustudio-contorls, click fix realtime permissions
logout
open ubuntustudio-controls, cpu governor performance, intel boost off
select firewire, sampling rate 48000, jack buffer size/latency 128, peroids 2
linux/supercollider hardware setup(
//set number of inputs and outputs
s.options.numInputBusChannels= 10;
s.options.numOutputBusChannels= 20;

// setup for RME Fireface800 using firewire stack
// rme fireface800 1-10 analog audio out, 10-11 spdif, 12-20 adat 1 out// 0 is ch1, haven't figured out how to enable/disable streams in sc with linux/jack
// connect first to input channels with system
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2,system:capture_3,system:capture_4,system:capture_5,system:capture_6,system:capture_7,system:capture_8,system:capture_9,system:capture_10");
// connect all output channels with system
"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1,system:playback_2,system:playback_3,system:playback_4,system:playback_5,system:playback_6,system:playback_7,system:playback_8,system:playback_9,system:playback_10,system:playback_11,system:playback_12,system:playback_13,system:playback_14,system:playback_15,system:playback_16,system:playback_17,system:playback_18,system:playback_19,system:playback_20");

// setup for using Audient iD4 usb using alsa stack
// "SC_JACK_DEFAULT_INPUTS".setenv("iD4:capture_1,iD4:capture_2");
// "SC_JACK_DEFAULT_OUTPUTS".setenv(iD4:playback_1, iD4:playback_2");
s.boot
)

