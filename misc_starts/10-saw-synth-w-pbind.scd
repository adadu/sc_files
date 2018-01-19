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
).play;
)

x.free;
x.stop;