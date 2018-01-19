s.quit;

(
// hardware ssettings for 828 & es3
ServerOptions.devices;
s.options.device = "MOTU 828";
s.options.numOutputBusChannels = 18;
s.options.outputStreamsEnabled = "111111110011111111";
s.options.memSize = 16384;
s.options.numOutputBusChannels.postln;
s.boot;
)

(
//SYNTHDEFS - offsets & controller init

//microkontrol
k = MKtl(\nk2, "*trol2");

//offset synthdef
SynthDef(\offset0, { arg ch = nil, offset = -1;
	Out.ar(ch, K2A.ar(offset));
}).add;

//channel offsets
//828mk1                                                                                             // 0V offsets
~ch0 = Pmono(\offset0, \ch, 0, \offset, Pdefn(\ch0off, 0));                 // 0.003
~ch1 = Pmono(\offset0, \ch, 1, \offset, Pdefn(\ch1off, 0));                // 0.001
~ch2 = Pmono(\offset0, \ch, 2, \offset, Pdefn(\ch2off, -1));             // 0.015
~ch3 = Pmono(\offset0, \ch, 3, \offset, Pdefn(\ch3off, -1));            // -0.006
~ch4 = Pmono(\offset0, \ch, 4, \offset, Pdefn(\ch4off, -1));           // -0.001
~ch5 = Pmono(\offset0, \ch, 5, \offset, Pdefn(\ch5off, -1));          // 0.001
~ch6 = Pmono(\offset0, \ch, 6, \offset, Pdefn(\ch6off, -1));         // -0.006
~ch7 = Pmono(\offset0, \ch, 7, \offset, Pdefn(\ch7off, -1));        // 0.008
//ES3,     (8 & 9 spdif)                                                                                         // 0V offsets
~ch10 = Pmono(\offset0, \ch, 10, \offset, Pdefn(\ch10off, -0.0001));              // -0.0001
~ch11 = Pmono(\offset0, \ch, 11, \offset, Pdefn(\ch11off, 0.00169));             //  0.00169
~ch12 = Pmono(\offset0, \ch, 12, \offset, Pdefn(\ch12off, -0.0034));            // -0.0035
~ch13 = Pmono(\offset0, \ch, 13, \offset, Pdefn(\ch13off, -0.0002));           // -0.0002
~ch14 = Pmono(\offset0, \ch, 14, \offset, Pdefn(\ch14off, 0));                     // 0
~ch15 = Pmono(\offset0, \ch, 15, \offset, Pdefn(\ch15off, 0.0001));           // 0.0001
~ch16 = Pmono(\offset0, \ch, 16, \offset, Pdefn(\ch16off, -0.0001));        // -0.0001
~ch17 = Pmono(\offset0, \ch, 17, \offset,Pdefn(\ch17off, -0.0018));        // -0.0018

//run ALL offsets w nanokontrol2
k.elAt(\tr, \mset).action_({  |elem|
    if(elem.value > 0)
	{ o = [~ch0.play, ~ch1.play, ~ch2.play, ~ch3.play, ~ch4.play, ~ch5.play, ~ch6.play, ~ch7.play,
		     ~ch10.play, ~ch11.play, ~ch12.play, ~ch13.play, ~ch14.play, ~ch15.play, ~ch16.play, ~ch17.play]; }
	{ o[0].stop; o[1].stop; o[2].stop; o[3].stop; o[4].stop; o[5].stop; o[6].stop; o[7].stop;
		 o[8].stop; o[9].stop; o[10].stop; o[11].stop; o[12].stop; o[13].stop; o[14].stop; o[15].stop; } });

//maleable envelopes
SynthDef(\zero, { | note, octave = 0, spo = 12, t_trig, ch = nil, port = 0, calibration = 0.1, midiTune = 0, amp = 1,
	ampCh = nil, att = 0.001, dur = 1 |
	var level = amp * 2.6;
	var env = Env([0.001, 0.999, 0.001], [att, 1.0-att], [\lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	note = note;
	note = note + (octave * spo) + midiTune;
	note = (note / spo) * calibration;
	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
	Out.ar(ampCh, K2A.ar(Lag.kr(envGen)));
}).add;

//snappy envelopes
SynthDef(\pulse, { | note, octave = 0, spo = 12, t_trig, ch = nil, port = 0, calibration = 0.1, midiTune = 0, amp = 1,
	ampCh = nil, att = 0.001, dec = 0.02, sus = 0.4, rel = 0.579, curve = 2, dur = 1 |
	var level = amp * 2.6;
	var env = Env.adsr(att, dec, sus, rel, 1, -4);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	note = note;
	note = note + (octave * spo) + midiTune;
	note = (note / spo) * calibration;
	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
	Out.ar(ampCh, K2A.ar(Lag.kr(envGen)));
}).add;

//AUDIO sine out
SynthDef(\sinOut, { | freq = 440, t_trig, ch = nil, amp = 1, ampCh = nil, att = 0.01, dur = 1 |
	var env = Env([0.001, 0.99, 0.001], [att, 1.0-att], [\lin, \lin]);
	var level = amp * 2.6;
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	Out.ar(ch, SinOsc.ar(freq, 0, 1, 0));
	Out.ar(ampCh, K2A.ar(Lag.kr(amp * envGen)));
}).add;

//END SYNTHDEFS
)

(
//INIT PDEFNS

//virtual osc modulator for zerosc
(
~zm = Pmono(
	\sinOut,
	\ch, 10,
	\ampCh, 2,
	\trig, 1,
	\midinote, Pdefn(\znote, 60),
	\ctranspose, Pdefn(\zoct, 0),
	\dur, Pdefn(\zdur, 1),
	\port, Pdefn(\zport, 0),
	\att, Pdefn(\zatt, 0.001),
	\amp, Pdefn(\zamp, 1),
	\stepsPerOctave, Pdefn(\zspo, 12),
	\stretch, Pdefn(\zstretch, 1.0),
);


//zerosc
~v1 = Pmono(
	\zero,
	\ch, 11,
	\ampCh, 3,
	\trig, 1,
	\note, Pdefn(\v1note, 60),
	\octave, Pdefn(\v1oct, 0),
	\dur, Pdefn(\v1dur, 1),
	\port, Pdefn(\v1port, 0),
	\att, Pdefn(\v1att, 0.001),
	\amp, Pdefn(\v1amp, 1),
	\calibration, Pdefn(\v1cal, 0.09773),
	\midiTune, Pdefn(\v1mt, -23.61),
	\spo, Pdefn(\v1spo, 12),
	\stretch, Pdefn(\v1stretch, 1.0),
);

//mini osc w snappy env
~v2 = Pmono(
	\pulse,
	\ch, 12,
	\ampCh, 4,
	\trig, 1,
	\note, Pdefn(\v2note, 60),
	\octave, Pdefn(\v2oct, 0),
	\dur, Pdefn(\v2dur, 1),
	\port, Pdefn(\v2port, 0),
	\att, Pdefn(\v2att, 0.001),
	\dec, Pdefn(\v2dec, 0.9),
	\sus, Pdefn(\v2sus, 0.01),
	\rel, Pdefn(\v2rel, 0.9),
	\curve, Pdefn(\v2curv, 4),
	\amp, Pdefn(\v2amp, 1),
	\calibration, Pdefn(\v2cal, 0.09773),
	\midiTune, Pdefn(\v2mt, -23.61),
	\spo, Pdefn(\v2spo, 12),
	\stretch, Pdefn(\v2stretch, 1.0),
);

//mini osc w regular env
~v22 = Pmono(
	\zero,
	\ch, 12,
	\ampCh, 4,
	\trig, 1,
	\note, Pdefn(\v22note, 60),
	\octave, Pdefn(\v22oct, 0),
	\dur, Pdefn(\v22dur, 1),
	\port, Pdefn(\v22port, 0),
	\att, Pdefn(\v22att, 0.001),
	\amp, Pdefn(\v22amp, 1),
	\calibration, Pdefn(\v22cal, 0.09773),
	\midiTune, Pdefn(\v22mt, -23.61),
	\spo, Pdefn(\v22spo, 12),
	\stretch, Pdefn(\v22stretch, 1.0),
);

//q106 osc 1
~v3 = Pmono(
	\zero,
	\ch, 13,
	\ampCh, 5,
	\trig, 1,
	\note, Pdefn(\v3note, 60),
	\octave, Pdefn(\v3oct, 0),
	\dur, Pdefn(\v3dur, 1),
	\port, Pdefn(\v3port, 0),
	\att, Pdefn(\v3att, 0.001),
	\amp, Pdefn(\v3amp, 1),
	\calibration, Pdefn(\v3cal, 0.0976),
	\midiTune, Pdefn(\v3mt, -23.64),
	\spo, Pdefn(\v3spo, 12),
	\stretch, Pdefn(\v3stretch, 1.0),
);

//q106 osc 2
~v4 = Pmono(
	\zero,
	\ch, 14,
	\ampCh, 6,
	\trig, 1,
	\note, Pdefn(\v4note, 60),
	\octave, Pdefn(\v4oct, 0),
	\dur, Pdefn(\v4dur, 1),
	\port, Pdefn(\v4port, 0),
	\att, Pdefn(\v4att, 0.001),
	\amp, Pdefn(\v4amp, 1),
	\calibration, Pdefn(\v4cal, 0.097086),
	\midiTune, Pdefn(\v4mt, -23.61),
	\spo, Pdefn(\v4spo, 12),
	\stretch, Pdefn(\v4stretch, 1.0),
);

//zm copy
~v5 = Pmono(
	\sinOut,
	\ch, 15,
	\ampCh, 7,
	\trig, 1,
	\midinote, Pdefn(\znote, 60),
	\ctranspose, Pdefn(\zoct, 0),
	\dur, Pdefn(\zdur, 1),
	\port, Pdefn(\zport, 0),
	\att, Pdefn(\zatt, 0.001),
	\amp, Pdefn(\zamp, 1),
	\stepsPerOctave, Pdefn(\zspo, 12),
	\stretch, Pdefn(\zstretch, 1.0),
);
//END INIT PDEFNS
)

//start / stop w play button
(
k.elAt(\tr, \play).action_({  |elem|
    if(elem.value > 0)
	{ q = ~zm.play(quant:1); r = ~v1.play(quant:1); t = ~v2.play(quant:1); v = ~v3.play(quant:1); z = ~v4.play(quant:1); x = ~v5.play(quant:1); }
	{ q.stop; r.stop; t.stop; v.stop; z.stop; x.stop; } });
)

//start
(
q = ~zm.play(quant:1);
r = ~v1.play(quant:1);
t = ~v2.play(quant:1);
v = ~v3.play(quant:1);
z = ~v4.play(quant:1);
x = ~v5.play(quant:1);
)

//stop
(
q.stop;
r.stop;
t.stop;
v.stop;
z.stop;
x.stop;
)

s.freeAll;

// tuning test slow
(
k.elAt(\bt, \S, \1).action_({  |elem|
    if(elem.value > 0)
	{ (
		//var only - for tuning
		~testNote = Prand([40, \rest, 44, 43, 38, 37, 35, 54], inf);
		~testOct = 0; //Pseq([0,\rest, 8, \rest],inf);
		~testDur = 0.5; // Pseq([6, 1],inf); //Pseq((8..1) * 0.05,inf); //Pexprand(0.04, 0.09, inf); //0.4;
		~testAmp = 1; //Pexprand(1.0, 1.0, inf); //0.5;
		~testAtt = 0.001; //Pgauss(0.001, 0.999, inf);
		~testStretch = 1.0;

		//run pdfns
		// zm
		Pdefn(\znote, ~testNote);
		Pdefn(\zoct, ~testOct * 12);
		Pdefn(\zdur, ~testDur);
		Pdefn(\zamp, ~testAmp);
		Pdefn(\zatt, ~testAtt);
		// v1
		Pdefn(\v1note, ~testNote);
		Pdefn(\v1oct, ~testOct);
		Pdefn(\v1dur, ~testDur);
		Pdefn(\v1amp, ~testAmp);
		Pdefn(\v1att, ~testAtt);
		Pdefn(\v1port, 0);
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, ~testOct);
		Pdefn(\v2dur, ~testDur);
		Pdefn(\v2amp, ~testAmp);
		Pdefn(\v2att, ~testAtt);
		Pdefn(\v2port, 0);
		// v3
		Pdefn(\v3note, ~testNote);
		Pdefn(\v3oct, ~testOct);
		Pdefn(\v3dur, ~testDur);
		Pdefn(\v3amp, ~testAmp);
		Pdefn(\v3att, ~testAtt);
		// v4
		Pdefn(\v4note, ~testNote);
		Pdefn(\v4oct, ~testOct);
		Pdefn(\v4dur, ~testDur);
		Pdefn(\v4amp, ~testAmp);
		Pdefn(\v4att, ~testAtt);
		// v5
		Pdefn(\v5note, ~testNote);
		Pdefn(\v5oct, ~testOct * 12);
		Pdefn(\v5dur, ~testDur);
		Pdefn(\v5amp, ~testAmp);
		Pdefn(\v5att, ~testAtt);
	) }
	{  } });
)

// tuning test octaves
(
k.elAt(\bt, \M, \1).action_({  |elem|
    if(elem.value > 0)
	{ (
		~testNote = 24; //Pseq((24..36).mirror1,inf);
		//~testNoteRev = Pseq((0..47).reverse,inf);
		~testOct = Pseq((0..3),inf); //- Prand([4, 6, 0, 0],inf);
		~testDur =  1; //Pseq((8..1).mirror2 * 0.05,inf); //Pexprand(0.04, 0.09, inf); //0.4;
		~testAmp = 1; //Pexprand(1.0, 1.0, inf); //0.5;
		~testAtt = 0.001; //Pgauss(0.001, 0.999, inf);
		~testStretch = 1.0;

		//run pdfns
		// zm
		Pdefn(\znote, ~testNote);
		Pdefn(\zoct, ~testOct * 12);
		Pdefn(\zdur, ~testDur);
		Pdefn(\zamp, ~testAmp);
		Pdefn(\zatt, ~testAtt);
		// v1
		Pdefn(\v1note, ~testNote);
		Pdefn(\v1oct, ~testOct);
		Pdefn(\v1dur, ~testDur);
		Pdefn(\v1amp, ~testAmp);
		Pdefn(\v1att, ~testAtt);
		Pdefn(\v1port, 0);
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, ~testOct);
		Pdefn(\v2dur, ~testDur);
		Pdefn(\v2amp, ~testAmp);
		Pdefn(\v2att, ~testAtt);
		Pdefn(\v2port, 0);
		// v3
		Pdefn(\v3note, ~testNote);
		Pdefn(\v3oct, ~testOct);
		Pdefn(\v3dur, ~testDur);
		Pdefn(\v3amp, ~testAmp);
		Pdefn(\v3att, ~testAtt);
		// v4
		Pdefn(\v4note, ~testNote);
		Pdefn(\v4oct, ~testOct);
		Pdefn(\v4dur, ~testDur);
		Pdefn(\v4amp, ~testAmp);
		Pdefn(\v4att, ~testAtt);
		// v5
		Pdefn(\v5note, ~testNote);
		Pdefn(\v5oct, ~testOct * 12);
		Pdefn(\v5dur, ~testDur);
		Pdefn(\v5amp, ~testAmp);
		Pdefn(\v5att, ~testAtt);
	) }
	{  } });
)

// tuning test melodic
(
k.elAt(\bt, \R, \1).action_({  |elem|
    if(elem.value > 0)
	{ (
		~testNote = Pshuf([12,15,17,19,20,22,24] +24,inf); //+ Pshuf([0,0,0,7], inf);
		~testOct = Prand((0..2),inf); //- Prand([0, 0, 0, 10],inf);
		~testDur = Pwhite(0.04, 4, inf); //0.4;
		~testAmp = Pexprand(0.05, 1.0, inf); //0.5;
		~testAtt = Pexprand(0.001, 0.999, inf);
		~testStretch = Pseq((1..4),inf);

		//run pdfns
		// zm
		Pdefn(\znote, ~testNote);
		Pdefn(\zoct, ~testOct * 12);
		Pdefn(\zdur, ~testDur);
		Pdefn(\zamp, ~testAmp);
		Pdefn(\zatt, ~testAtt);
		// v1
		Pdefn(\v1note, ~testNote);
		Pdefn(\v1oct, ~testOct);
		Pdefn(\v1dur, ~testDur);
		Pdefn(\v1amp, ~testAmp);
		Pdefn(\v1att, ~testAtt);
		Pdefn(\v1port, 0);
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, ~testOct);
		Pdefn(\v2dur, ~testDur);
		Pdefn(\v2amp, 1);
		Pdefn(\v2att, 0.001);
		Pdefn(\v2port, 0);
		// v3
		Pdefn(\v3note, ~testNote);
		Pdefn(\v3oct, ~testOct);
		Pdefn(\v3dur, ~testDur);
		Pdefn(\v3amp, ~testAmp);
		Pdefn(\v3att, ~testAtt);
		// v4
		Pdefn(\v4note, ~testNote);
		Pdefn(\v4oct, ~testOct);
		Pdefn(\v4dur, ~testDur);
		Pdefn(\v4amp, ~testAmp);
		Pdefn(\v4att, ~testAtt);
		// v5
		Pdefn(\v5note, ~testNote);
		Pdefn(\v5oct, ~testOct * 12);
		Pdefn(\v5dur, ~testDur);
		Pdefn(\v5amp, ~testAmp);
		Pdefn(\v5att, ~testAtt);
	) }
	{  } });
)

//test high pitch
(
k.elAt(\bt, \S, \2).action_({  |elem|
    if(elem.value > 0)
	{ (
		~testNote = Pxrand((12..48),inf);
		~testOct = Prand((5..8),inf);
		~testDur = Pexprand(0.09, 0.2, inf); //0.4;
		~testAmp = Pexprand(0.05, 1.0, inf); //0.5;
		~testAtt = Pexprand(0.001, 0.999, inf);
		~testStretch = Pseq((1..8),inf);

		//run pdfns
		// zm
		Pdefn(\znote, ~testNote);
		Pdefn(\zoct, ~testOct * 12);
		Pdefn(\zdur, ~testDur);
		Pdefn(\zamp, ~testAmp);
		Pdefn(\zatt, ~testAtt);
		// v1
		Pdefn(\v1note, ~testNote);
		Pdefn(\v1oct, ~testOct);
		Pdefn(\v1dur, ~testDur);
		Pdefn(\v1amp, ~testAmp);
		Pdefn(\v1att, ~testAtt);
		Pdefn(\v1port, 0);
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, Prand((2..4	),inf));
		Pdefn(\v2dur, ~testDur);
		Pdefn(\v2amp, 1);
		Pdefn(\v2att, 0.001);
		Pdefn(\v2port, 0);
		Pdefn(\v2stretch, ~testStretch);
		// v3
		Pdefn(\v3note, ~testNote);
		Pdefn(\v3oct, ~testOct);
		Pdefn(\v3dur, ~testDur);
		Pdefn(\v3amp, ~testAmp);
		Pdefn(\v3att, ~testAtt);
		// v4
		Pdefn(\v4note, ~testNote);
		Pdefn(\v4oct, ~testOct);
		Pdefn(\v4dur, ~testDur);
		Pdefn(\v4amp, ~testAmp);
		Pdefn(\v4att, ~testAtt);
		// v5
		Pdefn(\v5note, ~testNote);
		Pdefn(\v5oct, ~testOct * 12);
		Pdefn(\v5dur, ~testDur);
		Pdefn(\v5amp, ~testAmp);
		Pdefn(\v5att, ~testAtt);
	) }
	{  } });
)

//part 1
(
k.elAt(\bt, \M, \2).action_({  |elem|
    if(elem.value > 0)
	{ (
		~testNote = Pxrand((12..24),inf);
		~testOct = Pshuf((1..3),inf);
		~testDur = Pexprand(3, 15, inf); //0.4;
		~testAmp = Pexprand(0.5, 1.0, inf); //0.5;
		~testAtt = Pexprand(0.001, 0.999, inf);
		~testStretch = Prand((0.1..0.5),inf);

		//run pdfns
		// zm
		Pdefn(\znote, ~testNote);
		Pdefn(\zoct, ~testOct * 12);
		Pdefn(\zdur, ~testDur);
		Pdefn(\zamp, ~testAmp);
		Pdefn(\zatt, ~testAtt);
		Pdefn(\zport, 1);
		// v1
		Pdefn(\v1note, ~testNote);
		Pdefn(\v1oct, ~testOct);
		Pdefn(\v1dur, ~testDur);
		Pdefn(\v1amp, ~testAmp);
		Pdefn(\v1att, ~testAtt);
		Pdefn(\v1port, 1);
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, Prand((4..6	),inf));
		Pdefn(\v2dur, Prand((4..8),inf));
		Pdefn(\v2amp, 1);
		Pdefn(\v2att, 0.001);
		Pdefn(\v2port, 0);
		Pdefn(\v2stretch, ~testStretch);
		// v3
		Pdefn(\v3note, ~testNote);
		Pdefn(\v3oct, Pshuf((5..8),inf));
		Pdefn(\v3dur, ~testDur);
		Pdefn(\v3amp, ~testAmp);
		Pdefn(\v3att, ~testAtt);
		// v4
		Pdefn(\v4note, ~testNote);
		Pdefn(\v4oct, Pshuf((5..8),inf));
		Pdefn(\v4dur, ~testDur);
		Pdefn(\v4amp, ~testAmp);
		Pdefn(\v4att, ~testAtt);
		// v5
		Pdefn(\v5note, ~testNote + 36);
		Pdefn(\v5oct, ~testOct);
		Pdefn(\v5dur, ~testDur);
		Pdefn(\v5amp, ~testAmp);
		Pdefn(\v5att, ~testAtt);
		Pdefn(\v5port, 1);
	) }
	{  } });
)

//part 2
(
k.elAt(\bt, \R, \2).action_({  |elem|
    if(elem.value > 0)
	{ (
		~testNote = Pshuf([12, 14, 15, 17, 19, \rest].mirror2,inf);
		~testOct = Pshuf((2..3),inf);
		~testDur = Pshuf((0.1..0.8), inf); //0.4;
		~testAmp = Pexprand(0.5, 1.0, inf); //0.5;
		~testAtt = Pexprand(0.001, 0.999, inf);
		~testStretch = Prand((10..30),inf);

		//run pdfns
		// zm
		Pdefn(\znote, ~testNote + ~testNote);
		Pdefn(\zoct, Pshuf((3..6),inf) * 12);
		Pdefn(\zdur, ~testDur * 3);
		Pdefn(\zamp, 0.3);
		Pdefn(\zatt, ~testAmp);
		Pdefn(\zport, 0);
		// v1
		Pdefn(\v1note, ~testNote  + ~testNote);
		Pdefn(\v1oct, Pshuf((3..6),inf));
		Pdefn(\v1dur, ~testDur * 3);
		Pdefn(\v1amp, ~testAmp);
		Pdefn(\v1att, ~testAtt);
		Pdefn(\v1port, 0);
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, Prand((1..3	),inf));
		Pdefn(\v2dur, ~testDur);
		Pdefn(\v2amp, 1);
		Pdefn(\v2att, 0.001);
		Pdefn(\v2port, 0);
		Pdefn(\v2stretch, ~testStretch);
		// v3
		Pdefn(\v3note, ~testNote);
		Pdefn(\v3oct, Pshuf((3..4),inf));
		Pdefn(\v3dur, ~testDur * 2);
		Pdefn(\v3amp, ~testAmp);
		Pdefn(\v3att, ~testAtt);
		// v4
		Pdefn(\v4note, ~testNote);
		Pdefn(\v4oct, Pshuf((3..4),inf));
		Pdefn(\v4dur, ~testDur * 3);
		Pdefn(\v4amp, ~testAmp);
		Pdefn(\v4att, ~testAtt);
		// v5
		Pdefn(\v5note, ~testNote + ~testNote);
		Pdefn(\v5oct, Pshuf((3..6),inf) * 12);
		Pdefn(\v5dur, ~testDur * 3);
		Pdefn(\v5amp, ~testAmp);
		Pdefn(\v5att, ~testAtt);
		Pdefn(\v5port, 1);
	) }
	{  } });
)

//assign a knobs to dur
(
k.elAt(\kn, \1).action = { |el|
	Pdefn(\zdur, el.value.linexp(0, 1, 0.01, 5));
	Pdefn(\v1dur, el.value.linexp(0, 1, 0.01, 5));
	Pdefn(\v2dur, el.value.linexp(0, 1, 0.01, 5));
	Pdefn(\v3dur, el.value.linexp(0, 1, 0.01, 5));
	Pdefn(\v4dur, el.value.linexp(0, 1, 0.01, 5));
	Pdefn(\v5dur, el.value.linexp(0, 1, 0.01, 5));
};
k.elAt(\kn, \1).doAction;
)

// ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®

// calibrations for 1V
(
Pdefn(\v1cal, 0.0976); // es3 1, sc10
Pdefn(\v2cal, 0.097086); // es3 2, sc11
Pdefn(\v3cal, 0.09773); //es3 3, sc12;
Pdefn(\v3cal, 0.09773); //es3 3, sc12;
)

// miditune offsets
(
Pdefn(\v1mt, -23.64);
Pdefn(\v2mt, -23.61);
Pdefn(\v3mt, -23.61);
Pdefn(\v5mt, -23.61);
)

//modality

//microkontrol gui
k.gui;

// make sure there are no current assigned actions
k.resetActions;

// get its normalized value
k.elAt(\sl, 0).value;
// or its device-side value (here, midi)
k.elAt(\sl, \1).deviceValue;
// scale value
k.elAt(\sl, \1).value.linexp(0, 1, 200, 5000);

//custom nk2
k.elAt(\bt, \S, \1).value;
k.elAt(\bt,1,1).deviceValue;

//ADC rules
//example synth
(
SynthDef(\vocal, {|freq = 110, f1 = 1000, f2 = 2300|
        var sig, frq, frmt, env;
        env = EnvGen.kr(Env.perc, doneAction: 2);
        sig = Mix.new(Formant.ar([freq, freq*3], [f1, f2], 800, [0.2, 0.03] * env));
        Out.ar(0, sig.dup)
}).add;
)
//pdefn
(
k.elAt(\sl, 0).action = { |el| Pdefn(\f1, el.value.linexp(0, 1, 200, 5000)) };
k.elAt(\sl, 0).doAction;

~seqArp1 = Pseq(([60, 74, 67, 74, 64, 79, 72, 79]-24).midicps, inf).asStream;
~patArp1 = Pbind(
        \instrument, \vocal,
        \freq, ~seqArp1,
        // ask Pdefn for its current value on each new event
        \f1, Pdefn(\f1),
        \dur, 0.25
        ).trace.play;
)

//run pdfns
(
// v1
Pdefn(\v1note, ~testNote);
Pdefn(\v1oct, ~testOct);
Pdefn(\v1dur, ~testDur);
Pdefn(\v1amp, ~testAmp);
Pdefn(\v1att, ~testAtt);
Pdefn(\v1port, 0);
// v2
Pdefn(\v2note, ~testNote);
Pdefn(\v2oct, ~testOct);
Pdefn(\v2dur, ~testDur);
Pdefn(\v2amp, ~testAmp);
Pdefn(\v2att, ~testAtt);
Pdefn(\v2port, 0);
// v3
Pdefn(\v3note, ~testNote);
Pdefn(\v3oct, ~testOct);
Pdefn(\v3dur, ~testDur);
Pdefn(\v3amp, ~testAmp);
Pdefn(\v3att, ~testAtt);
Pdefn(\v3port, 0);
// v4
Pdefn(\v4note, ~testNote);
Pdefn(\v4oct, ~testOct * 12);
Pdefn(\v4dur, ~testDur);
Pdefn(\v4amp, ~testAmp);
Pdefn(\v4att, ~testAtt);
// v5
Pdefn(\v5note, ~testNote);
Pdefn(\v5oct, ~testOct);
Pdefn(\v5dur, ~testDur);
Pdefn(\v5amp, ~testAmp);
Pdefn(\v5att, ~testAtt);
)

// copy
(
({ |out, freq = 440, gate = 0.5, plfofreq = 6, mw = 0, ffreq = 2000, rq = 0.3, freqlag = 0.05, amp = 1|
var sig, plfo, fcurve;
plfo = SinOsc.kr(plfofreq, mul:mw, add:1);
freq = Lag.kr(freq, freqlag) * plfo;
fcurve = EnvGen.kr(Env.adsr(0, 0.3, 0.1, 20), gate); fcurve = (fcurve - 1).madd(0.7, 1) * ffreq;
sig = Mix.ar([Pulse.ar(freq, 0.9), Saw.ar(freq*1.007)]); sig = RLPF.ar(sig, fcurve, rq)
* EnvGen.kr(Env.adsr(0.04, 0.2, 0.6, 0.1), gate, doneAction:2)
* amp; Out.ar(out, sig ! 2)
}).memStore; )

//CV scaling
{DC.ar(-1) }.play

//LFO
{ Out.ar(14, LFSaw.ar(0.1,0,1)) }.play
{ Out.ar(21, LFSaw.ar(3,0,1)) }.play

(
SynthDef(\dcAux, { | note, octave = 0, spo = 12, midiCvOff  = -84, t_trig = 1, ch = nil, port = 0, calibration = 0.2202, offset = 0, amp = 0.01, ampCh = nil, aux = 0.0001, auxCh = nil, att = 0.01, aatt =0.01, dur = 0.1, dur2 = 0.1 |
	var auxEnv = Env([0.001, 0.99, 0.001], [aatt, 1.0-aatt], [\exp, \exp]);
	var auxEnvGen = EnvGen.kr(auxEnv, t_trig, timeScale: dur2);
	Out.ar(auxCh, K2A.ar(Lag.kr(aux * auxEnvGen)));
});
)

(
Pdefn(\two3note, Pseq([50, 55, 65, 75],inf));
Pdefn(\two3spo, 80);
Pdefn(\two3mCO, 0);
Pdefn(\two3octave, 0);
Pdefn(\two3dur, 0.3);
Pdefn(\two3amp,0.99);
Pdefn(\two3att, Pwhite(0.001, 0.002, inf));
Pdefn(\two3dur2, 0.6);
Pdefn(\two3aux, 1);
Pdefn(\two3aatt, Pwhite(0.001, 0.002, inf));
Pdefn(\two3port, 0.3);
//Pdefn(\two3amp, -1);
)

(
a = Pslide([1, 2, 3, 4, \rest, \rest], inf, 3, 1, 0);
b = a.asStream;
20.do({ (b.next.asString ++ " ").post; });
c = Pslide([1, 2, 3, 4] * 0.1, inf, 3, 1, 0);
Pdefn(\two3note, Pshuf([33, 35, 39, 42, 50, 53],inf));
Pdefn(\two3octave, Pshuf((1..5),inf));
Pdefn(\two3dur, c);
Pdefn(\two3amp,0.99);
Pdefn(\two3att, Pwhite(0.001, 0.002, inf));
Pdefn(\two3dur2, c);
Pdefn(\two3aux, Pmeanrand(0.1, 1, inf));
Pdefn(\two3aatt, Pslide((1..6) * 0.5, inf, 2, 1, 0));
Pdefn(\two3port, 0);
//Pdefn(\two3amp, -1);
)

/*
PATCH:
lfo - osc 3/4 pulse in
cv4 > mult	> sdfilt fm in
		> lpg1 cv in
osc 2 wave > sdfilt aud in
sdfilt aud out > lpg1 sig in
mix out > rev in
rev out > ext mix
828 2 > amp 2 cnt
828 3 	> mult	>zero fm ind
		>amp 1 cnt in
		>mm filt lev in
828 5	> lpg2 cv in
osc 3 tri > lpg 2 sig in
lpg2 out > mult	>mix in 2
		>to ext mixr
lpg1 out > mult>mix in 1
		>to ext mixr
osc 4 tri > lpg3in
828 6 > lpg3 cv in
lpg3 out > mult	> mix 3
		> to ext mixr
lpg4 > to ext mixr (vox)
ring mod out > lpg4 sig in
amp out > ring mod x in
amp env out > lpg4 in
es3 15 > ring mod y in
zero saw out > lev input mmfilt
high pass out > sig in amp1

cp251
noise mult > zero, osc3, osc4
sh slew to pan cont in
amp out 1 > pan in 1
zero sin out > amp sig in 2
amp2 out > mult > zero dyn ac in
		> audio out ext mix
es3 10 > amp1 sig in
es3 11 > 1oct zero
es3 12 > 1oct osc2
es3 13 > 1oct osc3
es3 14 > 1oct osc4
*/