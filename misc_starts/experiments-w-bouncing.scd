//experiments with bouncing

(
SynthDef(\bouncer, {
var bounceperiod, bouncetrigs, amp, fm, mainosc, ch = 13, ampCh = 5;
bounceperiod = Line.kr(0.3, 0, 3, doneAction: 2);
bouncetrigs = Impulse.kr(bounceperiod.reciprocal.min(30));
amp = EnvGen.ar(Env.perc(0.001, 0.0), bouncetrigs);
amp = Amplitude.ar(amp, 0, bounceperiod) * Line.kr(1, 0.05, 3, doneAction: 2);
fm = SinOsc.ar(120).range(0, Line.ar(1, 0, 3, doneAction: 2)) + (amp * Line.ar(1, 0, 3, doneAction: 2).cubed * 130 + 80);
mainosc = SinOsc.ar(fm, pi/2);
Out.ar(ch, amp * mainosc);
Out.ar(ampCh, amp);
}).add;
)

(
~v5 = Pmono(
	\bouncer,
	\ch, 13,
	\ampCh, 5,
	\trig, 1,
	//\midinote, Pdefn(\v5note, 60),
	//\dur, Pdefn(\v5dur, 0.4),
	//\att, Pdefn(\v5att, 0.001),
	//\amp, Pdefn(\v5amp, 0.8),
);
)