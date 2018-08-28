s.quit;

(
// hardware ssettings for es3
ServerOptions.devices;
s.options.device = "USBStreamer";
s.options.numOutputBusChannels = 8;
s.options.outputStreamsEnabled = "11111111";
s.options.memSize = 16384;
s.options.numOutputBusChannels.postln;
s.boot;
)

(
//SYNTHDEFS - offsets & controller init

//offset synthdef
SynthDef(\offset0, { arg ch = nil, offset = -1;
	Out.ar(ch, K2A.ar(offset));
}).add;

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

//AUDIO sine out
SynthDef(\sinOut, { | freq = 440, t_trig, ch = nil, amp = 1, ampCh = nil, att = 0.01, dur = 1 |
	var env = Env([0.001, 0.99, 0.001], [att, 1.0-att], [\lin, \lin]);
	var level = amp * 2.6;
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	Out.ar(ch, SinOsc.ar(freq, 0, 1, 0));
	Out.ar(ampCh, K2A.ar(Lag.kr(amp * envGen)));
}).add;

//offset synthdef
SynthDef(\lagRand, { arg ch = nil;
	Out.ar(ch, K2A.ar(offset));
}).add;

//END SYNTHDEFS
)

//channel offsets
//ES3
// 0V offsets
(
~ch0 = Pmono(\offset0, \ch, 0, \offset, Pdefn(\ch0off, -0.0001));              // -0.0001
~ch1 = Pmono(\offset0, \ch, 1, \offset, Pdefn(\ch1off, 0.00169));             //  0.00169
~ch2 = Pmono(\offset0, \ch, 2, \offset, Pdefn(\ch2off, -0.0034));            // -0.0035
~ch3 = Pmono(\offset0, \ch, 3, \offset, Pdefn(\ch3off, -0.0002));           // -0.0002
~ch4 = Pmono(\offset0, \ch, 4, \offset, Pdefn(\ch4off, 0));                     // 0
~ch5 = Pmono(\offset0, \ch, 5, \offset, Pdefn(\ch5off, 0.0001));           // 0.0001
~ch6 = Pmono(\offset0, \ch, 6, \offset, Pdefn(\ch6off, -0.0001));        // -0.0001
~ch7 = Pmono(\offset0, \ch, 7, \offset, Pdefn(\ch7off, -0.0018));        // -0.0018
)

//start offsets
o = [~ch0.play, ~ch1.play, ~ch2.play, ~ch3.play, ~ch4.play, ~ch5.play, ~ch6.play, ~ch7.play];

//stop offsets
o[0].stop; o[1].stop; o[2].stop; o[3].stop; o[4].stop; o[5].stop; o[6].stop; o[7].stop;

//INIT PDEFNS
(
//zero + mini osc w snappy env
~v2 = Pmono(
	\zero,
	\ch, 0,
	\ampCh, 4,
	\trig, 1,
	\note, Pdefn(\v2note, 60),
	\octave, Pdefn(\v2oct, 0),
	\dur, Pdefn(\v2dur, 1),
	\port, Pdefn(\v2port, 0),
	\att, Pdefn(\v22att, 0.001),
	\amp, Pdefn(\v2amp, 1),
	\calibration, Pdefn(\v2cal, 0.09773),
	\midiTune, Pdefn(\v2mt, -23.61),
	\spo, Pdefn(\v2spo, 12),
	\stretch, Pdefn(\v2stretch, 1.0),
);

//outs 1 & 5 inXess
~xx = Pmono(
	\zero,
	\ch, 1,
	\ampCh, 5,
	\trig, 1,
	\note, Pdefn(\xxnote, 60),
	\octave, Pdefn(\xxoct, 0),
	\dur, Pdefn(\xxdur, 1),
	\port, Pdefn(\xxport, 0),
	\att, Pdefn(\xxatt, 0.001),
	\amp, Pdefn(\xxamp, 1),
	\calibration, Pdefn(\xxcal, 0.0976),
	\midiTune, Pdefn(\xxmt, -23.64),
	\spo, Pdefn(\xxspo, 12),
	\stretch, Pdefn(\xxstretch, 1.0),
);

//q106 osc 1
~v3 = Pmono(
	\zero,
	\ch, 2,
	\ampCh, 6,
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
	\ch, 3,
	\ampCh, 7,
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
//END INIT PDEFNS
)


//start
(
q = ~v2.play(quant:1);
r = ~xx.play(quant:1);
t = ~v3.play(quant:1);
v = ~v4.play(quant:1);
)

//stop
(
q.stop;
r.stop;
t.stop;
v.stop;
)

s.freeAll;

// tuning test slow
(
		//var only - for tuning
		~testNote = 20;
		~testOct = 1;//Prand((1..4),inf); //Pseq([0,\rest, 8, \rest],inf);
		~testDur = 1; // Pseq([6, 1],inf); //Pseq((8..1) * 0.05,inf); //Pexprand(0.04, 0.09, inf); //0.4;
		~testAmp = 1; //Pexprand(1.0, 1.0, inf); //0.5;
		~testAtt = 0.001; //Pexprand(0.001, 0.999, inf);
		~testStretch = 1.0;

		//run pdfns
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, ~testOct);
		Pdefn(\v2dur, ~testDur);
		Pdefn(\v2amp, ~testAmp);
		Pdefn(\v2att, ~testAtt);
		// xx
		Pdefn(\xxnote, ~testNote);
		Pdefn(\xxoct, ~testOct);
		Pdefn(\xxdur, ~testDur);
		Pdefn(\xxamp, ~testAmp);
		Pdefn(\xxatt, ~testAtt);
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
)

// tuning test octaves
(

		~testNote = 24; //Pseq((24..36).mirror1,inf);
		//~testNoteRev = Pseq((0..47).reverse,inf);
		~testOct = Pseq((0..3),inf); //- Prand([4, 6, 0, 0],inf);
		~testDur =  1; //Pseq((8..1).mirror2 * 0.05,inf); //Pexprand(0.04, 0.09, inf); //0.4;
		~testAmp = 1; //Pexprand(1.0, 1.0, inf); //0.5;
		~testAtt = 0.001; //Pgauss(0.001, 0.999, inf);
		~testStretch = 1.0;

		//run pdfns
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, ~testOct);
		Pdefn(\v2dur, ~testDur);
		Pdefn(\v2amp, ~testAmp);
		Pdefn(\v2att, ~testAtt);
		// xx
		Pdefn(\xxnote, ~testNote);
		Pdefn(\xxoct, ~testOct);
		Pdefn(\xxdur, ~testDur);
		Pdefn(\xxamp, ~testAmp);
		Pdefn(\xxatt, ~testAtt);
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

)

// vox and zero osc bambler
(
		//var only - for tuning
		~testNote = 20;
		~testOct = 1;//Prand((1..4),inf); //Pseq([0,\rest, 8, \rest],inf);
		~testDur = 1; // Pseq([6, 1],inf); //Pseq((8..1) * 0.05,inf); //Pexprand(0.04, 0.09, inf); //0.4;
		~testAmp = 1; //Pexprand(1.0, 1.0, inf); //0.5;
		~testAtt = 0.001; //Pexprand(0.001, 0.999, inf);
		~testStretch = 1.0;

		//run pdfns
		// v2
        Pdefn(\v2note, Prand([33, 37, 41, 47].mirror2,inf));
Pdefn(\v2oct, -1);
		Pdefn(\v2dur, Prand([0.1,0.2],inf));
		Pdefn(\v2amp, 1);
		Pdefn(\v2att, 0.001);
		// xx
		Pdefn(\xxnote, Prand([33, 37, 41, 47].mirror2,inf));
		Pdefn(\xxoct, Prand([2,2,2,2,1,1,1,1],inf));
		Pdefn(\xxdur, Prand([0.1,0.2],inf));
		Pdefn(\xxamp, Prand((0..8) * 0.1,inf)):
		Pdefn(\xxatt, 0.001);
		// v3
		Pdefn(\v3note, Prand([-1,23,33,37],inf)); //Pexprand(40, 80, inf));
		Pdefn(\v3oct, Pexprand(3, 6, inf));
		Pdefn(\v3dur, Pexprand(1, 6, inf));
		Pdefn(\v3amp, Pexprand(0.2, 0.7, inf));
        Pdefn(\v3att, Pexprand(0.001, 0.7, inf));
	    Pdefn(\v3port, Prand([0,1.5,1,2],inf));
		// v4
		Pdefn(\v4note, Prand([-1,1,3,7,11,13],inf)); //Pexprand(40, 80, inf));
		Pdefn(\v4oct, Pexprand(1.00, 2.00, inf));
		Pdefn(\v4dur, Pexprand(1, 10, inf));
		Pdefn(\v4amp, Pexprand(0.1, 1.0, inf));
        Pdefn(\v4att, Pexprand(0.001, 0.7, inf));
	    Pdefn(\v4port, Prand([0,1.5,1,2],inf));
)

// tuning test melodic
(

		~testNote = Pshuf([12,15,17,19,20,22,24] +24,inf); //+ Pshuf([0,0,0,7], inf);
		~testOct = Prand((0..2),inf); //- Prand([0, 0, 0, 10],inf);
		~testDur = Pwhite(0.04, 4, inf); //0.4;
		~testAmp = Pexprand(0.05, 1.0, inf); //0.5;
		~testAtt = Pexprand(0.001, 0.999, inf);
		~testStretch = Pseq((1..4),inf);

		//run pdfns
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, ~testOct);
		Pdefn(\v2dur, ~testDur);
		Pdefn(\v2amp, 1);
		Pdefn(\v2att, 0.001);
		Pdefn(\v2port, 0);
		// xx
		Pdefn(\xxnote, ~testNote);
		Pdefn(\xxoct, ~testOct);
		Pdefn(\xxdur, ~testDur);
		Pdefn(\xxamp, 1);
		Pdefn(\xxatt, 0.001);
		Pdefn(\xxport, 0);
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

)

//test high pitch
(

		~testNote = Pxrand((12..48),inf);
		~testOct = Prand((5..8),inf);
		~testDur = Pexprand(0.09, 0.2, inf); //0.4;
		~testAmp = Pexprand(0.05, 1.0, inf); //0.5;
		~testAtt = Pexprand(0.001, 0.999, inf);
		~testStretch = Pseq((1..8),inf);

		//run pdfns
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

)


//CV scaling
{DC.ar(-1) }.play

//LFO
{ Out.ar(14, LFSaw.ar(0.1,0,1)) }.play
{ Out.ar(21, LFSaw.ar(3,0,1)) }.play


















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
