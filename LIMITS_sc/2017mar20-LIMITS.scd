(
// 01 --- motu 10 channel out setup
s.options.device = "MOTU 828mk2";
s.options.numOutputBusChannels = 10;
s.options.outputStreamsEnabled = "1111111111";
s.options.numOutputBusChannels.postln;
s.boot;
)

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
)

(
~two3 = Pmono(
	\dc,
	\ch, 2,
	\ampCh, 3,
	\auxCh, 8,
	\deg, Pdefn(\two3deg),
	\midiCvOff, Pdefn(\two3mCO),
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

(
~four5 = Pmono(
	\dc,
	\ch, 4,
	\ampCh, 5,
	\auxCh, 9,
	\deg, Pdefn(\four5deg),
	\midiCvOff, Pdefn(\four5mCO),
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

(
t = ~two3.play(quant: 1);
u = ~four5.play(quant: 1);
)

(
t.stop;
u.stop;
)

(
q=3;
r=48; //Prand([-2,-1,0,1,2,3,4],inf);
t=Pseq((36..96),inf);
u=Pseq((0..1),inf);

//tune to midi
Pdefn(\two3note, r);
Pdefn(\four5note, r);
Pdefn(\two3cal, 0.2209);
Pdefn(\four5cal, 0.2209);
Pdefn(\two3offset, -0.0005);
Pdefn(\four5offset, -0.0005);
Pdefn(\two3deg, 12);
Pdefn(\four5deg, 12);
Pdefn(\two3mCO, -84);
Pdefn(\four5mCO, -84);
Pdefn(\two3octave,u);
Pdefn(\four5octave,u);
Pdefn(\two3dur, q);
Pdefn(\four5dur, q);
Pdefn(\two3port, 0);
Pdefn(\four5port, 0);
Pdefn(\two3legato, 0);
Pdefn(\four5legato, 0);
Pdefn(\two3amp, 1);
Pdefn(\four5amp, 1);
Pdefn(\two3att, 0.001);
Pdefn(\four5att, 0.001);
Pdefn(\two3aux, nil);
Pdefn(\four5aux, nil);
Pdefn(\two3aatt, nil);
Pdefn(\four5aatt, nil);
Pdefn(\two3dur2, nil);
Pdefn(\four5dur2, nil);
)


(
Pdefn(\two3note, Pseq([50, 53, 57], inf) * Prand([0.97, 0.92, 0.91, \rest], inf));
Pdefn(\two3octave, Prand((-1..4),inf));
Pdefn(\two3octave, 0);
Pdefn(\two3dur, 0.5);
Pdefn(\two3att, 0.0001);
Pdefn(\two3port, 0.01);
)

(
Pdefn(\four5octave, Prand((-1..2),inf));
Pdefn(\four5octave, 1.);
Pdefn(\four5att, 0.5);
Pdefn(\four5port, 2);
Pdefn(\four5note, Pseq([50, 53, 57], inf) * Prand([0.97, 0.92, 0.91], inf));
)


Pdefn(\two3dur, PdurStutter(Pseq((2..5),inf), Pseq([0.3, 0.5, 1], inf)));
Pdefn(\two3dur, PdurStutter(Pseq((2..5),inf), Pseq([0.5, 1, 1.5], inf)));

Pdefn(\four5dur, PdurStutter(Pseq((2..5),inf), Pseq([3, 6, 9], inf)));
