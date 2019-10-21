/*
It is not possible to boot a server on a remote machine, but if you have one running already or you know of one running, you can send messages to it. You create the server object using the IP address of the machine running the server and the port it is using.


// without the IDE you can always run sclang from the commandline

$ sclang yourprogram.scd
// boot the server by puting your code that you pass to sclang into:

Server.default.waitForBoot {
         (... your code ...)
}

*/
s = Server.remote(\rpi, NetAddr("192.168.2.2", 57110,0));
s.boot
s.serverRunning

Server.remote(name, addr, options, clientID)

Server.remote(\rpi, NetAddr("192.168.2.2", 57110), o, 0);

(
o = ServerOptions.new;
o.maxLogins = 8;
s = Server.remote(\rpi, NetAddr("127.0.0.1", 57110), o); //127.0.0.1:57110 //"192.168.2.2", 57110
s.serverRunning;
s.boot;
{ [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play(s);
)

s.sendMsg(\rpi, { [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play);

a.set(\freq, [220, 330]);
s.sendMsg(\rpi, {a.set(\freq, 220)});

n = NetAddr(\rpi, 57110);
n = s.addr;
n.sendMsg(


// All clear and quit
p.clear;
s.quit;

// Setup audio io, boot & add proxyspace
(
//SERVER and BUFFER
//increased buffers for samples
s.options.numBuffers = 1024 * 16;
//this is about 1GB, may vary based on RAM
s.options.memSize=2.pow(21);
//2.pow(21).postln;
//boot server
s.boot;

// CORM macOS aggregate Audient iD4 + USBStreamer
s.options.device = "CORM";
s.options.outputStreamsEnabled = "1111111111";
s.options.numInputBusChannels = 2;
s.options.numOutputBusChannels = 10;
"INs".postln;
s.options.numInputBusChannels.postln;
"OUTs".postln;
s.options.numOutputBusChannels.postln;

//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 2;
)


NetAddr("192.168.2.2", 52705).sendMsg(\shutdown);


// Korg nanoKontrol2
/*
S1 freeze, S2 scamble, S3 fftNoise, S4 enhance, s5 conformer, S6 bin, S7 mag
M1 lorises, M2, hirises (sin ch)
R1 stop mod1 & mod2, R2 nil, R3 p1, R4 p2, R5 p3, R6 p4, R7 p5, R8 p6
*/


////////// SYNTHDEFS /////////////
// 8 synths will appear for offsets
(

//microkontrol
k = MKtl(\nk2, "*trol2");

//offset synthdef
SynthDef(\offset0, { arg ch = nil, offset = -1;
	Out.ar(ch, K2A.ar(offset));
}).add;

// offsets for es3
~ch02 = Pmono(\offset0, \ch, 2, \offset, Pdefn(\ch10off, -0.0001));              // -0.0001
~ch03 = Pmono(\offset0, \ch, 3, \offset, Pdefn(\ch11off, 0.00169));             //  0.00169
~ch04 = Pmono(\offset0, \ch, 4, \offset, Pdefn(\ch12off, -0.0034));            // -0.0035
~ch05 = Pmono(\offset0, \ch, 5, \offset, Pdefn(\ch13off, -0.0002));           // -0.0002
~ch06 = Pmono(\offset0, \ch, 6, \offset, Pdefn(\ch14off, 0));                // 0
~ch07 = Pmono(\offset0, \ch, 7, \offset, Pdefn(\ch15off, 0.0001));          // 0.0001
~ch08 = Pmono(\offset0, \ch, 8, \offset, Pdefn(\ch16off, -0.0001));        // -0.0001
~ch09 = Pmono(\offset0, \ch, 9, \offset,Pdefn(\ch17off, -0.0018));        // -0.0018

SynthDef(\dcev, { | note=60, octave = 0, stepsPerOctave = 12, t_trig, atk=0, sus=0, rel=3, ch = nil, port = 0, calibration = 0.1, midiTune = 0, amp = 1, ampCh = nil, dur = 1 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	note = note;
	note = note + (octave * stepsPerOctave) + midiTune;
	note = (note / stepsPerOctave) * calibration;
	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
	Out.ar(ampCh, K2A.ar(Lag.kr(envGen)));
}).add;
// free synths so they don't start until triggered
//~dc.free;

// sc virtual osc
SynthDef(\sinOut, { | freq = 440, t_trig, ch = nil, atk=0, sus=0, rel=3, amp = 0.5, ampCh = nil, dur = 1, octave = 0, stepsPerOctave = 12 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	var sig = SinOsc.ar(freq, 0, 1, 0);
	freq = freq + (octave * stepsPerOctave);
	freq = freq / stepsPerOctave;
	Out.ar(ch, sig * envGen);
	//Amp for audio rate modulation
	//Out.ar(ampCh, K2A.ar(Lag.kr(amp * envGen)));
}).add;

/*
vplaym: enveloped mono buffer player
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
SynthDef(\vplaym,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, atk=0.01, rel=1, pos=0;
		var sig, env;
		sig = Pan2.ar(PlayBuf.ar(1,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2),pan);
		env = EnvGen.ar(Env.linen(0.0,rel,0.0,1));
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,sig);
}).add;

// fft freeze
~freeze = SynthDef(\fftFreeze, {
    arg out = 0;
	var in, chain;
	in = SoundIn.ar(0);
	chain = FFT({ LocalBuf(1024) }, in);
	chain = PV_MagFreeze(chain, LFNoise0.kr([LFNoise0.kr(2).exprange(2,10), LFNoise0.kr(2).exprange(2,10)]));
	Out.ar(out, Pan2.ar(IFFT(chain), 0, 0.3));// inverse FFT
}).add;

~freeze.free;

// buttons for synthdefs
k.elAt(\bt, \S, \1).action_({  |elem|
    if(elem.value > 0)
	{	~vox = ~freeze;
		~freeze.set(\out, 0);
	}{   ~freeze.free(3);}
});

)

// ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®


// Modular music interlude w buttons
(
// 01
k.elAt(\bt, \R, \3).action_({  |elem|
    if(elem.value > 0)
	{
	~mod1 = Pmono(\dcev,
	\ch,4,
	\ampCh,0,
	\trig, 1,
	\note, Pseq([30,30].mirror1,inf).asStream,
	\dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4,
	\atk, 0.001,
	\sus, 0.05,
	\rel, 0.4,
	\calibration, 0.0967, //0.0074, 0.10255,
	\midiTune, -24,
	\stepsPerOctave, 12,
	\amp, 0.5,
	\port, 0,
	\octave, 0);

	~mod1.set(\note, Pseq([30,30],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, 0.5, \port, 0, \octave, 0, \atk, 0.001,\sus, 0.05, \rel, 0.4).quant(1);
	}{   }
});

// 02
k.elAt(\bt, \R, \4).action_({  |elem|
    if(elem.value > 0)
	{
		~mod1.set(\note, Pseq([30,33,25],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pseq((30..99) *0.01, inf).asStream, \port, nil, \octave, 0).quant(1);
	} { }
});

// 03
k.elAt(\bt, \R, \5).action_({  |elem|
    if(elem.value > 0)
	{
~mod1.set(\note, Pseq([30,33,25],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pseq((30..99) *0.01, inf).asStream, \port, Pseq([0,1,3],inf).asStream, \octave, 0).quant(1);
	} { }
});

// 04
k.elAt(\bt, \R, \6).action_({  |elem|
    if(elem.value > 0)
	{
~mod1.set(\note, Pseq([30,33,45,25],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pseq((60..99) *0.01, inf).asStream, \port, Pseq([0,1,3],inf).asStream, \octave, 0).quant(1);
	} { }
});

// 05
k.elAt(\bt, \R, \7).action_({  |elem|
    if(elem.value > 0)
	{
~mod1.set(\note, Pseq([30,33,45,25],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pseq((70..99) *0.01, inf).asStream, \port, Pseq([0,1,3],inf).asStream, \octave, 0).quant(1);
(
~mod2 =	Pmono(\dcev,
	\ch,1,
	\ampCh,5,
	\trig, 1,
	\note, Pseq([30,30],inf),
	\dur, 0.1,
	\amp, 0.5,
	\atk, 0.001,
	\sus, 0.05,
	\rel, 0.4,
	\calibration, 0.09773, //0.0967
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, 0,
	\port, 0,
	);

~mod2.set(\note, Pseq([30,33,45,25],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pseq((70..99) *0.01, inf).asStream, \port, Pseq([0,1,3],inf).asStream, \octave, 0, \atk, 0.001,\sus, 0.05, \rel, 0.4).quant(1);
		)
	} { }
});

// 06
k.elAt(\bt, \R, \8).action_({  |elem|
    if(elem.value > 0)
	{
~mod1.set(\note, Pseq([30,33,45,25,47],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pseq((70..99) *0.01, inf).asStream, \port, Pseq([0,1,3],inf).asStream, \octave, 0).quant(1);
~mod2.set(\note, Pseq([30,33,45,25,47],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pexprand(0.7,0.7,inf).asStream, \amp, Pseq((70..99) *0.01, inf).asStream, \port, Pseq([0,1,3],inf).asStream, \octave, 0).quant(1);
	} { }
});

k.elAt(\bt, \R, \1).action_({  |elem|
    if(elem.value > 0)
	{
		// turn off mod1, mod2
		~mod1.set(\amp, Pseq((70..0) * 0.001,1).asStream, \dur, 0.001).quant(1);
		~mod2.set(\amp, Pseq((70..0) * 0.001,1).asStream, \dur, 0.001).quant(1);
} { }
});
)