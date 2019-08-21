// Setup io & boot
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
s.boot
)

// SynthDef
(
SynthDef(\dcev, { | note, octave = 0, spo = 12, t_trig, atk=0, sus=0, rel=3, ch = nil, port = 0, calibration = 0.1, midiTune = 0, amp = 1, ampCh = nil, att = 0.001, dur = 1 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	note = note;
	note = note + (octave * spo) + midiTune;
	note = (note / spo) * calibration;
	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
	Out.ar(ampCh, K2A.ar(Lag.kr(envGen)));
}).add;
)

Scale.directory;
Tuning.directory;
Scale.whole.degrees

(
// Modular PMONO initial values
~mod1 = Pmono(\dcev,
	\ch,16,\ampCh,12, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Pseq((0..20),inf),
	\scale, Scale.major,
	\dur, Pseq([0.3, 0.1, 0.6, 0.1, Rest(0.1), 0.3, Rest(0.1), 0.3],inf) * 0.5,
	\amp, 0.40,
	\atk, /*0.001,*/ Pseq([1,5,10],inf)*0.1,
	\sus, /*0.05,*/  Pseq([1,5,10],inf)*0.001,
	\rel, /*0.5,*/ Pseq([10,10,10],inf)*0.001,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 21,
	\octave, Pseq((2..7),inf),
	);
)

(
// Modular PMONO initial values
~mod1 = Pmono(\dcev,
	\ch,16,\ampCh,12, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Pseq((5..12).mirror1,inf),
	\scale, Scale.major,
	\dur, Pseq([0.3, 0.1, 0.5, 0.1],inf) * 0.5,
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
)

Scale.directory;
Tuning.directory;
Scale.whole.degrees
(
// Modular PMONO initial values
~mod1 = Pmono(\dcev,
	\ch,16,\ampCh,12, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Prand((0..7),inf),
	\scale, Scale.whole,
	\tuning, \harmonic,
	\dur, /*Pseq([0.3, Rest(0.9)],inf)*/ Pexprand(5.33, 9.79,inf),
	\amp, Pseq((15..35).mirror2, inf) * 0.01,
	\atk, /*0.001,*/ Prand([1,5,9],inf) * 0.1,
	\sus, /*0.05,*/  Prand([1,10,100],inf) *0.01,
	\rel, /*0.5,*/ Prand([1,5,9],inf) *0.1,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq((2..2),inf),
	\port, Pkey(\dur) *2,
);
)

a = ~mod1.play
a.stop
~mod1.free

s.quit;