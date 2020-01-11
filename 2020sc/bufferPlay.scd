s.boot;

//buffers
(
b = BufFolders(s, "~/git/001set");
b[\kick];
b[\clap];
c = BufFiles(s, "~/git/001set/kick");
c;
)


/*

mbuf: enveloped mono buffer player
For mono buffers only

Arguments:

out = Channel out
buf = Buffer index
rate = Speed of playback
amp = volume
pan = pan (stereo)
atk = attack
rel = release
pos = position to start playback from 0 to 1

*/

(
SynthDef(\mbuf,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, atk=0.01, rel=1, pos=0;
		var sig, env;
		sig = Pan2.ar(PlayBuf.ar(1,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2),pan);
		env = EnvGen.ar(Env.linen(0.0,rel,0.0,1));
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,sig);
}).add;
)


/*

vplay: enveloped stereo buffer player
For stereo buffers only
The default is to have no attack, as I use this to create a 'chopped-up' effect

Arguments:

out = Channel out
buf = Buffer index
rate = Speed of playback
amp = volume
pan = pan (stereo)
atk = attack
sus = sustain
rel = release
pos = position to start playback from 0 to 1

*/

(
SynthDef(\sbuf,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, atk=0.0, sus=1, rel= 0, pos=0;
		var sig, env;
		sig = Pan2.ar(PlayBuf.ar(2,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2),pan);
		env = EnvGen.ar(Env.linen(atk,sus,rel,1),doneAction:2);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,sig);
}).add;
)

(
// Play using a pbind
Pbind(
    \instrument, \mbuf, // (you need to make a bufferPlayer synth to make this work
	\buf, Pxrand(
		[
			Pxrand(b[\sn]),
			Pxrand(b[\kick]),
			Pxrand(b[\kick]),
			Pxrand(b[\kick])],
			inf),
	\dur, Pseq([0.25, 0.25, 0.5, Rest(0.25)] * 0.2,inf),
	\atk, Pexprand(0.001,0.1,inf),
	\rel, Prand([0.2,0.01,0.5,0.2],inf),
	\rate, Pseg(Prand((40..90).mirror1,inf)*0.01,0.05, \lin, inf),
	\pan, Pseg(Pseq((-90..90).mirror1,inf)*0.01,0.005, \sin, inf),
	\pos, 0,//Pexprand(0.001,0.99,inf),
).play;
)




MethodOverride.printAll