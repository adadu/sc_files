
/*
2020feb20
an attempt at creating  proxy synth of modular control, converting var sp to ~sp. As a way to update variable that multiple pmonos use.

2020feb13
connect hardware (thunderbolt 3/thunderbolt 2 > thunderbolt 2/firewire 800 > firewire 800 cable > rme fireface 800
boot computer, turn on audio interface
open ubuntustudio-controls, cpu governor performance, intel boost off
select firewire, sampling rate 48000, jack buffer size/latency 128, peroids 2
open ffado mixer for graphical control of most rme fireface800 settings
ctrl-m for levels, right click to select 'always on top'
TO DO:
? disable pulse to jack bridge and bridge usb devices ?? this may not be necessary
? can midi also work?
*/

s.quit

(
s.quit;
//set number of inputs and outputs
s.options.numInputBusChannels= 10;
s.options.numOutputBusChannels= 20;

// connect first to input channels with system
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2"); //note that i've only enabled 2
// connect all output channels with system
// rme fireface800 1-10 analog audio out, 10-11 spdif, 12-20 adat 1 out (0 is ch1, and linux jack won't allow enable/disable streams)
"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1,system:playback_2,system:playback_3,system:playback_4,system:playback_5,system:playback_6,system:playback_7,system:playback_8,system:playback_9,system:playback_10,system:playback_11,system:playback_12,system:playback_13,system:playback_14,system:playback_15,system:playback_16,system:playback_17,system:playback_18,system:playback_19,system:playback_20");

// setup for using Audient iD4 usb, would need alsa
// "SC_JACK_DEFAULT_INPUTS".setenv("iD4:capture_1,iD4:capture_2");
// "SC_JACK_DEFAULT_OUTPUTS".setenv(iD4:playback_1, iD4:playback_2");
p = ProxySpace.push(s.boot);

//s.boot;
)

// Simple test of Mads default SC synth
Ndef(\mads, Pbind(\dur, Prand([1,2,2,1,1] * 0.125, inf), \degree, Prand((0..10)+10,inf,4), \pan,Pshuf((-99..99)*0.01,inf), \release,Pseq((1..10) * 0.5,inf),  \cutoff, Prand((50..15000),inf), \rq, Prand((0..30)*0.01,inf), \out,2));
Ndef(\mads).play;
Ndef(\mads, { VarSaw.ar([600,635], Ndef.ar(\mads), 0.2) });

(
//microkontrol
k = MKtl(\nk2, "*trol2");

//offset synthdef
SynthDef(\offset0, { arg ch = nil, offset = -1;
	Out.ar(ch, K2A.ar(offset));
}).add;

// Offsets for ES-3 outputs
//ES3,     (10 & 11 spdif)                                                         // 0V offsets
~ch12 = Pmono(\offset0, \ch, 12, \offset, Pdefn(\ch12off, -0.0001));              // -0.0001
~ch13 = Pmono(\offset0, \ch, 13, \offset, Pdefn(\ch13off, 0.00169));             //  0.00169
~ch14 = Pmono(\offset0, \ch, 14, \offset, Pdefn(\ch14off, -0.0034));            // -0.0035
~ch15 = Pmono(\offset0, \ch, 15, \offset, Pdefn(\ch15off, -0.0002));           // -0.0002
~ch16 = Pmono(\offset0, \ch, 16, \offset, Pdefn(\ch16off, 0));                // 0
~ch17 = Pmono(\offset0, \ch, 17, \offset, Pdefn(\ch17off, 0.0001));          // 0.0001
~ch18 = Pmono(\offset0, \ch, 18, \offset, Pdefn(\ch18off, -0.0001));        // -0.0001
~ch19 = Pmono(\offset0, \ch, 19, \offset,Pdefn(\ch19off, -0.0018));        // -0.0018

//run ALL offsets w nanokontrol2
k.elAt(\tr, \mset).action_({  |elem|
    if(elem.value > 0)
	{ o = [~ch12.play, ~ch13.play, ~ch14.play, ~ch15.play, ~ch16.play, ~ch17.play, ~ch18.play, ~ch19.play]; }
	{ o[0].stop; o[1].stop; o[2].stop; o[3].stop; o[4].stop; o[5].stop; o[6].stop; o[7].stop; }
});
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
k.elAt(\tr, \play).action_({  |elem|
    if(elem.value > 0)
{
// generate Pmonos for 2 voices, with initial settings based on variables to keep them related

// variables that both modular voices use and riff off of
~fi = 2;//Prand([2,3,4],inf);
~sp = 0.3;//2 *Prand([1,2,4,1,1] * 0.125, inf);
~oc = Pseq((3..5),inf);
~atk = Prand([100,200,300,100,1,1] * 0.001, inf);
~sus = Pkey(\dur,inf) *0.5;//0.2;//0.15;
~rel = Prand([1,2,3,1] * 0.5, inf);

// ***************** VOICE ONE ********************

// Modular synth, a channel for pitch and a channel for envelope-amp
~mod1 = Pmono(\dcev,
	\ch,16,\ampCh,17, // rme fireface 800 adat channels
	\trig, 1,
	\degree, ~fi,
	\dur, ~sp,
	\amp, 0.5,
	\atk, ~atk,
	\sus, ~sus,
	\rel, ~rel,
	\calibration, 0.094,
	//other calibrations that have worked on different ch: 0.0074, 0.10255,
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, ~oc,
).play;

// Virtual oscillator for FM modulation
~vir1 = Pmono(\compSinTest,
	\out,18,
	\trig, 1,
	\degree, ~fi * 0.66, //Pseq([24, 36, 48, 120], inf),
	//\scale, Scale.major,
	\dur, ~sp * 10,
	\amp, 0.49,
	\atk, ~atk*5,//Pseq([1,5,10],inf)*0.001,
	\sus, ~sus,//Pseq([1,5,10],inf)*0.02,
	\rel, ~rel*2,//Pseq([10,10,10],inf)*0.04,
	//\calibration, 12,
	//\midiTune, 5,
	//\spo, 12,
	\octave, ~oc+4,
).play;

// Env Modulator

~env1 = Pmono(\dcctl,
	\ampCh,19,
	\trig,1,
	\dur,~sp*4,
	\amp,0.29,
	\atk,~atk,
	\sus,~sus,
	\rel,~rel,
).play;

// ***************** VOICE TWO ********************

~mod2 = Pmono(\dcev,
	\ch,12,\ampCh,13, // rme fireface 800 adat channels
	\trig, 1,
	\degree, ~fi,
	\dur,~sp,
	\amp, 0.5,
	\atk, ~atk,
	\sus, ~sus,
	\rel, ~rel,
	\calibration, Pdefn(\cal2, 0.1001), //0.0074, 0.10255,
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, ~sp,
).play;


~vir2 = Pmono(\compSinTest,
	\out,14, // rme fireface 800 adat channels
	\trig, 1,
	\degree, ~fi+4 * 0.66, //Pseq([24, 36, 48, 120], inf),
	\dur, ~sp * 10,
	\amp, 0.49,
	\atk, ~atk*5,//Pseq([1,5,10],inf)*0.001,
	\sus, ~sus,//Pseq([1,5,10],inf)*0.02,
	\rel, ~rel*2,//Pseq([10,10,10],inf)*0.04,
	//\calibration, 12,
	//\midiTune, 5,
	//\spo, 12,
	\octave, ~sp+2,
).play;

~env2 = Pmono(\dcctl,
	\ampCh,15,
	\trig,1,
	\dur,~sp*4,
	\amp,0.29,
	\atk,~atk,
	\sus,~sus,
	\rel,~rel,
).play;

}
{ ~mod1.stop; ~mod2.stop; ~vir1.stop; ~vir2.stop; ~env1.stop; ~env2.stop; }
});
)

~z.play;
~z = ~sp;
~sp =0.1;

currentEnvironment.postln;

Pdefn(\cal2, 0.9);

(
~mod1.stop;
~mod2.stop;
~vir1.stop;
~vir2.stop;
~env1.stop;
~env2.stop;
)

s.quit