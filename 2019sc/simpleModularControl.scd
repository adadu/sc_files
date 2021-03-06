// Setup io & boot & add proxyspace
(
s.options.device="Fireface 800 (3EC)";
// Fireface w/ 8 ANALOG INS activated
s.options.numInputBusChannels = 8;
s.options.outputStreamsEnabled = "11111111";
// Fireface w/ ADAT OUTS activated
// 0-9=ANALOG 1-10
// 10-11=SPDIF 1-2(11-12)
// 12-19=ADAT OUT 1-8(13-20)
s.options.numOutputBusChannels = 19;
// disable SPDIF outputs
s.options.outputStreamsEnabled = "11111111110011111111";
s.boot;

//PROXYSPACE
//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 2;
)

// SynthDef
(
SynthDef(\dcev, { | note, octave = 0, spo = 12, t_trig, atk=0, sus=0, rel=3, ch = nil, port = 0, calibration = 0.1, midiTune = 0, amp = 1, ampCh = nil, att = 0.001, dur = 1 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	note = note + (octave * spo) + midiTune;
	note = (note / spo) * calibration;
	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
	Out.ar(ampCh, K2A.ar(Lag.kr(envGen)));
}).add;
)

// attempt creating a sin synth to tune to dcenv synth
(
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

Scale.directory;
Tuning.directory;
Scale.whole.degrees

(
var fi = Pseq([70, 82],inf);
var sp = 4;
// Modular PMONO initial values
~mod1 = Pmono(\dcev,
	\ch,16,\ampCh,12, // rme fireface 800 adat channels
	\trig, 1,
	\note, fi, //Pseq([24, 36, 48, 120], inf),
	//\degree, 0,
	//\degree, Pseq((0..20),inf),
	//\scale, Scale.major,
	\dur, sp,
	\amp, 0.3,
	\atk, 0.001,
	\sus, 0.05,
	\rel, 0.5,
	\calibration, 0.1,
	\midiTune, -57, //-26.27,
	\spo, 12,
	\octave, 0,
	).play;

// Modular PMONO initial values
~def1 = Pmono(\compSinTest,
	\out,0, // rme fireface 800 adat channels
	\trig, 1,
	\note, fi, //Pseq([24, 36, 48, 120], inf),
	//\degree, 0,
	//\degree, Pseq((0..20),inf),
	//\scale, Scale.major,
	\dur, sp,
	\amp, 0.30,
	\atk, 0.001,//Pseq([1,5,10],inf)*0.001,
	\sus, 0.05,//Pseq([1,5,10],inf)*0.02,
	\rel, 0.5,//Pseq([10,10,10],inf)*0.04,
	//\calibration, 12,
	//\midiTune, 5,
	//\spo, 12,
	//\octave, Pseq((2..2),inf),
	\octave, 0,
	).play;
)

(
~def1.free;
~mod1.free;
)


(

var durMult = 0.3;

// Modular PMONO initial values
~mod1 = Pmono(\dcev,
	\ch,16,\ampCh,12, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Pseq((5..12).mirror1,inf),
	\scale, Scale.major,
	\dur, Pseq([0.3, 0.1, 0.5, 0.1],inf) *durMult,
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
	\dur, Pseq([0.3, 0.1, 0.5, 0.1],inf) *durMult,
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
	\dur, Pseq([0.3, Rest(0.1), 0.5, 0.1],inf) *durMult,
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