s.quit

(
//set number of inputs and outputs
s.options.numInputBusChannels= 10;
s.options.numOutputBusChannels= 20;

// connect first to input channels with system
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2,system:capture_3,system:capture_4,system:capture_5,system:capture_6,system:capture_7,system:capture_8,system:capture_9,system:capture_10"); //note that i've only enabled 2
// connect all output channels with system
// rme fireface800 1-10 analog audio out, 10-11 spdif, 12-20 adat 1 out (0 is ch1, and linux jack won't allow enable/disable streams)
"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1,system:playback_2,system:playback_3,system:playback_4,system:playback_5,system:playback_6,system:playback_7,system:playback_8,system:playback_9,system:playback_10,system:playback_11,system:playback_12,system:playback_13,system:playback_14,system:playback_15,system:playback_16,system:playback_17,system:playback_18,system:playback_19,system:playback_20");

// setup for using Audient iD4 usb, would need alsa
// "SC_JACK_DEFAULT_INPUTS".setenv("iD4:capture_1,iD4:capture_2");
// "SC_JACK_DEFAULT_OUTPUTS".setenv(iD4:playback_1, iD4:playback_2");


//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 2;

s.boot
)

(
// SynthDef for modular control, one channel for pitch cv, the other for envelope-amp combo
SynthDef(\dcev, { | note=60, octave = 0, stepsPerOctave = 12, t_trig, atk=0, sus=0, rel=3, ch = nil, port = 0, calibration = 0.1, midiTune = 0, amp = 1, ampCh = nil, dur = 1 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	note = note;
	note = note + (octave * stepsPerOctave) + midiTune;
	note = (note / stepsPerOctave) * calibration;
	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
	Out.ar(ampCh, K2A.ar(Lag.kr(envGen)));
}).add;

// SynthDef for envelope control
SynthDef(\dcctl, { | t_trig, atk=0, sus=0, rel=3, calibration = 0.1, amp = 1, ampCh = nil, dur = 1 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	Out.ar(ampCh, K2A.ar(Lag.kr(envGen)));
}).add;

// a simple sine synth as a modulator or to use to tune to dcev synth
SynthDef(\compSinTest, { | note, out=nil, t_trig, atk=0, sus=0, rel=3, amp = 0.5, dur = 1, midiTune = 0, spo = 12, calibration = 1, octave = 0 |
	var env, envGen, sig;
	note = note + (octave * spo);
	sig = SinOsc.ar(note);
	env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	envGen = EnvGen.ar(env, t_trig, amp, timeScale: dur);
	env = envGen;
	sig = sig * env;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;

)

(
//vars
~gdur=0.3;
~gamp=1.0;
~gatk=0.001;
~gsus=0.2;
~grel=0.1;
~goct=Pseq([1,1,1,6,1,1,1,9],inf);
)

Ndef(\mod1).play;
Ndef(\mod1).fadeTime = 4;
Ndef(\mod1).clear(2);

//here i'm trying to mod this bs to work like the corm worked to run the synths through the ~freeze effect
(
~mod1=Pmono(\dcev, \ch,12,\ampCh,13, \calibration, 0.094, //0.0074, 0.10255,
	\midiTune, -24, \trig, 1, \stepsPerOctave, 12,
	\dur, Prand([1,2,2,4,1] * 0.0825, inf), \degree, Prand((0..10)+10,inf),
	\amp, ~gamp, \atk, ~gatk, \sus, ~gsus, \rel, ~grel,
	\octave, ~goct);
)

(
Ndef(\mod1, Pmono(\dcev, \ch,12,\ampCh,13, \calibration, 0.094, //0.0074, 0.10255,
	\midiTune, -24, \trig, 1, \stepsPerOctave, 12,
	\dur, Prand([1,2,2,4,1] * 0.125, inf), \degree, Prand((0..3)+30,inf),
	\amp, ~gamp, \atk, ~gatk, \sus, ~gsus, \rel, ~grel,
	\octave, ~goct));
)

Ndef(\mod2).play;
Ndef(\mod2).fadeTime = 1;
Ndef(\mod2).clear(4);

(
Ndef(\mod2, Pmono(\dcev, \ch,16,\ampCh,17, \calibration, 0.094, //0.0074, 0.10255,
	\midiTune, -24, \trig, 1, \stepsPerOctave, 12,
	\dur, Prand([1,2,2,4,1] * 0.125, inf), \degree, Prand((0..10)+10,inf), \port, Pseq([0,2,0,0,0,4] *0.1,inf),
	\amp, ~gamp, \atk, ~gatk, \sus, ~gsus, \rel, ~grel,
	\octave, ~goct)););
)


// Simple test of Mads default SC synth
Ndef(\mads, Pbind(\dur, Prand([1,2,2,1,1] * 0.125, inf), \degree, Prand((0..10)+10,inf,4), \pan,Pshuf((-99..99)*0.01,inf), \release,Pseq((1..2) * 0.5,inf),  \cutoff, Prand((50..15000),inf), \rq, Prand((0..30)*0.01,inf), \out,0));
Ndef(\mads).play;
Ndef(\mads).clear;
Ndef(\mads, { VarSaw.ar([41,40], Ndef.ar(\mads) * Ndef.ar(\rock)) });
Ndef(\rock, Pbind(\dur, Prand([1,2,2,1,1] * 0.125, inf), \degree, Prand((0..10)+10,inf,4)));
Ndef(\rock).play;
Ndef(\rock).clear;


(
~freeze = SynthDef(\fftFreeze, {
    arg out = 0;
	var in, chain;
	in = SoundIn.ar(6);
	chain = FFT({ LocalBuf(1024) }, in);
	chain = PV_MagFreeze(chain, LFNoise0.kr([LFNoise0.kr(2).exprange(2,10), LFNoise0.kr(2).exprange(2,10)]));
	Out.ar(out, Pan2.ar(IFFT(chain), 0, 0.3));// inverse FFT
}).add;
)
~vox = ~freeze;
~freeze.set(\out, 0);
~freeze.set(\out,
~freeze.free(3);

~freeze.free;

//grain in tests that don't work

Ndef(\grn).play;
~in=7;
Ndef(\grn, { GrainIn.ar(numChannels: 2, trigger: Dust.kr(2), dur: 1, in:~in, pan: 0, envbufnum: -1, maxGrains: 32, mul: 1, add: 0) });


(
var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\in_grain_test, { |out, gate = 1, amp = 0.5, envbuf|
    var pan, env;
    // use mouse x to control panning
    pan = MouseX.kr(-1, 1);
    env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        levelScale: amp,
        doneAction: Done.freeSelf);
    Out.ar(out,
		GrainIn.ar(2, Impulse.kr(32), 1, 7, pan, envbuf) * env)
}).add;

)

x = Synth(\in_grain_test, [\envbuf, -1])
