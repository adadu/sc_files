s.boot;
{ Out.ar(0, LFSaw.ar(0.1,0,1)) }.play
{ Out.ar(0, SinOsc.ar(40, 0, 0.5)) }.play


//AUDIO sine out
SynthDef(\sinOut, { | freq = 440, t_trig, ch = nil, amp = 1, ampCh = nil, att = 0.01, dur = 1 |
	var env = Env([0.001, 0.99, 0.001], [att, 1.0-att], [\lin, \lin]);
	var level = amp * 2.6;
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	Out.ar(ch, SinOsc.ar(freq, 0, 1, 0));
	Out.ar(ampCh, K2A.ar(Lag.kr(amp * envGen)));
}).add;

//INIT PDEFNS
(
//zero + mini osc w snappy env
~sinTest = Pmono(
	\sinOut,
	\ch, 0,
	//\ampCh, 4,
	\trig, 1,
	\note, Pdefn(\xxnote, 60),
	\octave, Pdefn(\xxoct, 0),
	\dur, Pdefn(\xxdur, 1),
	\port, Pdefn(\xxport, 0),
	\att, Pdefn(\xxatt, 0.001),
	\amp, Pdefn(\xxamp, 1),
	//\calibration, Pdefn(\v2cal, 0.09773),
	//\midiTune, Pdefn(\v2mt, -23.61),
	//\spo, Pdefn(\v2spo, 12),
	//\stretch, Pdefn(\v2stretch, 1.0),
);
)

//start
q = ~sinTest.play(quant:1);
//stop
q.stop

(
// xx
Pdefn(\xxnote, Pseq([20,36,40],inf));
Pdefn(\xxoct, 0);
Pdefn(\xxdur, 0.2);
Pdefn(\xxamp, 0.5):
Pdefn(\xxatt, 0.001);
Pdefn(\xxport, 0.1);
)