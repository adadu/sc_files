s.quit;

//motu 10 channel out setup
(
s.options.device = "MOTU 828mk2";
s.options.numOutputBusChannels = 10;
s.options.outputStreamsEnabled = "1111111111";
s.boot;
)

//query active inputs
s.options.numOutputBusChannels.postln;

//offset synthdef
(
SynthDef(\offset, { arg ch = 2, offset = 0;
	Out.ar(ch, K2A.ar(offset));
}).add;
)

//channel offsets
(
~ch2 = Synth(\offset, [\ch, 2, \offset,  -0.0003]);
~ch3 = Synth(\offset, [\ch, 3, \offset,  -0.0015]);
~ch4 = Synth(\offset, [\ch, 4, \offset,  0.0003]);
~ch5 = Synth(\offset, [\ch, 5, \offset,  -0.0003]);
~ch6 = Synth(\offset, [\ch, 6, \offset,  -0.0026]);
~ch7 = Synth(\offset, [\ch, 7, \offset,  0.001]);
~ch8 = Synth(\offset, [\ch, 8, \offset,  0.0018]);
~ch9 = Synth(\offset, [\ch, 9, \offset,  0.0005]);
~ch0 = Synth(\offset, [\ch, 0, \offset,  -0.00007]);
~ch1 = Synth(\offset, [\ch, 1, \offset,  0.0005]);
)

// 2017.feb.11 for sonarchy

// VOICE ONE zerosc/slave/mmfilter/amp/pan (cp251 slew sh)
// cv 2 pitch for zerosc & slave
// cv 3 for amp env, zerosc index in & exp in
// cv8 for mmfilter freq lev in
// amp out to pan, ctrl by cp251 slew sh

//VOICE TWO osc1 to lpg

//cv w portamento, amp, and aux
(
SynthDef(\dc, { | note, octave = 0, t_trig = 1, ch = nil, port = 0, calibration = 0.2202, amp = 0.01, ampCh = nil, aux = 0.0001, auxCh = nil, att = 0.01, aatt =0.01, dur = 0.1, dur2 = 0.1 |
	var env = Env([0.001, 0.99, 0.001], [att, 1.0-att], [\lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, timeScale: dur);
	var auxEnv = Env([0.001, 0.99, 0.001], [aatt, 1.0-aatt], [\exp, \exp]);
	var auxEnvGen = EnvGen.kr(auxEnv, t_trig, timeScale: dur2);
	note = note + (octave * 12 -1);
	note = (note/12) * calibration;
	//note = note + octave;
	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
	Out.ar(ampCh, K2A.ar(Lag.kr(amp * envGen)));
	Out.ar(auxCh, K2A.ar(Lag.kr(aux * auxEnvGen)));
}).add;
)

// ZEROSC, SLAVE OSC, AMP, MMFILTER
// panning by cp251

(
~two3 = Pmono(
	\dc,
	\ch, 2,
	\ampCh, 3,
	\auxCh, 8,
	\trig, 1,
	\note,  Pdefn(\two3note, Pseq([-48, -36, -24, -12, 0, 12, 24, 36],inf)),
	\octave, Pdefn(\two3octave),
	\dur, Pdefn(\two3dur, 0.1),
	\port, Pdefn(\two3port),
	\legato, Pdefn(\two3legato),
	\amp, Pdefn(\two3amp, 0.8),
	\att, Pdefn(\two3att),
	\aux, Pdefn(\two3aux),
	\aatt, Pdefn(\two3aatt),
	\dur2, Pdefn(\two3dur2)
);
)

// need to code in something like above '\two2note' so you can access only that pmono w Pdefn's OR
// find another way to do it w vars?
x = ~two3.play;

x.stop;

(
Pdefn(\two3note, Pseq([20],inf));
Pdefn(\two3octave, 0);// Pseq((-2..2),inf));
Pdefn(\two3dur, Pseq(Array.fill(32, { arg i; i + 1}).postln, inf) * 0.01);
Pdefn(\two3amp,0.8);
Pdefn(\two3att, 0.0001);
Pdefn(\two3port, 0);
Pdefn(\two3aux, 0);
Pdefn(\two3aatt, 0);
Pdefn(\two3dur2, 0);
)

//001
// zerosc: sine out, no bias, med range
// fm index 7, dyn ac 3, exp in 4
(
//n =
Pdefn(\two3aux, Pshuf([0.9, 0.3, 2, 0.1] * 0.4, inf));//Pwrand(#[0.25, 0.5, 0.75], #[0.5, 0.3, 0.2], inf));
Pdefn(\two3aatt, Pshuf(Array.fill(20, { arg i; i.rand}).postln, inf));
Pdefn(\two3note, Pshuf(Array.fill(20, { arg i; i.rand}).postln, inf));
Pdefn(\two3dur, Pshuf(Array.fill(9, { arg i; i.rand}).postln, inf) * 0.5);
Pdefn(\two3port, 0);
Pdefn(\two3att, Pexprand(0.08, 0.99, inf));
Pdefn(\two3amp, 0.8);
Pdefn(\two3aatt, Pexprand(0.08, 0.99, inf));
Pdefn(\dur2, 2);
Pdefn(\two3octave, Pshuf((-2..3),inf));
//Pdefn((4, n));
)

// zerosc: saw out, high bias, hi range OR med range
//can increase cv amt on exp in OR can switch range up to either med or high
// manipulate multiplier of dur for studder, good range is 0.02 and up
(
Pdefn(\two3dur, Pshuf([0.9, 0.3, 2, 0.1] * 0.08, inf));
Pdefn(\two3port, Pshuf([0.3, 0.1, 0.8, 0.2], inf));
Pdefn(\two3note, Pshuf([-4, -5, -2, -1] * 4, inf));
Pdefn(\two3att, Pexprand(0.08, 0.99, inf));
Pdefn(\two3amp, 0.8);
Pdefn(\two3aux, Pexprand(0.01, 0.99, inf));
Pdefn(\two3aatt,	Pexprand(0.01, 0.99, inf));
Pdefn(\two3dur2, 3);
)

// follow previous to dynamicize
// manipulate dur multiplier depending on how long
(
Pdefn(\two3amp, Pexprand(3, 9, inf) -1 * 0.1).round;
Pdefn(\two3note, Pexprand(-12, -2, inf) - 1).round;
Pdefn(\two3dur, Pexprand(1, 9, inf) - 1 * 1).round;
Pdefn(\two3octave, Pshuf((-3..3), inf));
)

//??
(
Pdefn(\two3amp, Pshuf((1..9) * 0.1, inf));
Pdefn(\two3note, Pshuf((-12..0), inf, 3));
Pdefn(\two3dur, Pshuf((1..10) * 0.1, inf));
Pdefn(\two3aux, 0.2);
Pdefn(\two3amp, Pexprand(1, 9, inf) -1 * 0.1).round;
Pdefn(\two3octave, Pseq((-3..4), inf));
Pdefn(\two3dur2, 5);
)

x.stop;


// tri osc1
(
~four5 = Pmono(
	\dc,
	\ch, 4,
	\ampCh, 5,
	//auxCh,,
	\trig, 1,
	\note,  Pdefn(\four5note, Pseq((1..7),inf)),
	\octave, Pdefn(\four5octave, Pseq((-4..4), inf)),
	\dur, Pdefn(\four5dur, 0.1),
	\port, Pdefn(\four5port),
	\legato, Pdefn(\four5legato),
	\amp, Pdefn(\four5amp, 0.8),
	\att, Pdefn(\four5att,0.5),
	\aux, Pdefn(\four5aux, 0),
	\aatt, Pdefn(\four5aatt),
	\dur2, Pdefn(\four5dur2)
);
)

y = ~four5.play;

y.stop;

// tri osc2
(
~six7 = Pmono(
	\dc,
	\ch, 6,
	\ampCh, 7,
	//auxCh,,
	\trig, 1,
	\note,  Pdefn(\six7note, Pseq((1..7), inf)),
	\octave, Pdefn(\six7octave, Pseq((-4..4), inf)),
	\dur, Pdefn(\six7dur, 0.1),
	\port, Pdefn(\six7port),
	\legato, Pdefn(\six7legato),
	\amp, Pdefn(\six7amp, 0.99),
	\att, Pdefn(\six7att,0.5),
	\aux, Pdefn(\six7aux, 0),
	\aatt, Pdefn(\six7aatt),
	\dur2, Pdefn(\six7dur2)
);
)

(
y = ~four5.play;
z = ~six7.play;
)
x.play;

x.stop;
(
y.stop;
z.stop;
)

// tri outs osc1 & osc2,

(
Pdefn(\four5note, Pshuf(Array.fill(21, { arg i; i * 3}).postln, inf));
Pdefn(\four5octave, Pseq((-4..4), inf));
Pdefn(\four5dur, Pshuf(Array.fill(14, { arg j; j * 2} * 0.1).postln, inf));
Pdefn(\four5port, 0);
Pdefn(\four5legato, 0);
Pdefn(\four5amp, 0.99);
Pdefn(\four5att, Pshuf(Array.fill(14, { arg k; k * 3} * 0.1).postln, inf));
Pdefn(\four5aux, 0);
Pdefn(\four5aatt);
Pdefn(\four5dur2);
)

(
Pdefn(\six7note, Pshuf(Array.fill(21, { arg i; i * 4}).postln, inf));
Pdefn(\six7octave, Pseq((-4..4), inf));
Pdefn(\six7dur, Pshuf(Array.fill(14, { arg j; j * 4} * 0.1).postln, inf));
Pdefn(\six7port, 0);
Pdefn(\six7legato, 0);
Pdefn(\six7amp, 0.99);
Pdefn(\six7att, Pshuf(Array.fill(14, { arg k; k * 2} * 0.1).postln, inf));
Pdefn(\six7aux, 0);
Pdefn(\six7aatt);
Pdefn(\six7dur2);
)

// Play together OR offset for rythmic variations
Pdefn(\four5dur, Pseq([Pn(0.25, 8), Pn(1/3, 6), Pn(1/5, 5)], inf));
Pdefn(\six7dur,  Pseq([Pn(0.25, 8), Pn(1/3, 6), Pn(1/5, 5)], inf)); //Pseq([Pn(1/16, 8), Pn(1/8, 6), Pn(1/7, 5)], inf));

//TEMPO change
TempoClock.default.tempo = 90/160; //40





	