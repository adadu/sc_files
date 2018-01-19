s.boot;

(
SynthDef.new(\iter, {
	arg freq=40, atk=0.005, rel=0.3, amp=0.8;
	var temp, sum, env;
	sum = 0;
	10.do{
		temp = VarSaw.ar(
			freq * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			0.05!2
		);
		sum = sum + temp;
	};
	env = EnvGen.kr(Env.new([0,0.25,0],[atk,rel],[1,-1]),doneAction:2);
	sum = sum * env;
	Out.ar(0, sum);
}).add;
)

(
x = Pbind(
	\instrument, \iter,
	\freq, Pexprand(Pexprand(1, 5666), 17000, inf),
	\dur, Pgeom(0.1, 1, inf),
	\rest, Pexprand(0.5, 0.2, inf),
);
)



(
SynthDef.new(\fm, { | out, feedback, gate=1, dur = 0.3, freq=440, att = 0.01, amp = 0.5 |
	var env = Env([0.001, 0.99, 0.001], [att, 1.0-att], [\lin, \lin]);
	var envGen = EnvGen.kr(env, doneAction: 2, timeScale: dur);
	Out.ar(out, SinOscFB.ar(freq) * envGen * amp);
}).add;
)


(
y=Prand((55..56), inf);
~fmf = Pbind(
	\instrument, \fm,
	\freq, Pdefn(\fmfFreq, y), //Pexprand(Pexprand(1, 5666), 17000, inf),
	\dur, Pdefn(\fmfDur, 0.3), //Pgeom(0.1, 1, inf),
	\octave, Pdefn(\fmfOctave, 0),
);
)

x = ~fmf.play;

x.stop;





(
Pdefn(\fmfFreq, Pseq([50, 53, 57], inf) * Prand([0.97, 0.92, 0.91, \rest], inf));
Pdefn(\fmfOctave, 8); //Prand((3..8),inf));
Pdefn(\fmfDur, 0.3);
Pdefn(\fm, 0.5);
Pdefn(\fm, 0.0001);
Pdefn(\fm, 0.01);
)

(
Pdefn(\four5octave, Prand((-1..2),inf));
Pdefn(\four5octave, 1.);
Pdefn(\four5att, 0.5);
Pdefn(\four5port, 2);
Pdefn(\four5note, Pseq([50, 53, 57], inf) * Prand([0.97, 0.92, 0.91], inf));
)


Pdefn(\fmfDur, PdurStutter(Pseq((2..5),inf), Pseq([0.3, 0.5, 1], inf)));
Pdefn(\two3dur, PdurStutter(Pseq((2..5),inf), Pseq([0.5, 1, 1.5], inf)));

Pdefn(\four5dur, PdurStutter(Pseq((2..5),inf), Pseq([3, 6, 9], inf)));