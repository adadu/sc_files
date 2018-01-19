s.quit;

//motu 10 channel out setup
(
s.options.device = "MOTU 828mk2";
s.options.numOutputBusChannels = 10;
s.options.outputStreamsEnabled = "1111111111";
s.boot;
)

//query active inputs
s.options.numInputBusChannels.postln;

//offset synthdef
(
SynthDef(\offset, { arg ch = 2, offset = 0;
	Out.ar(ch, K2A.ar(offset));
}).add;
)

//channel offsets
(
x = Synth(\offset, [\ch, 2, \offset,  -0.0004]);
x = Synth(\offset, [\ch, 3, \offset,  -0.0015]);
x = Synth(\offset, [\ch, 4, \offset,  0.00015]);
x = Synth(\offset, [\ch, 5, \offset,  -0.0003]);
x = Synth(\offset, [\ch, 6, \offset,  -0.0026]);
x = Synth(\offset, [\ch, 7, \offset,  0.001]);
x = Synth(\offset, [\ch, 8, \offset,  0.0018]);
x = Synth(\offset, [\ch, 9, \offset,  0.0005]);
x = Synth(\offset, [\ch, 0, \offset,  -0.00007]);
x = Synth(\offset, [\ch, 1, \offset,  0.0005]);
)

//cv w portamento and trig
(
SynthDef(\dc, { arg note, octave, ch = 2, port = 0, calibration = 0.2202, t_envgate = 0, gateCh = 3, trigLen = 0.1;
	var gate;
	note = ((note/12)) * calibration;
	//octave = octave * 12;
	//note = note + octave -1;
	gate = Trig1.kr(t_envgate, trigLen).range(0,5);
	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
	Out.ar(gateCh, K2A.ar(gate));
}).add;
)

//global sequence variables
(
a = Prand([0, 0, 0, 0,0,0, 5], inf);
n = Pser([1,20,10,12, -35], 2);
m= Pser([13,-12, -4], 2);
o = Pseq([1,2,3],inf) * 12 -1;
)

//DEFINE Pdefs: 2 ch available for ea pitch & trig

/*
patch: REVERB
mixer aux send 1 > rev in
rev out > mixer ch (roll off hi)
cv2 > osc2 in > saw > lpg1 sig in
cv3 > lpg1 cv in
cv4 > pan ctl in
pan out1 > mix ch
pan out2 > mix ch (mute), aux1 @ 2
*/

//REVERB Pan slither rubber

(
Pdef(\mtf23,
	Pmono(
	\dc,
	\ch, 2,
		\gateCh, 3,
		\note, Prand([-48, -36, -24, -12, 0, 12, 24, 36, 48], inf),
		\dur, 0.2,
		\port, 0.2,
		//\note, Pshuf([-40,-30, n, -37, -35, m, 0], inf),
	   \dur, Pshuf([1, 1, 2, 1]*0.02, inf) + Pshuf((1..8)*0.04,inf),
		//\note, Prand([-16, -15, 1, 1, -1, 2, -20, -15], inf),
		//\dur, Pseq([1, 1, 2, 1]*0.2, inf), //Pseq( [0.01] + [n,1], inf),
		\dur, Pseq([Pn(0.25, 8), Pn(1/3, 6), Pn(1/5, 5)], inf),
		//\note, Pseq([12, -12, 0, 13, 14, 15, 6], inf) *a,
		\envgate, 1,
		\trigLen, 0.025,
	\dur, Pseq([0.75, 0.25, 0.25, 0.25, 0.5], inf),
	 //\legato, Pseq([0.9, 0.3, 0.3, 0.3, 0.3], inf),
	//\port, Pseq([0.03, 0, 0.2, 0.01], inf),
));
)

(
Pdef(\mtf4,
	Pmono(
	\dc,
	//\ch, 4,
		\gateCh, 4,
		\envgate, a,
		\trigLen, 0.025,
	    \dur, Pseq([0.75, 0.25, 0.25, 0.25, 0.5], inf),
	 //\legato, Pseq([0.9, 0.3, 0.3, 0.3, 0.3], inf),
));
)

d = Pshuf([5,7,2], inf);

//FILTERED
(
Pdef(\mtf56,
	Pmono(
	\dc,
	\ch, 5,
		\gateCh, 6,
		\note, Pshuf([-48, -36, -24, -12, 0, 12, 24, 36, 48], inf) / 12,
		\dur, 0.01,
		\port, 0.2,
		\note, Pseq([-40,-30, n, -37, -35, m], inf)+ o,
	    //\dur, Pseq([1, 1, 2, 1]*0.02, inf) + Pseq((1..8)*0.04,inf),
		//\note, Pseq([-16, -15, 1, 1, -1, 2, -20, -15], inf),
		\dur, Pseq([1, 1, 2, 1, Rest(2)], inf)/ d,
		//\dur, Pseq([Pn(1/16, 8), Pn(1/8, 6), Pn(1/7, 5)], inf) /d,
		//\note, Pseq([12, -12, 0, 13, 14, 15, 6], inf),
		\envgate, 1,
		\trigLen, 0.025,
	//\dur, Pseq([0.75, 0.25, 0.25, 0.25, 0.5], inf),
	 //\legato, Pseq([0.9, 0.3, 0.3, 0.3, 0.3], inf),
		\port, Pshuf([0.03, 0, 0.2, 0.1], inf),
));
)

/*
(
Pdef(\mtf7,
	Pmono(
	\dc,
	\ch, 5,
		\note, Pshuf([-48, -36, -24, -12, 0, 12, 24, 36, 48], inf),
		//\note, Pseq([-40,-30, n, -37, -35, m], inf)+ o,
		\dur, Pseq([1, 1, 2, 1]*2.5, inf) + Pseq((1..8)*0.1,inf),
		\gateCh, 6,
		\envgate, 1,
		\trigLen, 0.025,
		//\port, 0.3,
));
)
*/

//FM

b = Pshuf([1,2,3, Rest (1), 0.5], inf);
c = 0.1;
(
Pdef(\mtf78,
	Pmono(
	\dc,
	\ch, 7,
		\note, Pshuf([-48, -36, -24, Rest(5), -12, 0, 12, 24, Rest(10), 36, 48], inf),
		//\note, Pseq([n, Rest(2), m], inf)+ o,
		\dur, Pshuf((0.1..1),inf)  * b,
		//\dur, Pseq([1, 1, 2, 1]*2.5, inf) + Pseq((1..8)*0.1,inf) *c,
		\gateCh, 8,
		\envgate, 1,
		\trigLen, 0.025,
		//\port, 0.3,
));
)



//PLAY Pdefs
(
Pdef(\mtf23).play;
Pdef(\mtf4).play;
Pdef(\mtf56).play;
Pdef(\mtf78).play;
)

//STOP Pdefs
(
Pdef(\mtf23).stop;
Pdef(\mtf4).stop;
Pdef(\mtf56).stop;
Pdef(\mtf78).stop;
)

//TEMPO change
TempoClock.default.tempo = 90/60; //40


	