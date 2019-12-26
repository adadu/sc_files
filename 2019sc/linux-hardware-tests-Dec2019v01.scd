
// LINUX audio, Dec 2019
(

o = Server.default.options;
o.outDevice = "USBStreamer";
o.numOutputBusChannels.postln;
o.numOutputBusChannels = 8;
//
// // connect first to input channels with system
// "SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2");
//
// // connect all output channels with system
// "SC_JACK_DEFAULT_OUTPUTS".setenv("USBStreamer");


//PROXYSPACE
//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 2;

s.boot

)


// SynthDef for modular control
(
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
)

(
var durMult = 0.3;

// Modular PMONO initial values
~mod1 = Pmono(\dcev,
	\ch,5,\ampCh,6, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Pseq((5..12).mirror1,inf),
	\scale, Scale.major,
	\dur, Pseq([0.3, 0.1, 0.5, 0.1],inf) * durMult,
	\amp, Pseq((15..75).mirror2, inf) * 0.01, //Pseq([0.20, 0.30, 0.35], inf),
	\atk, /*0.001,*/ Pseq([10,10,10],inf)*0.001,
	\sus, /*0.05,*/  Pshuf([10,10,10],inf)*0.005,
	\rel, /*0.5,*/ Pseq([10,10,10],inf)*0.005,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pshuf((1..1),inf),
	);
)

~mod1.play
~mod1.stop