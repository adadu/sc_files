s.quit;

(
// hardware ssettings for USBStreamer
ServerOptions.devices;
s.options.device = "USBStreamer ";
s.options.sampleRate = 48000.0;
s.options.numOutputBusChannels = 8;
s.options.outputStreamsEnabled = "11111111";
s.options.memSize = 8192;
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

//ES3,     (8 & 9 spdif)                                                                                         // 0V offsets
~ch0 = Pmono(\offset0, \ch, 0, \offset, Pdefn(\ch0off, -0.0001));              // -0.0001
~ch1 = Pmono(\offset0, \ch, 1, \offset, Pdefn(\ch1off, 0.00169));             //  0.00169
~ch2 = Pmono(\offset0, \ch, 2, \offset, Pdefn(\ch2off, -0.0034));            // -0.0035
~ch3 = Pmono(\offset0, \ch, 3, \offset, Pdefn(\ch3off, -0.0002));           // -0.0002
~ch4 = Pmono(\offset0, \ch, 4, \offset, Pdefn(\ch4off, 0));                     // 0
~ch5 = Pmono(\offset0, \ch, 5, \offset, Pdefn(\ch5off, 0.0001));           // 0.0001
~ch6 = Pmono(\offset0, \ch, 6, \offset, Pdefn(\ch6off, -0.0001));        // -0.0001
~ch7 = Pmono(\offset0, \ch, 7, \offset,Pdefn(\ch7off, -0.0018));        // -0.0018

//run ALL offsets w nanokontrol2
k.elAt(\tr, \mset).action_({  |elem|
    if(elem.value > 0)
	{ o = [~ch0.play, ~ch1.play, ~ch2.play, ~ch3.play, ~ch4.play, ~ch5.play, ~ch6.play, ~ch7.play]; }
	{ o[0].stop; o[1].stop; o[2].stop; o[3].stop; o[4].stop; o[5].stop; o[6].stop; o[7].stop; } });

//att-dec envelopes equal to dur
SynthDef(\zero, { | note, octave = 0, spo = 12, t_trig, ch = nil, port = 0, calibration = 0.1, midiTune = 0, amp = 1,
	ampCh = nil, att = 0.001, dur = 1 |
	var level = amp;
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
	var level = amp;
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	Out.ar(ch, SinOsc.ar(freq, 0, 1, 0));
	Out.ar(ampCh, K2A.ar(Lag.kr(amp * envGen)));
}).add;

SynthDef(\wadsr, { | note, octave = 0, spo = 12, t_trig = 1, ch = nil, port = 0, calibration = 0.1, midiTune = 0, amp = 1,
	ampCh = nil, att = 0.001, dec = 0.02, sus = 0.4, rel = 0.579, curve = 2, dur = 1 |
	var level, env, envGen;
	level = amp * 0.694;
	env = Env([0, 1, level, level, 0], [att, dec, sus, rel], curve);
	envGen = EnvGen.kr(env, t_trig, level); //, timeScale: dur
	note = note;
	note = note + (octave * spo) + midiTune;
	note = (note / spo) * calibration;
	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
	Out.ar(ampCh, K2A.ar(envGen));
}).add;

//END SYNTHDEFS
)

(
//INIT PDEFNS

//q106 osc 1
~v1 = Pmono(
	\wadsr,
	\ch, 0,
	\ampCh, 4,
	\trig, 1,
	\note, Pdefn(\v1note, 60),
	\octave, Pdefn(\v1oct, 0),
	\dur, Pdefn(\v1dur, 1),
	\port, Pdefn(\v1port, 0),
	\att, Pdefn(\v1att, 0.001),
	\dec, Pdefn(\v1dec, 0.7),
	\sus, Pdefn(\v1sus, 0.2),
	\rel, Pdefn(\v1rel, 0.9),
	\curve, Pdefn(\v1curv, 4),
	\amp, Pdefn(\v1amp, 1),
	\calibration, Pdefn(\v1cal, 0.0976),
	\midiTune, Pdefn(\v1mt, -23.98),
	\spo, Pdefn(\v1spo, 12),
	\stretch, Pdefn(\v1stretch, 1.0),
);

//q106 osc 2
~v2 = Pmono(
	\wadsr,
	\ch, 1,
	\ampCh, 5,
	\trig, 1,
	\note, Pdefn(\v2note, 60),
	\octave, Pdefn(\v2oct, 0),
	\dur, Pdefn(\v2dur, 1),
	\port, Pdefn(\v2port, 0),
	\att, Pdefn(\v2att, 0.001),
	\dec, Pdefn(\v2dec, 0.7),
	\sus, Pdefn(\v2sus, 0.2),
	\rel, Pdefn(\v2rel, 0.9),
	\curve, Pdefn(\v2curv, 4),
	\amp, Pdefn(\v2amp, 1),
	\calibration, Pdefn(\v2cal, 0.0972),
	\midiTune, Pdefn(\v2mt, -23.98),
	\spo, Pdefn(\v2spo, 12),
	\stretch, Pdefn(\v2stretch, 1.0),
);

//mini osc
~v3 = Pmono(
	\wadsr,
	\ch, 2,
	\ampCh, 6,
	\trig, 1,
	\note, Pdefn(\v3note, 60),
	\octave, Pdefn(\v3oct, 0),
	\dur, Pdefn(\v3dur, 1),
	\port, Pdefn(\v3port, 0),
	\att, Pdefn(\v3att, 0.001),
	\dec, Pdefn(\v3dec, 0.7),
	\sus, Pdefn(\v3sus, 0.2),
	\rel, Pdefn(\v3rel, 0.9),
	\curve, Pdefn(\v3curv, 4),
	\amp, Pdefn(\v3amp, 1),
	\calibration, Pdefn(\v3cal, 0.09812),
	\midiTune, Pdefn(\v3mt, -23.98),
	\spo, Pdefn(\v3spo, 12),
	\stretch, Pdefn(\v3stretch, 1.0),
);

//zerosc
~v4 = Pmono(
	\wadsr,
	\ch, 3,
	\ampCh, 7,
	\trig, 1,
	\note, Pdefn(\v4note, 60),
	\octave, Pdefn(\v4oct, 0),
	\dur, Pdefn(\v4dur, 1),
	\port, Pdefn(\v4port, 0),
	\att, Pdefn(\v4att, 0.001),
	\dec, Pdefn(\v4dec, 0.7),
	\sus, Pdefn(\v4sus, 0.2),
	\rel, Pdefn(\v4rel, 0.9),
	\curve, Pdefn(\v4curv, 4),
	\amp, Pdefn(\v4amp, 1),
	\calibration, Pdefn(\v4cal, 0.09812),
	\midiTune, Pdefn(\v4mt, -23.98),
	\spo, Pdefn(\v4spo, 12),
	\stretch, Pdefn(\v4stretch, 1.0),
);

//END INIT PDEFNS
)

//START STOP w play button
(
k.elAt(\tr, \play).action_({  |elem|
    if(elem.value > 0)
	{ q = ~v1.play(quant:1); r = ~v2.play(quant:1); t = ~v3.play(quant:1); v = ~v4.play(quant:1); }
	{ q.stop; r.stop; t.stop; v.stop; } });
)

// tuning test octaves
(
k.elAt(\bt, \S, \1).action_({  |elem|
    if(elem.value > 0)
	{ (
		~testNote = 24; //Pseq((24..36).mirror1,inf);
		//~testNoteRev = Pseq((0..47).reverse,inf);
		~testOct = Pseq((0..6),inf); //- Prand([4, 6, 0, 0],inf);
		~testDur =  3; //Pseq((8..1).mirror2 * 0.05,inf); //Pexprand(0.04, 0.09, inf); //0.4;
		~testAmp = 1; //Pexprand(1.0, 1.0, inf); //0.5;
		~testAtt = 0.001; //Pgauss(0.001, 0.999, inf);
		~testDec = 0.1;
		~testSus = ~testDur * 0.8;
		~testRel = 0.8;
		~testStretch = 1.0;

		//run pdfns

		// v1
		Pdefn(\v1note, ~testNote);
		Pdefn(\v1oct, ~testOct);
		Pdefn(\v1dur, ~testDur);
		Pdefn(\v1amp, ~testAmp);
		Pdefn(\v1att, ~testAtt);
		Pdefn(\v1dec, ~testDec);
		Pdefn(\v1sus, ~testSus);
		Pdefn(\v1rel, ~testRel);
		Pdefn(\v1stretch, ~testStretch);
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, ~testOct);
		Pdefn(\v2dur, ~testDur);
		Pdefn(\v2amp, ~testAmp);
		Pdefn(\v2att, ~testAtt);
		Pdefn(\v2dec, ~testDec);
		Pdefn(\v2sus, ~testSus);
		Pdefn(\v2rel, ~testRel);
		Pdefn(\v2stretch, ~testStretch);
		// v3
		Pdefn(\v3note, ~testNote);
		Pdefn(\v3oct, ~testOct);
		Pdefn(\v3dur, ~testDur);
		Pdefn(\v3amp, ~testAmp);
		Pdefn(\v3att, ~testAtt);
		Pdefn(\v3dec, ~testDec);
		Pdefn(\v3sus, ~testSus);
		Pdefn(\v3rel, ~testRel);
		Pdefn(\v3stretch, ~testStretch);
		// v4
		Pdefn(\v4note, ~testNote);
		Pdefn(\v4oct, ~testOct);
		Pdefn(\v4dur, ~testDur);
		Pdefn(\v4amp, ~testAmp);
		Pdefn(\v4att, ~testAtt);
		Pdefn(\v4dec, ~testDec);
		Pdefn(\v4sus, ~testSus);
		Pdefn(\v4rel, ~testRel);
		Pdefn(\v4stretch, ~testStretch);
	) }
	{  } });
)


// kale season 1
(
k.elAt(\bt, \M, \1).action_({  |elem|
    if(elem.value > 0)
	{ (
		~testMult = Pxrand([4/3, 6/5, 8/7],inf);
		~testNote = 22 + Pslide([2,3,5,7,9], inf, 4, 1);
		//~testNoteRev = Pseq((0..47).reverse,inf);
		~testOct = Pseq([0,0,0,1],inf);
		~testDur =  Pslide([1, 2, 3, 4, 5] * 1, inf, 1, 1, 1);
		~testAmp = Pexprand(0.8, 1.0, inf); //0.5;
		~testAtt = ~testDur * Pgauss(0.001, 0.5, inf);
		~testDec = 0.1; //Pseq((0.05 .. 0.05),inf);
		~testSus = ~testDur * 0.3;
		~testRel = ~testDur * 0.7;
		~testStretch = 1.0;

		//run pdfns

		//v1
		Pdefn(\v1note, Pseq([32],inf));
		Pdefn(\v1oct, 0);
		Pdefn(\v1dur, Pseq([5, Rest(0.25)], inf));
		Pdefn(\v1amp, 1);
		Pdefn(\v1att, 0.02);
		Pdefn(\v1dec, 0.1);
		Pdefn(\v1sus, 0.8);
		Pdefn(\v1rel, 1.6);
		Pdefn(\v1curv, 4);
		Pdefn(\v1stretch, ~testStretch);
		// v2
	    Pdefn(\v2note, Pseq([31],inf));
		Pdefn(\v2oct, 0);
		Pdefn(\v2dur, Pseq([5, Rest(0.25)], inf));
		Pdefn(\v2amp, 1);
		Pdefn(\v2att, 1.2);
		Pdefn(\v2dec, 0.2);
		Pdefn(\v2sus, 1.1);
		Pdefn(\v2rel, 0.9);
		Pdefn(\v2curv, 4);
		Pdefn(\v2port, 0);
		Pdefn(\v2stretch, ~testStretch);
		// v3
		//miniOsc sig proc -1V > cv in/exp 10, sin > zerosc dyn ac in
		Pdefn(\v3note, ~testNote);
		Pdefn(\v3oct, ~testOct);
		Pdefn(\v3dur, ~testDur);
		Pdefn(\v3amp, ~testAmp);
		Pdefn(\v3att, ~testAtt);
		Pdefn(\v3dec, ~testDec);
		Pdefn(\v3sus, ~testSus);
		Pdefn(\v3rel, ~testRel);
		Pdefn(\v3stretch, ~testStretch);
		// v4
		//zerosc bias=lo, range=lfo, linFM=3, ind=5, ramp out > mmFilt
		//slew sh > 1v oct, noise > mmFilt, hiPass
		Pdefn(\v4note, ~testNote);
		Pdefn(\v4oct, ~testOct);
		Pdefn(\v4dur, ~testDur);
		Pdefn(\v4amp, ~testAmp);
		Pdefn(\v4att, ~testAtt);
		Pdefn(\v4dec, ~testDec);
		Pdefn(\v4sus, ~testSus);
		Pdefn(\v4rel, ~testRel);
		Pdefn(\v4stretch, ~testStretch);
	) }	{  } });
)


// red dress
(
k.elAt(\bt, \R, \1).action_({  |elem|
    if(elem.value > 0)
	{ (
		~testNote = Prand([22,33,23,35,26,39,27],inf); //Pshuf([2,3,5,7,11], inf);//Pslide([2,3,5,7,11], inf, 1, 1);
		~tNote = ~testNote;
		//~testNoteRev = Pseq((0..47).reverse,inf);
		~testOct = Pseq((2..2),inf);
		~testDur =  Pseq((1..8) * 0.5, inf); //Pslide([1, 2, 3, 4] * 0.3, inf, 3, 1, 0);
		~testD = ~testDur;
		~testAmp = Pexprand(0.8, 1.0, inf);
		~testAtt = ~testD* 0.8;
		~testDec = ~testD * 0.1;
		~testSus = ~testD * 0.06;
		~testRel = ~testD * 0.01;
		~testStretch = Pseq((1..3) * 1, inf);

		//run pdfns

		//v1
		Pdefn(\v1note, ~tNote);
		Pdefn(\v1oct, 1);
		Pdefn(\v1dur, ~testD);
		Pdefn(\v1amp, ~testAmp);
		Pdefn(\v1att, ~testAtt);
		Pdefn(\v1dec, ~testDec);
		Pdefn(\v1sus, ~testSus);
		Pdefn(\v1rel, ~testRel);
		Pdefn(\v1stretch, ~testStretch);
		// v2
		Pdefn(\v2note, ~tNote);
		Pdefn(\v2oct, 1);
		Pdefn(\v2dur, ~testD);
		Pdefn(\v2amp, ~testAmp);
		Pdefn(\v2att, ~testAtt);
		Pdefn(\v2dec, ~testDec);
		Pdefn(\v2sus, ~testSus);
		Pdefn(\v2rel, ~testRel);
		Pdefn(\v2stretch, ~testStretch);
		// v3
		Pdefn(\v3note, ~tNote);
		Pdefn(\v3oct, ~testOct);
	    Pdefn(\v3dur, ~testDur);
		Pdefn(\v3amp, ~testAmp);
		Pdefn(\v3att, ~testAtt);
		Pdefn(\v3dec, ~testDec);
		Pdefn(\v3sus, ~testSus);
		Pdefn(\v3rel, ~testRel);
		Pdefn(\v3stretch, ~testStretch);
		// v4
		Pdefn(\v4note, ~tNote);
		Pdefn(\v4oct, ~testOct);
		Pdefn(\v4dur, ~testDur);
		Pdefn(\v4amp, ~testAmp);
		Pdefn(\v4att, ~testAtt);
		Pdefn(\v4dec, ~testDec);
		Pdefn(\v4sus, ~testSus);
		Pdefn(\v4rel, ~testRel);
		Pdefn(\v4stretch, ~testStretch);
	) }	{  } });
)

//test high pitch
(
k.elAt(\bt, \S, \2).action_({  |elem|
    if(elem.value > 0)
	{ (
		~testNote = Pshuf((12..48),inf, 4);
		~testOct = Pshuf((4..7),inf);
		~testDur = Pexprand(0.09, 0.2, inf); //0.4;
		~testAmp = Pexprand(0.1, 1.0, inf); //0.5;
		~testAtt = Pexprand(0.001, 0.5, inf);
		~testDec = Pexprand(0.01, 0.4, inf);
		~testSus = Pexprand(0.001, ~testDur/2, inf);
		~testRel = Pexprand(0.001, ~testDur, inf);
		~testStretch = Pseq((1..1),inf);

		//run pdfns

		// v1
		Pdefn(\v1note, ~testNote);
		Pdefn(\v1oct, ~testOct);
		Pdefn(\v1dur, ~testDur);
		Pdefn(\v1amp, ~testAmp);
		Pdefn(\v1att, ~testAtt);
		Pdefn(\v1dec, ~testDec);
		Pdefn(\v1sus, ~testSus);
		Pdefn(\v1rel, ~testRel);
		Pdefn(\v1stretch, ~testStretch);
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, ~testOct);
		Pdefn(\v2dur, ~testDur);
		Pdefn(\v2amp, ~testAmp);
		Pdefn(\v2att, ~testAtt);
		Pdefn(\v2dec, ~testDec);
		Pdefn(\v2sus, ~testSus);
		Pdefn(\v2rel, ~testRel);
		Pdefn(\v2stretch, ~testStretch);
		// v3
		Pdefn(\v3note, ~testNote);
		Pdefn(\v3oct, ~testOct);
		Pdefn(\v3dur, ~testDur);
		Pdefn(\v3amp, ~testAmp);
		Pdefn(\v3att, ~testAtt);
		Pdefn(\v3dec, ~testDec);
		Pdefn(\v3sus, ~testSus);
		Pdefn(\v3rel, ~testRel);
		Pdefn(\v3stretch, ~testStretch);
		// v4
		Pdefn(\v4note, ~testNote);
		Pdefn(\v4oct, ~testOct);
		Pdefn(\v4dur, ~testDur);
		Pdefn(\v4amp, ~testAmp);
		Pdefn(\v4att, ~testAtt);
		Pdefn(\v4dec, ~testDec);
		Pdefn(\v4sus, ~testSus);
		Pdefn(\v4rel, ~testRel);
		Pdefn(\v4stretch, ~testStretch);
	) }
	{  } });
)

//running dance improv
(
k.elAt(\bt, \M, \2).action_({  |elem|
    if(elem.value > 0)
	{ (
		~testNote = Pshuf([12, 14, 15, 17, 19, \rest].mirror2,inf);
		~testOct = Pshuf((4..1).mirror,inf);
		~testDur = Pshuf((0.1..0.38), inf); //0.4;
		~testAmp = Pexprand(0.95, 1.0, inf); //0.5;
		~testAtt = Pexprand(0.001, 0.999, inf);
		~testDec = 0.1;
		~testSus = 0.3;
		~testRel = 0.1;
		~testStretch = 1.0;

		//run pdfns

		// v1
		Pdefn(\v1note, ~testNote);
		Pdefn(\v1oct, ~testOct);
		Pdefn(\v1dur, ~testDur);
		Pdefn(\v1amp, ~testAmp);
		Pdefn(\v1att, ~testAtt);
		Pdefn(\v1dec, ~testDec);
		Pdefn(\v1sus, ~testSus);
		Pdefn(\v1rel, ~testRel);
		Pdefn(\v1stretch, ~testStretch);
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, ~testOct);
		Pdefn(\v2dur, ~testDur);
		Pdefn(\v2amp, ~testAmp);
		Pdefn(\v2att, ~testAtt);
		Pdefn(\v2dec, ~testDec);
		Pdefn(\v2sus, ~testSus);
		Pdefn(\v2rel, ~testRel);
		Pdefn(\v2stretch, ~testStretch);
		// v3
		Pdefn(\v3note, ~testNote);
		Pdefn(\v3oct, ~testOct);
		Pdefn(\v3dur, ~testDur);
		Pdefn(\v3amp, ~testAmp);
		Pdefn(\v3att, ~testAtt);
		Pdefn(\v3dec, ~testDec);
		Pdefn(\v3sus, ~testSus);
		Pdefn(\v3rel, ~testRel);
		Pdefn(\v3stretch, ~testStretch);
		// v4
		Pdefn(\v4note, ~testNote);
		Pdefn(\v4oct, ~testOct);
		Pdefn(\v4dur, ~testDur);
		Pdefn(\v4amp, ~testAmp);
		Pdefn(\v4att, ~testAtt);
		Pdefn(\v4dec, ~testDec);
		Pdefn(\v4sus, ~testSus);
		Pdefn(\v4rel, ~testRel);
		Pdefn(\v4stretch, ~testStretch);
	) }
	{  } });
)

//cafe end part, add cafe talking synth
(
k.elAt(\bt, \R, \2).action_({  |elem|
    if(elem.value > 0)
	{ (
		~testNote = Pshuf([12, 14, 15, 17, 19, \rest].mirror2,inf);
		~testOct = Pseq((8..7).mirror,inf);
		~testDur = Pshuf((0.1..0.38), inf); //0.4;
		~testAmp = Pexprand(0.95, 1.0, inf); //0.5;
		~testAtt = Pexprand(0.001, 0.999, inf);
		~testDec = 0.1;
		~testSus = 0.3;
		~testRel = 0.1;
		~testStretch = 1.0;

		//run pdfns

		// v1
		Pdefn(\v1note, ~testNote);
		Pdefn(\v1oct, ~testOct);
		Pdefn(\v1dur, ~testDur);
		Pdefn(\v1amp, ~testAmp);
		Pdefn(\v1att, ~testAtt);
		Pdefn(\v1dec, ~testDec);
		Pdefn(\v1sus, ~testSus);
		Pdefn(\v1rel, ~testRel);
		Pdefn(\v1stretch, ~testStretch);
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, Prand((0..2).mirror,inf));
		Pdefn(\v2dur, ~testDur * 2);
		Pdefn(\v2amp, ~testAmp);
		Pdefn(\v2att, ~testAtt);
		Pdefn(\v2dec, ~testDec);
		Pdefn(\v2sus, ~testSus / 2);
		Pdefn(\v2rel, ~testRel);
		Pdefn(\v2stretch, ~testStretch);
		Pdefn(\v2port, 0.5);
		// v3
		Pdefn(\v3note, ~testNote);
		Pdefn(\v3oct, -3);
		Pdefn(\v3dur, ~testDur);
		Pdefn(\v3amp, ~testAmp);
		Pdefn(\v3att, ~testAtt);
		Pdefn(\v3dec, ~testDec);
		Pdefn(\v3sus, ~testSus);
		Pdefn(\v3rel, ~testRel);
		Pdefn(\v3stretch, ~testStretch);
		// v4
		Pdefn(\v4note, ~testNote);
		Pdefn(\v4oct, ~testOct -4);
		Pdefn(\v4dur, ~testDur * 5);
		Pdefn(\v4amp, Pexprand(0.15, 1.0, inf));
		Pdefn(\v4att, ~testAtt);
		Pdefn(\v4dec, ~testDec);
		Pdefn(\v4sus, ~testSus);
		Pdefn(\v4rel, ~testRel);
		Pdefn(\v4stretch, ~testStretch);
	) }
	{  } });
)



s.freeAll;

// ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®
// ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®
// ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®

//microkontrol gui
k.gui;

// make sure there are no current assigned actions
k.resetActions;

//assign a knobs to dur
(
k.elAt(\kn, \1).action = { |el|
	Pdefn(\zdur, el.value.linexp(0, 1, 0.01, 5));
	Pdefn(\v1dur, el.value.linexp(0, 1, 0.01, 5));
	// Pdefn(\v2dur, el.value.linexp(0, 1, 0.01, 5));
	Pdefn(\v3dur, el.value.linexp(0, 1, 0.01, 5));
	Pdefn(\v4dur, el.value.linexp(0, 1, 0.01, 5));
	// Pdefn(\v5dur, el.value.linexp(0, 1, 0.01, 5));
};
k.elAt(\kn, \1).doAction;
)

//start
(
q = ~v1.play(quant:1);
r = ~v2.play(quant:1);
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

//asdr env test, using es3, level should be mult by 1/2 to adjust to 5v
// SynthDef(\wadsr, { | note, octave = 0, spo = 12, t_trig = 1, ch = nil, port = 0, calibration = 0.1, midiTune = 0, amp = 1,
// 	ampCh = nil, att = 0.001, dec = 0.02, sus = 0.4, rel = 0.579, curve = 2, dur = 1, susLevel = 0.5 |
// 	var level, env, envGen;
// 	PulseCount.kr(t_trig).poll;
// 	level = amp * 0.4;
// 	env = Env([0, 1, level, level, 0], [att, dec, sus, rel]);
// 	envGen = EnvGen.kr(env, t_trig, level/*, timeScale: dur*/);
// 	note = note;
// 	note = note + (octave * spo) + midiTune;
// 	note = (note / spo) * calibration;
// 	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
// 	Out.ar(ampCh, K2A.ar(envGen));
// }).add;

// params for env test
~gdur  = Pseq([1, 1, 2, 1, 1, 3, 1, 1, 9], inf); // * Prand((0.08..0.2) * 4, inf);
~a = 1;
Pdefn(\v3dur, ~gdur * ~a);
Pdefn(\v3amp, 0.999);
Pdefn(\v3att, 0.001);
Pdefn(\v3att, Prand([0.1, 0.3, 0.6, 0.8] * 1,inf));
Pdefn(\v3dec, 0.01);
Pdefn(\v3dec, Prand([0.1, 0.3, 0.6, 0.8] * 1,inf));
Pdefn(\v3sus, Pseq([0.1, 0.3, 0.6, 0.8] * 2,inf));
Pdefn(\v3rel, Pseq([0.1, 0.3, 0.6, 0.8] * 2 ,inf));
Pdefn(\v3curv, \exp);
Pdefn(\v3note, Pseq([40, 32, 33, \rest, 41, 43], inf));
Pdefn(\v3oct, 2);

Pdefn(\v3dur, ~gdur * ~a);
Pdefn(\v3amp, 0.999);
Pdefn(\v3att, Pxrand([0.001, 0.001, 0.001, 0.9], inf));
Pdefn(\v3dec, ~gdur * 0.3);
Pdefn(\v3sus, ~gdur * 0.05);
Pdefn(\v3sus, ~gdur + (~gdur * Pseq((0.1..0.3),inf)));
Pdefn(\v3rel, ~gdur * 1 + (~gdur * Pshuf((1..5) * 1,inf)));
Pdefn(\v3rel, Pseq([0.5, 1, 1.5, 2],inf));
Pdefn(\v3curv, \exp);

Pdefn(\v3dur, Pwhite(0.1, 0.2, inf));
Pdefn(\v3amp, Pwhite(0.001, 1, inf));
Pdefn(\v3amp, 0.5);
Pdefn(\v3att, 0.001);
Pdefn(\v3att, Pwhite(0.001, 0.1, inf));
Pdefn(\v3dec, Pwhite(0.01, 1, inf));
Pdefn(\v3dec, 0.03);
Pdefn(\v3sus, 1);
Pdefn(\v3sus, Pwhite(0.001, 1, inf));
Pdefn(\v3sus, 0.001);
Pdefn(\v3rel, 0.8);
Pdefn(\v3rel, 0.01);
Pdefn(\v3rel, Pseq((1..5),inf));
Pdefn(\v3scale, 7);
Pdefn(\v3deg, 1);
Pdefn(\v3note, Pxrand((60..80), inf, 5));
Pdefn(\v3note, Pseq([10, 12, 13, 15], inf));
Pdefn(\v3oct, Pxrand((-2..8),inf));
Pdefn(\v3curv, \lin);
Pdefn(\v3curv, [\exp, \sin, \lin, \exp]);

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

//part 2
(
k.elAt(\bt, \R, \7).action_({  |elem|
    if(elem.value > 0)
	{ (
		~testNote = Pshuf([12, 14, 15, 17, 19, \rest].mirror2,inf);
		~testOct = Pshuf((2..3),inf);
		~testDur = Pshuf((0.1..0.8), inf); //0.4;
		~testAmp = Pexprand(0.5, 1.0, inf); //0.5;
		~testAtt = Pexprand(0.001, 0.999, inf);
		~testDec = 0.1;
		~testSus = 0.3;
		~testRel = 0.8;
		~testStretch = Prand((10..30),inf);

		//run pdfns

		// v1
		Pdefn(\v1note, ~testNote);
		Pdefn(\v1oct, ~testOct);
		Pdefn(\v1dur, ~testDur);
		Pdefn(\v1amp, ~testAmp);
		Pdefn(\v1att, ~testAtt);
		Pdefn(\v1dec, ~testDec);
		Pdefn(\v1sus, ~testSus);
		Pdefn(\v1rel, ~testRel);
		Pdefn(\v1stretch, ~testStretch);
		// v2
		Pdefn(\v2note, ~testNote);
		Pdefn(\v2oct, ~testOct);
		Pdefn(\v2dur, ~testDur);
		Pdefn(\v2amp, ~testAmp);
		Pdefn(\v2att, ~testAtt);
		Pdefn(\v2dec, ~testDec);
		Pdefn(\v2sus, ~testSus);
		Pdefn(\v2rel, ~testRel);
		Pdefn(\v2stretch, ~testStretch);
		// v3
		Pdefn(\v3note, ~testNote);
		Pdefn(\v3oct, ~testOct);
		Pdefn(\v3dur, ~testDur);
		Pdefn(\v3amp, ~testAmp);
		Pdefn(\v3att, ~testAtt);
		Pdefn(\v3dec, ~testDec);
		Pdefn(\v3sus, ~testSus);
		Pdefn(\v3rel, ~testRel);
		Pdefn(\v3stretch, ~testStretch);
		// v4
		Pdefn(\v4note, ~testNote);
		Pdefn(\v4oct, ~testOct);
		Pdefn(\v4dur, ~testDur);
		Pdefn(\v4amp, ~testAmp);
		Pdefn(\v4att, ~testAtt);
		Pdefn(\v4dec, ~testDec);
		Pdefn(\v4sus, ~testSus);
		Pdefn(\v4rel, ~testRel);
		Pdefn(\v4stretch, ~testStretch);
	) }
	{  } });
)
