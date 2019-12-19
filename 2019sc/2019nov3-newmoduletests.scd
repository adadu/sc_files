// JEA
// 2019nov3

(
//Define the number of inputs and outputs for the ES-8
o = Server.local.options;
// Fireface w/ ADAT OUTS activated
// s.options.numOutputBusChannels = 20;
// disable SPDIF outputs
o.outputStreamsEnabled = "11111111110011111111";
// 0-9=ANALOG 0-9
// 10-11=SPDIF 1-2
// 12-19=ADAT OUT 1-8
o.numOutputBusChannels = 20;
// 0-9=ANALOG 0-9
o.numInputBusChannels = 10;
//SERVER and BUFFER
//increased buffers for samples
o.numBuffers = 1024 * 16;
//set memory size
//this is about 1GB, may vary based on RAM
o.memSize=2.pow(20);
Server.internal.options.memSize =2.pow(20);
//load the ES-3 Device
o.device = "ES-3";

//PROXYSPACE
//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 1;

//boot the server
s.boot;
)

s.quit;

{ Pan2.ar(Mix(LFSaw.ar({rrand(40,8000)}!50,mul:0.01)),{rrand(-0.999,0.999)}!50,level:0.5)}.play;



// SynthDef for modular control
(
SynthDef(\dcev, { | note=60, octave = 0, stepsPerOctave = 12, t_trig, atk=0, sus=0, rel=3, ch = nil, port = 0, calibration = 0.1, midiTune = 0, amp = 1, ampCh = nil, att = 0.001, dur = 1 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	note = note;
	note = note + (octave * stepsPerOctave) + midiTune;
	note = (note / stepsPerOctave) * calibration;
	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
	Out.ar(ampCh, K2A.ar(Lag.kr(envGen)));
}).add;

// sc virtual osc
SynthDef(\sawd, { | freq = 440, t_trig, ch = nil, atk=0, sus=0, rel=3, amp = 0.5, ampCh = nil, dur = 1, octave = 0, stepsPerOctave = 12 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	var sig = LFSaw.ar(freq, 0, 1, 0);
	freq = freq + (octave * stepsPerOctave);
	freq = freq / stepsPerOctave;
	Out.ar(ch, sig * envGen);
	//Amp for audio rate modulation
	//Out.ar(ampCh, K2A.ar(Lag.kr(amp * envGen)));
}).add;

//can i make a multi poly synth to multiply a modular signal?
SynthDef(\sawedoff, { | f1=40, f2=8000, xm=50, ch=33 |
	var mult = 1 / xm;
	var sig = Mix(LFSaw.ar({rrand(f1,f2)}!xm,mul:mult));
	Out.ar(ch, sig);
	//{ Mix(LFSaw.ar({rrand(40,8000)}!50,mul:0.01)) !2}.play;
}).add;
)

Quarks.gui

// Synthdefs
(
// Modular synth
~mod1 = Pmono(\dcev,
	\ch,12,\ampCh,16, // rme fireface 800 adat channels
	\trig, 1,
	\note, Pshuf((30..80).mirror,inf,12),
	\dur, Prand((10..50), inf) * Phprand(0.1,0.001,inf).asStream,
	\amp, Phprand(0.111,0.99,inf),
	\atk, Phprand(0.001,0.699,inf),
	\sus, Phprand(0.151,0.315,inf),
	\rel, Phprand(0.001,0.515,inf),
	\calibration, 0.0967, //0.0074, 0.10255,
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, Phprand(1,8,inf),
	\port,0.3,
);

// Modular synth 2
~mod2 = Pmono(\dcev,
	\ch,13,\ampCh,17, // rme fireface 800 adat channels
	\trig, 1,
	\note, Pshuf((30..80).mirror,inf,12),
	\dur, Prand((10..50), inf) * Phprand(0.1,0.001,inf).asStream,
	\amp, Phprand(0.111,0.99,inf),
	\atk, Phprand(0.001,0.699,inf),
	\sus, Phprand(0.151,0.315,inf),
	\rel, Phprand(0.001,0.515,inf),
	\calibration, 0.0967, //0.0074, 0.10255,
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, Phprand(1,8,inf),
	\port,0.3,
);


// Modular synth 3
~mod3 = Pmono(\dcev,
	\ch,14,\ampCh,18, // rme fireface 800 adat channels
	\trig, 1,
	\note, Prand((0..11.99).mirror,inf,3),
	\dur, Phprand(0.0311,8.98,inf),
	\amp,Phprand(0.011,0.99,inf),
	\atk, Phprand(0.001,0.515,inf),
	\sus, Phprand(0.001,0.515,inf),
	\rel, Phprand(0.001,0.515,inf),
	\calibration, 0.0967, //0.0074, 0.10255,
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave,Phprand(1,5,inf),
	\port,0.1,
);

~mod4 = Pmono(\dcev,
	\ch,15,\ampCh,19, // rme fireface 800 adat channels
	\trig, 1,
	\note, Prand((0..11.99).mirror,inf,3),
	\dur, Phprand(0.0311,8.98,inf),
	\amp, Phprand(0.011,0.99, inf),
	\atk, Phprand(0.001,0.515,inf),
	\sus, Phprand(0.001,0.515,inf),
	\rel, Phprand(0.001,0.515,inf),
	\calibration, 0.0967, //0.0074, 0.10255,
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave,Phprand(1,5,inf),
	\port,0.1,
);
)

~mod1.play;
~mod2.play;
~mod3.play;
~mod4.play;

~mod1.free(2);
~mod2.free(2);
~mod3.free(4);
~mod4.free(4);

~mod1 = ~mod1 * 