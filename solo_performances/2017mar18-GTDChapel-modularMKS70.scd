// ---- MARCH 18 performance

// 00 --- pwr on CPU, 828, BCR, MKS, modular, open midi patchbay > OPEN mar18.mbp

(
// 01 --- motu 10 channel out setup
s.options.device = "MOTU 828mk2";
s.options.numOutputBusChannels = 10;
s.options.outputStreamsEnabled = "1111111111";
s.options.numOutputBusChannels.postln;
s.boot;
//midi
MIDIClient.init;
MIDIClient.destinations;
)

// 02 --- begin cv synthdef, midi out port, globals
(
SynthDef(\dc, { | note, octave = 0, deg = 12, midiCvOff  = -84, t_trig = 1, ch = nil, port = 0, calibration = 0.2202, offset = 0, amp = 0.01, ampCh = nil, aux = 0.0001, auxCh = nil, att = 0.01, aatt =0.01, dur = 0.1, dur2 = 0.1 |
	var env = Env([0.001, 0.99, 0.001], [att, 1.0-att], [\lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, timeScale: dur);
	var auxEnv = Env([0.001, 0.99, 0.001], [aatt, 1.0-aatt], [\exp, \exp]);
	var auxEnvGen = EnvGen.kr(auxEnv, t_trig, timeScale: dur2);
	note = note;
	note = note + (octave * deg) + midiCvOff;
	note = (note / deg) * calibration + offset;
	//note = note + octave;
	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
	Out.ar(ampCh, K2A.ar(Lag.kr(amp * envGen)));
	Out.ar(auxCh, K2A.ar(Lag.kr(aux * auxEnvGen)));
}).add;

//global vars:
//midi out var
~mOut = MIDIOut.newByName("828mk2", "MIDI Port");
//tuning related
h = Prand((1..24), inf);
i = 6;
j = i * 2;
t = {Pdefn(\two3amp, -1); Pdefn(\four5amp, -1); };
p = {128.do({ |pitch| ~mOut.noteOff(0, pitch, 0); }); }; CmdPeriod.add(p);
)

// 03 --- begin midi and pmonos
(
//start midi
~mks = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, ~mOut,
	\chan, Pdefn(\mksCh, 0),
	\note, Pdefn(\mksNote, 60),
	\octave, Pdefn(\mksOct, 0),
	\dur, Pdefn(\mksDur, 0.5),
	\amp, Pdefn(\mksAmp, 1),
	\control, Pdefn(\mksCont),
	\bend, Pdefn(\mksBend),
);
)

(
//two3: osc1
~two3 = Pmono(
	\dc,
	\ch, 2,
	\ampCh, 3,
	\auxCh, 8,
	\trig, Pdefn(\two3trig, 1),
	\deg, Pdefn(\two3deg, 12),
	\midiCvOff, Pdefn(\two3mCO, -84),
	\note,  Pdefn(\two3note),
	\octave, Pdefn(\two3octave),
	\dur, Pdefn(\two3dur),
	\port, Pdefn(\two3port),
	\legato, Pdefn(\two3legato),
	\amp, Pdefn(\two3amp),
	\att, Pdefn(\two3att),
	\aux, Pdefn(\two3aux),
	\aatt, Pdefn(\two3aatt),
	\dur2, Pdefn(\two3dur2),
	\calibration, Pdefn(\two3cal),
	\offset, Pdefn(\two3offset),
);
)


//four5: zerosc/slave
(
~four5 = Pmono(
	\dc,
	\ch, 4,
	\ampCh, 5,
	\auxCh, 9,
	\trig, Pdefn(\four5trig, 1),
	\deg, Pdefn(\four5deg, 12),
	\midiCvOff, Pdefn(\four5mCO, -84),
	\note, Pdefn(\four5note),
	\octave, Pdefn(\four5octave),
	\dur, Pdefn(\four5dur),
	\port, Pdefn(\four5port),
	\legato, Pdefn(\four5legato),
	\amp, Pdefn(\four5amp),
	\att, Pdefn(\four5att),
	\aux, Pdefn(\four5aux),
	\aatt, Pdefn(\four5aatt),
	\dur2, Pdefn(\four5dur2),
	\calibration, Pdefn(\four5cal, 0.2202),
	\offset, Pdefn(\four5offset, -0.0012),
);
)
// 03 --- END


(
//stop
x.stop;
d.stop;
y.stop;
(128.do({ |pitch| ~mOut.noteOff(0, pitch, 0); });)
)

// no 5 or 6
(
// 06 --- PART_01, begin dark beginnings, mks drone + 24 tone zerosc morph

//mks dark cluster
~mOut.program(0, 6);
Pdefn(\mksNote, Prand([ [33, 35, 39, 42, 50, 53]], inf));
Pdefn(\mksOct, 1);
Pdefn(\mksDur, 60 * 7);

//four5 zerosc/slave 1v/oct
j=6;
//delete if possible
Pdefn(\four5offset, 0.0001);
Pdefn(\four5cal, 0.2215);
//reset deg
Pdefn(\four5deg, 24);
//seqs
Pdefn(\four5note, -12 + h);
Pdefn(\four5octave,1);
Pdefn(\four5dur, j * Prand((1.3..1.9),inf));
Pdefn(\four5port, 12);
Pdefn(\four5legato, 0);
Pdefn(\four5amp, 1);
Pdefn(\four5att, Pmeanrand(0.2, 0.5, inf));
Pdefn(\four5aux, Pmeanrand(0.3, 1, inf));
Pdefn(\four5aatt, Pmeanrand(0.2, 0.7, inf));
Pdefn(\four5dur2, Pwhite((j*0.8), (j*1.7), inf)); //Prand((2..3) * j, inf));

//two3 slave aux to cv-lin in 10
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

(
//start
x = ~two3.play(quant:1);
y = ~mks.play(quant:1);
d = ~four5.play(quant: [1, 0, 20]);
)

(
//start
x = ~two3.play(quant:1);
y = ~mks.play(quant:1);
d = ~four5.play(quant: 1);
)

(
//stop
x.stop;
y.stop;
d.stop;
(128.do({ |pitch| ~mOut.noteOff(0, pitch, 0); });)
)

//after modular
(
Pdefn(\two3note, a * Pshuf((2..16), inf));
Pdefn(\two3amp, Pmeanrand(0.9, 1.00, inf));
Pdefn(\two3octave, Pseq((2..4),inf));
Pdefn(\two3dur, Pseq(Array.fill(32, { arg i; i*1.5}).postln, inf) * 0.01);
Pdefn(\two3dur, PdurStutter(Pseq((1..4), inf), Pseq(Array.fill(16, { arg i; i*1.33}).postln, inf) * 0.1), inf);
Pdefn(\two3att, Pmeanrand(0.001, 0.05, inf));
Pdefn(\two3port, Prand([0, 0.8],inf));
//Pdefn(\two3aux, 1);
//Pdefn(\two3aux, Pslide((1..10) * 0.1, inf, 2, 1, 0));
//Pdefn(\two3aux, 0);
//Pdefn(\two3aatt, 0);
)

d = ~four5.play(quant:1);

//mute LPGS setting amps to -1
t.value;

// 07 --- PART_02, hyperorgd octave jumps, mks prog ch/midi seq + zerosc deg 12 tone set/seq

// 08 --- PART_03, silence & noise break

// 09 --- PART_04, rhythmic-semi-melodic - mks prog ch/midi seq into mod

// PLACE INTO PARTS...
(
//two3 ZONE
a = Pslide([1, 2, 3, 4, \rest, \rest], inf, 3, 1, 0);
b = a.asStream;
20.do({ b.next.post; });
c = Pslide([1, 2, 3, 4] * 0.1, inf, 3, 1, 0);
Pdefn(\two3note, Pshuf([33, 35, 39, 42, 50, 53],inf));
//Pdefn(\two3note, a + 84);
//Pdefn(\two3note, Prand([33, 38, 41] + 8,inf));
Pdefn(\two3octave, 2);
Pdefn(\two3octave, Pshuf((2..6),inf));
//Pdefn(\two3octave, 1);//Prand((2..8),inf));
//Pdefn(\two3dur, Pseq(Array.fill(32, { arg i; i*1.5}).postln, inf) * 0.01);
//Pdefn(\two3dur, Pslide((1..6) * 0.05, inf, 3, 1, 0));
Pdefn(\two3dur, c);
Pdefn(\two3amp,0.99 );
//Pdefn(\two3att, 0.1);
Pdefn(\two3att, Pwhite(0.001, 0.002, inf));
//Pdefn(\two3port, 0.0);
//Pdefn(\two3dur2, Pslide((1..6), inf, 2, 1, 0));
Pdefn(\two3dur2, c);
//Pdefn(\two3aux, 1);
Pdefn(\two3aux, Pmeanrand(0.1, 1, inf));
//Pdefn(\two3aux, Pslide((1..10) * 0.1, inf, 2, 1, 0));
//Pdefn(\two3aux, 0);
Pdefn(\two3aatt, Pslide((1..6) * 0.5, inf, 2, 1, 0));
//Pdefn(\two3aatt, 0);
)

(
Pdefn(\two3aux, Pshuf((0.1..1.0), inf));//Pwrand(#[0.25, 0.5, 0.75], #[0.5, 0.3, 0.2], inf));
Pdefn(\two3aatt, Pshuf(Array.fill(20, { arg i; i.rand}).postln, inf));
Pdefn(\two3note, Pshuf(Array.fill(20, { arg i; i.rand*5}).postln, inf));
Pdefn(\two3note, Prand([33, 35, 39, 42, 50, 53], inf) * Prand([4/3, 5/4, 6/5, \rest], inf));
Pdefn(\two3dur, Pshuf(Array.fill(9, { arg i; i.rand}).postln, inf) * 0.05);
Pdefn(\two3port, 0);
Pdefn(\two3att, Pexprand(0.01, 0.001, inf));
Pdefn(\two3amp, 1);
Pdefn(\two3aatt, Pgeom(0.01, 1.67, inf));
Pdefn(\two3dur2, Prand((1..5), inf) * Prand([4/3, 5/4, 6/5], inf));
Pdefn(\two3octave, Pshuf((3..5),inf));
)

(
y.stop;
128.do({ |pitch| ~mOut.noteOff(0, pitch, 0); });
)


(
//start
x = ~two3.play(quant:1);
y = ~mks.play(quant:1);
d = ~four5.play(quant: 1);
)

(
//mks ZONE 1
~mOut.program(0, 3);
Pdefn(\mksNote, Prand([[33, 35, 39, 42, 50, 53], \rest], inf) * Prand([4/3, 5/4, 6/5, \rest], inf));
Pdefn(\mksOct, 0);
Pdefn(\mksDur, PdurStutter(Pseq((2..3),inf), Pseq([0.3, 0.5, 0.7], inf)));
)

/opt
Pdefn(\mksOct, Pshuf((0..2),inf));

(
//mks ZONE 2
~mOut.program(0, 3);
Pdefn(\mksNote, Prand([ [33, 35, 39, 42, 50, 53]], inf) * Pseq([4/3, 5/4, 6/5, \rest], inf));
Pdefn(\mksOct, 1);
Pdefn(\mksDur, PdurStutter(Pseq((2..5),inf), Pseq([0.3, 0.5, 0.7], inf)));
)

//opt
Pdefn(\mksOct, Pshuf((0..2),inf));
Pdefn(\mksOct, Pshuf((0..1),inf));
Pdefn(\mksDur, 0.1);

//NEW NEW NEW
(
//mks ZONE 3 thru modular
~mOut.program(0, 7);
Pdefn(\mksNote, Pshuf([ [63, 68, 69], [61,66, 68], \rest] ,inf) * Pseq([3/3, 3/4], inf));
Pdefn(\mksDur, 0.1);
Pdefn(\mksOct, 0);
)
//opt
Pdefn(\mksNote, Pshuf([ [63, 68, 69], [61,66, 68]] ,inf) * Pseq([3/3, 2/1], inf));
Pdefn(\mksDur, PdurStutter(Pseq((2..5),inf), Pseq([0.3, 0.5, 0.7], inf)));
Pdefn(\mksOct, Pshuf((0..1),inf));
Pdefn(\mksOct, Pshuf((0..2),inf));

(
Pdefn(\mksNote, Prand([[0,1,2], \rest, [1,4,5,8], \rest, [1,3,4,5,8], \rest, [1,2,3,6,7,8], \rest] * 5, inf) * Prand([4/3, 5/4, 6/5, \rest], inf));
Pdefn(\mksNote, Pshuf([ [63, 68, 69], [61,66, 68], [55, 88]] ,inf));
Pdefn(\mksNote, Prand([ [33, 35, 39, 42, 50, 53], \rest], inf) * Prand([4/3, 5/4, 6/5, \rest], inf));
Pdefn(\mksNote, Prand([ [33, 35, 39, 42, 50, 53] ],inf) * Prand([4/3, 5/4, 6/5, \rest], inf));
Pdefn(\mksNote, Pshuf([[33, 35, 39, 42, 45], [38, 40, 44, 47, 50], [41, 43, 47, 50, 53]], inf) * Prand([4/3, 5/4, 6/5, \rest], inf));
)

Pdefn(\mksOct, 0);
Pdefn(\mksOct, 1);
Pdefn(\mksOct, 2);
Pdefn(\mksOct, Pshuf((0..1),inf));
Pdefn(\mksOct, Pshuf((0..4),inf));
Pdefn(\mksOct, Pshuf((0..2),inf));

Pdefn(\mksDur, 0.05);
Pdefn(\mksDur, 0.1);
Pdefn(\mksDur, 0.3);
Pdefn(\mksDur, 0.5);
Pdefn(\mksDur, 1);
Pdefn(\mksDur, 10);
Pdefn(\mksDur, Pwhite(1, 3, inf));
Pdefn(\mksDur, Pwhite(0.1, 0.3, inf));

)

(
//start w delay
x = ~two3.play(quant:1);
y = ~mks.play(quant:1);
d = ~four5.play(quant: [1, 0, 20]);
)

(
//start
x = ~two3.play(quant:1);
y = ~mks.play(quant:1);
d = ~four5.play(quant: 1);
)

(
//stop
x.stop;
y.stop;
d.stop;
(128.do({ |pitch| ~mOut.noteOff(0, pitch, 0); });)
)