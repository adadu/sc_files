s.quit;

//Load setup file to get examples working
("setup.scd").loadRelative;

l = Prand([2,9,8],inf);

(
p.clock.tempo = 150/60;
~c = Pbind(\instrument,\wtabl, \freq, Pshuf((0..20),inf), \buf, Prand([ d["kick"][2], d["kick"][3], d["sn"][1], d["clap"][0] ],inf),\dur,Pbjorklund2(Pexprand(2,9).round(1),16,inf,Pwhite(2,5).asStream)/8,\amp,0.89, \atk, 0.01, \rel, 0.2, \rate,Pexprand(0.05, 2.3, inf));
~c2 = Pbind(\instrument,\bpfsaw,
	\degree, Pexprand(2,13,inf),
	//\note, Prand([33,21,31,36],inf) * Prand([0.77,1.33,1],inf),
	\scale, Scale.chromatic(\harmonic),
	\octave, 5,
	\ts, 2,
	\dur,Pbjorklund2(Pexprand(2,5,inf),16,inf,Pwhite(2,7).asStream)/64,
	\amp,0.59,
	\cfhzmin, 2,
	\cfhzmax, 0.3,
	\cfmin,30, \cfmax,2200,
	\lsf,150, \ldb,9,
	\atk, 0.7,
	\sus,0,
	\rel, 0.7,
	\lag, 0.3
);
// ~k = Pbind(\instrument,\bplaym,\buf,d["kick"][1],\dur,Pbjorklund2(Pseq((1..4),inf),32,inf,0.asStream)/16,\amp,0.99,\rate,0.40);
// ~snare = Pbind(\instrument,\bplaym,\buf,d["sn"][3],\dur,Pbjorklund2(Pseq((1..2),inf),16,inf,0.asStream)/16,\amp,0.99,\rate,1);
~c.play;
~c2.play;
//~k.play;
//~snare.play;
)
~c.free;
~c2.free;
~k.free;
~snare.free;
//snare running forwards and back
(
p.clock.tempo = 130/60;
~sn = Pbind(\instrument,\bplay,\buf,d["sn"][7],\dur,Pbjorklund2(Pexprand(1,3).round(1),16,inf,Pwhite(2,5).asStream)/32,\amp, Pexprand(0.16, 0.99, inf), \rate, Pexprand(0.83, 6.53,inf).asStream, \pan, Pbjorklund2(Pexprand(8,16).round(1),16,inf,Pwhite(1,5).asStream)/4 * Prand((-1.0..1.0),inf));

~sn.play;
)
~sn.free;

Tuning.directory
Scale.directory

s.record(bus:1,numChannels: 5, duration: 20);
s.stopRecording;


//ff800 outs: 0-7, 828 outs: 28-37 / es3 outs: 42-49


//modular control test
(
//p.clock.tempo = 150/60;
v = Scale.egyptian/*(\johnston)*/;
u = 0.4;
~o2 = Pmono(\dcev,
	\ch,42,\ampCh,28,
	\trig, 1,
	\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1, 0],inf),
	\scale, Pfunc( {v},inf),
	\dur, u* Pseq([1,1,0.5,1,1,1,0.5],inf), //Pbjorklund2(Pseq((1..3),inf),16,inf,1.asStream)/16,  //+ Prand([0.33,Rest(0.33), Rest(0.33)],inf) * 1, //Pbjorklund2(Pseq((3..1),inf),16,inf,1.asStream)/1,
	\amp, Pexprand(0.7, 1, inf),
	\atk, Prand([1,10,5,1],inf)*0.001,
	\sus,Prand([1,5,1,1,2],inf)*0.2,
	\rel,Prand([1,3,10,1],inf)*0.39,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq([2,3,2,4],inf) + 1,
	\port, 0,//Pseq([0,0,0.6,0,0.3],inf)
	); //Pexprand(0.03,0.5,inf));

~o3 = Pmono(\dcev,
	\ch,43,\ampCh,29,
	\trig, 1,
	\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1, 0],inf),
	\scale, Pfunc( {v},inf),
	\dur, u* Pseq([1,1,0.25,1,1,1,0.25],inf), //Pbjorklund2(Pseq((3..1),inf),16,inf,1.asStream)/16,
	\amp, Pexprand(0.7, 1, inf),
	\atk, Prand([1,10,5,1],inf)*0.001,
	\sus,Prand([1,5,1,1,2],inf)*0.2,
	\rel,Prand([1,3,10,1],inf)*0.39,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq([2,1,2,3],inf) + 1,
	\port, 0,//Pseq([0,0,0.6,0,0.3],inf)
	); //Pexprand(0.03,0.5,inf));

~o4 = Pmono(\dcev,
	\ch,44,\ampCh,30,
	\trig, 1,
	\degree, Prand([0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1, 0],inf),
	\scale, Pfunc( {v},inf),
	\dur, u * Pseq([1,1,2,4,1],inf), //Pbjorklund2(Pseq((3..1),inf),16,inf,1.asStream)/16,
	\amp, Pexprand(0.68, 0.95, inf),
	\atk, Prand([1,10,5,1],inf)*0.001,
	\sus,Prand([1,5,1,1,2],inf)*0.2,
	\rel,Prand([1,3,10,1],inf)*0.39,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq([2,2,4,2],inf),
	\port, 0,//Pseq([0,0,0.6,0,0.3],inf)
	); //Pexprand(0.03,0.5,inf));

~o5 = Pmono(\dcev,
	\ch,45,\ampCh,31,
	\trig, 1,
	\degree, Prand([0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1, 0],inf),
		\scale, Pfunc( {v},inf),
	\dur, u * Pshuf([1,1,2,4,1],inf), //Pbjorklund2(Pseq((3..1),inf),16,inf,1.asStream)/16,
	\amp, Pexprand(0.68, 0.95, inf),
	\atk, Prand([1,10,5,1],inf)*0.1,
	\sus,Prand([1,5,1,1,2],inf)*0.2,
	\rel,Prand([1,3,10,1],inf)*0.49,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq([2,2,2,1],inf),
	\port, 0,//Pseq([0,0,0.6,0,0.3],inf)
	); //Pexprand(0.03,0.5,inf));
~o2.play;
~o3.play;
~o4.play;
~o5.play;
)


(
~o2.fade(5);
~o3.fade(5);
~o4.fade(3);
~o5.fade(3);
)

Scale.directory
Scale.ushaqMashri.pitchesPerOctave;
Scale.ushaqMashri.stepsPerOctave;

	t = Tuning.sruti;
	t.semitones
	Tuning.default(pitchesPerOctave);
t.semitones
Tuning.directory


//sending MIDI notes to MKS-70
(
~mk1 = Pbind(\type, \midi, \midicmd, \noteOn, \midiout, d[\m2], \scale, Scale.major(\sruti), \degree, Prand((23..37),inf), /* Pseq([Prand((1..16), inf,5), Prand((1..16), inf,7), Prand((1..16), inf,3), Prand((1..16), inf,2)], inf),*/ \dur, 0.5/*Pbjorklund2(Pexprand(2,8).round(1),16,inf,Pwhite(2,4).asStream)/8*/,\amp,Pexprand (0.8, 0.99, inf), \octave, 2);
~mk1.play;
)
~mk1.free



//sending MIDI notes to WS a/d
(
~ws1 = Pbind(\type, \midi, \midicmd, \noteOn, \midiout, d[\m1], \scale, Scale.major, \degree, Pshuf((24..48), inf,5), \dur, Pbjorklund2(Pexprand(2,4).round(1),16,inf,Pwhite(2,4).asStream)/1,\amp,Pexprand(0.1, 0.4, inf), \octave, 0);
~ws1.play;
)
~ws1.free

//MKS-70 sysex
(
~sysExArray = Pbind(
    \type, \midi,
    \midicmd, \sysex,
	\midiout, d[\m7],
	\array, Ptuple([0xf0, 0x41, 0x36, 0x00, 0x24, 0x20, 0x01,
		0x36, Prand((0..80), inf), //env2 sus param, value
		0x37, Prand((0..60), inf), //env2 rel param, value
		0x22, Prand((40..80), inf), //LPF Cutoff param, value
		0x0D, Pseq((1..127), inf, 2), //DCO 1 Tune param, value
		0x13, Pseq((1..127), inf, 3), //DCO 2 Tune param, value
		0x0C, Pexprand(40, 127, inf), //DCO 1 Waveform param, value
		0xf7])
    .collect { |array| [array.as(Int8Array)] },  // <<-- brackets here
	\dur, Pbjorklund2(Pexprand(2,11).round(1),33,inf,Pwhite(1,5).asStream)/4,
).play;
)
~sysExArray.free

//WS a/d sysex
(
~sysExArrayB = Pbind(
    \type, \midi,
    \midicmd, \sysex,
	\midiout, d[\m1],
	\array, Ptuple([0xf0, 0x41, 0x36, 0x00, 0x24, 0x20, 0x02,
		0x22, Pseq((40..80), inf), //LPF Cutoff param, value
		0x0D, Pseq((1..127), inf, 2), //DCO 1 Tune param, value
		0x13, Pshuf((1..127), inf, 3), //DCO 2 Tune param, value
		0x0C, Pexprand(40, 127, inf), 0xf7]) //DCO 1 Waveform param, value
    .collect { |array| [array.as(Int8Array)] },  // <<-- brackets here
	\dur, Pexprand(0.5, 0.5, inf),
).play;
)
~sysExArrayB.free

~c.stop;
~c2.stop;
~k.stop;
~sn.stop;
~mk1.free;
~mk1Filt.free;
s.freeAll;

p.free
s.quit

