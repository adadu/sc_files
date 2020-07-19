s.quit;

// 4ch stripped down
(
s.quit;

//set number of inputs and outputs
s.options.numInputBusChannels= 10;
s.options.numOutputBusChannels= 10;

// connect first to input channels with system
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2,system:capture_3,system:capture_4,system:capture_5,system:capture_6,system:capture_7,system:capture_8,system:capture_9,system:capture_10");
// connect all output channels with system
// rme fireface800 1-10 analog audio out, 10-11 spdif, 12-20 adat 1 out (0 is ch1, and linux jack won't allow enable/disable streams)
"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1,system:playback_2,system:playback_3,system:playback_4,system:playback_5,system:playback_6,system:playback_7,system:playback_8,system:playback_9,system:playback_10");

// setup for using Audient iD4 usb, would need alsa
// "SC_JACK_DEFAULT_INPUTS".setenv("iD4:capture_1,iD4:capture_2");
// "SC_JACK_DEFAULT_OUTPUTS".setenv(iD4:playback_1, iD4:playback_2");

//increase memory
s.options.memSize = 4 * 8192;

s.boot;
)


Ndef(\q3).fadeTime = 2

(
Ndef(\q3, {|freq=444, pan=0.0|
	var sig = LFTri.ar(freq);
	sig = Pan2.ar(sig, pan);
	sig * 0.3
}).play;
)

Ndef(\q3).copy(\q4);

Ndef(\q3).xset(\freq, rrand(410,320), \pan, rrand(-1.0,1.0));

//Add an fx

(
Ndef(\q3)[1] = \filter -> {|in, pitch=0.5, pitchdispersion=0.1, timedispersion=0.1|
	PitchShift.ar(in, 0.25, pitch, pitchdispersion, timedispersion) }
)

Ndef(\q3).xset(\pitchdispersion,0, \timedispersion, 0);

Ndef(\q3).gui;
Ndef(\q3).clear

Quarks.gui

(
Ndef(\q3)[999] = \pset -> Pbind(\dur, 4,
	\freq,Pwhite(100,500),
	\pan, Prand((-10..10)*0.1,inf)
))
//fades from val to val
(
Ndef(\q3)[999] = \xset -> Pbind(
	\dur, Pwhite(3,6),
	\degree,Pwhite(0,11),
	\scale, Scale.minor,
	\pan, Prand((-10..10)*0.1,inf),
	\pitch, Prand([1,2,0.33,0.66],inf),
	\harmonic,2,
	\root, 1,
	\octave,3
)
)

//see NodeProxy roles
Ndef(\q4).play

// lfo
Ndef(\clfo, {|lfofreq=0.1| LFSaw.kr(lfofreq)})

Ndef(\q4).xmap(\freq,nil)
Ndef(\q4).xmap(\freq, Ndef(\clfo))


