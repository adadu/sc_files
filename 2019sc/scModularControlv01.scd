// Setup io & boot & add proxyspace
(
//SERVER and BUFFER
//increased buffers for samples
s.options.numBuffers = 1024 * 16;
//this is about 1GB, may vary based on RAM
s.options.memSize=2.pow(20);
2.pow(20).postln;
//boot server
s.boot;

//list audio io devices
ServerOptions.devices;
// CORM is my macOS aggregate device consisting of Audient iD4 + USBStreamer
s.options.device = "CORM";
s.options.outputStreamsEnabled = "1111111111";
s.options.numInputBusChannels = 2;
s.options.numOutputBusChannels = 10;
"INs".postln;
s.options.numInputBusChannels.postln;
"OUTs".postln;
s.options.numOutputBusChannels.postln;
// RME Fireface 800
// s.options.device="Fireface 800 (3EC)";
// Fireface w/ 8 ANALOG INS activated
// s.options.numInputBusChannels = 8;
// s.options.outputStreamsEnabled = "11111111";
// Fireface w/ ADAT OUTS activated
// 0-9=ANALOG 1-10
// 10-11=SPDIF 1-2(11-12)
// 12-19=ADAT OUT 1-8(13-20)
// s.options.numOutputBusChannels = 19;
// disable SPDIF outputs
// s.options.outputStreamsEnabled = "11111111110011111111";

//PROXYSPACE
//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 2;
)

ServerOptions.outDevices
s.quit;

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

// Sine synth or modular modulator
(
SynthDef(\sinOut, { | freq = 440, t_trig, ch = nil, atk=0, sus=0, rel=3, amp = 0.5, ampCh = nil, dur = 1, octave = 0, stepsPerOctave = 12 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	var sig = SinOsc.ar(freq, 0, 1, 0);
	freq = freq + (octave * stepsPerOctave);
	freq = freq / stepsPerOctave;
	Out.ar(ch, sig * envGen);
	//Amp for audio rate modulation
	Out.ar(ampCh, K2A.ar(Lag.kr(amp * envGen)));
}).add;
)

Scale.directory;
Tuning.directory;
Scale.whole.degrees

p.clock.tempo = 200/60;

(
// initial values, internal in-parens vars
var fi, sp, oc;
fi = 40; //Pseq((30..144),inf,12);
sp = 0.51;
oc = Pseq((0..4).mirror1,inf);

// Modular synth
~mod1 = Pmono(\dcev,
	\ch,6,\ampCh,2, // rme fireface 800 adat channels
	\trig, 1,
	\note, fi,
	\dur,sp,
	\amp, 0.5,
	\atk, 0.001,
	\sus, 0.05,
	\rel, 0.4,
	\calibration, 0.0967, //0.0074, 0.10255,
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, oc,
);
~mod1.play;

// sine wave synth from sc
~def1 = Pmono(\sinOut,
	\ch, [0,7],
	\ampCh, 3,
	\trig, 1,
	\note,fi,
	\dur, sp,
	\amp, 0.80,
	\atk, 0.001,
	\sus, 0.05,
	\rel, 0.4,
	\stepsPerOctave, 12,
	\octave, oc,
);
~def1.play;

)

//alter the state of the synth def
~mod1.set(\octave, Pseq((0..4).mirror1,inf).asStream);
~def1.set(\octave, Pseq((0..3).mirror1,inf).asStream);
~mod1.set(\octave, 0);
~def1.set(\octave, 2.33);
~mod1.set(\note, Pseq((40..63).mirror1,inf).asStream, \dur, 0.3, \port, 0.05);
~def1.set(\note, Pseq((100..104).mirror1 * 0.333,inf).asStream, \dur, 4, \amp, 0.6, \atk, 0.001, \rel, 0.7);
~def1.set(\note, Pseq([50,55,60,65,70,75],inf).asStream, \dur, 0.33);
~mod1.set(\note, 25, \dur, 0.33);
~mod1.set(\note, Pseq([25,25/*32,33,35,37*/].mirror1,inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/8, \amp, Pexprand(0.5,0.9,inf).asStream, /*\sus, Pseq((2..9) * 0.03,inf).asStream*/);
~def1.set(\dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream*4, \atk, 0.1, \rel, 0.1, \amp, 0.5);




~mod1.fadeTime = 5;
~def1.fadeTime = 5;

~mod1.release
~def1.release
~mod1.set(\calibration, 0.0171);

(
~def1.free(2);
~mod1.free(5);
//~mod3.free;
)

p.clear;

// utilities

s.queryAllNodes;
s.sendMsg("/n_free", ~def1);
s.sendMsg("/n_free", 3000);



var durMult = 0.3;

// Modular PMONO initial values
~mod1 = Pmono(\dcev,
	\ch,16,\ampCh,12, // rme fireface 800 adat channels
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

// Modular PMONO initial values
~mod2 = Pmono(\dcev,
	\ch,17,\ampCh,13, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Pseq((5..12).mirror1,inf), //5..12
	\scale, Scale.major,
	\dur, Pseq([0.3, 0.1, 0.5, 0.1],inf) * durMult,
	\amp, Pseq((15..85).mirror2, inf) * 0.01, //Pseq([0.20, 0.30, 0.35], inf),
	\atk, /*0.001,*/ Pseq([10,10,10],inf)*0.001,
	\sus, /*0.05,*/  Pshuf([10,10,10],inf)*0.005,
	\rel, /*0.5,*/ Pseq([10,10,10],inf)*0.005,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pshuf((1..1),inf),
	);

// Modular PMONO initial values
~mod3 = Pmono(\dcev,
	\ch,18,\ampCh,14, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Pseq((5..12).mirror1,inf),
	\scale, Scale.major,
	\dur, Pseq([0.3, Rest(0.1), 0.5, 0.1],inf) * durMult,
	\amp, Pseq((25..75).mirror2, inf) * 0.01, //Pseq([0.20, 0.30, 0.35], inf),
	\atk, /*0.001,*/ Pseq([10,10,10],inf)*0.001,
	\sus, /*0.05,*/  Pshuf([10,10,10],inf)*0.005,
	\rel, /*0.5,*/ Pseq([10,10,10],inf)*0.005,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pshuf((2..2),inf),
	);
)


(
// Modular PMONO initial values
~mod1 = Pmono(\dcev,
	\ch,16,\ampCh,12, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Pseq((3..16).mirror2,inf),
	\scale, Scale.minor,
	\dur, Pseq([0.3, Rest(0.9)],inf) * 0.2,
	\amp, Pseq((35..95).mirror2, inf) * 0.01, //Pseq([0.20, 0.30, 0.35], inf),
	\atk, /*0.001,*/ Pseq([1,2,3],inf) * 0.01,
	\sus, /*0.05,*/  Pseq([1,2,3],inf) *0.08,
	\rel, /*0.5,*/ Pseq([1,2,3],inf) *0.1,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq((1..4),inf),
	);
)

(
// 2 osc, over ocatves, mirrored for stereo effect
// Modular PMONO initial values
~mod1 = Pmono(\dcev,
	\ch,16,\ampCh,12, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Pseq((3..16).mirror2,inf),
	\scale, Scale.minor,
	\dur, Pseq([0.3, Rest(0.9)],inf) * 0.19,
	\amp, Pseq((35..85).mirror2, inf) * 0.01, //Pseq([0.20, 0.30, 0.35], inf),
	\atk, /*0.001,*/ Pseq([1,1,1],inf) *0.001,
	\sus, /*0.05,*/  Pseq([1,1,1],inf) *0.2,
	\rel, /*0.5,*/ Pseq([1,1,1],inf) *0.2,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq((1..6),inf),
	);



// Modular PMONO initial values
~mod2 = Pmono(\dcev,
	\ch,17,\ampCh,13, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Pseq((3..16).mirror2,inf),
	\scale, Scale.minor,
	\dur, Pseq([0.3, Rest(0.9)],inf) * 0.19,
	\amp, Pseq((35..95).mirror2, inf) * 0.01, //Pseq([0.20, 0.30, 0.35], inf),
	\atk, /*0.001,*/ Pseq([1,1,1],inf) *0.001,
	\sus, /*0.05,*/  Pseq([1,1,1],inf) *0.2,
	\rel, /*0.5,*/ Pseq([1,1,1],inf) *0.2,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq((1..6),inf),
	);
)

Scale.directory;
Tuning.directory;
Scale.whole.degrees
(
// 2 osc slow morphing pitch and env
~mod1 = Pmono(\dcev,
	\ch,16,\ampCh,12, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Prand((0..7),inf),
	\scale, Scale.whole,
	\tuning, \harmonic,
	\dur, /*Pseq([0.3, Rest(0.9)],inf)*/ Pexprand(5.33, 9.79,inf) * 0.1,
	\amp, Pseq((15..45).mirror2, inf) * 0.01,
	\atk, /*0.001,*/ Prand([1,5,9],inf) * 0.1,
	\sus, /*0.05,*/  Prand([1,10,100],inf) *0.01,
	\rel, /*0.5,*/ Prand([1,5,9],inf) *0.1,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq((2..2),inf),
	\port, Pkey(\dur) *2,
);

~mod2 = Pmono(\dcev,
	\ch,17,\ampCh,13, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Prand((0..7),inf),
	\scale, Scale.whole,
	\tuning, \harmonic,
	\dur, /*Pseq([0.3, Rest(0.9)],inf)*/ Pexprand(5.33, 9.79,inf) * 0.1,
	\amp, Pseq((15..65).mirror2, inf) * 0.01,
	\atk, /*0.001,*/ Prand([1,5,9],inf) * 0.1,
	\sus, /*0.05,*/  Prand([1,10,100],inf) *0.01,
	\rel, /*0.5,*/ Prand([1,5,9],inf) *0.1,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq((2..2),inf),
	\port, Pkey(\dur) *2,
);

~mod3 = Pmono(\dcev,
	\ch,18,\ampCh,14, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Prand((0..7),inf),
	\scale, Scale.whole,
	\tuning, \harmonic,
	\dur, /*Pseq([0.3, Rest(0.9)],inf)*/ Pexprand(5.33, 9.79,inf) * 0.1,
	\amp, Pseq((15..65).mirror2, inf) * 0.01,
	\atk, /*0.001,*/ Prand([1,5,9],inf) * 0.1,
	\sus, /*0.05,*/  Prand([1,10,100],inf) *0.01,
	\rel, /*0.5,*/ Prand([1,5,9],inf) *0.1,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq((2..4),inf),
	\port, Pkey(\dur) *2,
);
)

(
~mod1.free;
~mod2.free;
~mod3.free;
)
s.quit;

