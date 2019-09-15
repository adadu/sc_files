s.quit

// Setup audio io, boot & add proxyspace
(
// RME Fireface800
s.options.device="Fireface 800 (3EC)";
// Fireface w/ 8 ANALOG INS activated
s.options.numInputBusChannels = 8;
s.options.outputStreamsEnabled = "11111111";
// Fireface w/ ADAT OUTS activated
// 0-9=ANALOG 1-10
// 10-11=SPDIF 1-2(11-12)
// 12-19=ADAT OUT 1-8(13-20)
s.options.numOutputBusChannels = 19;
// disable SPDIF outputs
s.options.outputStreamsEnabled = "11111111110011111111";
s.boot;

//PROXYSPACE
//start proxyspace
p=ProxySpace.push(s);
/*//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 2;*/

Task({
	3.wait;
	// print audio io details
	"Ins: ".post;
	s.options.numInputBusChannels.postln;
	"Outs: ".post;
	s.options.numOutputBusChannels.postln;
}).start;
)

//("setup.scd").loadRelative;


// OSC Communication
(
~mfcc = {
    var in, fft, array;
    //in = PlayBuf.ar(1, d, BufRateScale.kr(d), 1, 0, 1);
	in = SoundIn.ar(0);
    fft = FFT(LocalBuf(1024), in);
    array = MFCC.kr(fft);
    Out.kr(0, array); // control bus out
    Out.ar(0, Pan2.ar(in)); // audio bus out
};

~mfccBus = Bus(\control, 0, 13); // create control bus
)

(
var ms, sender;
// Continuous graphical display of MFCC values; free routine before closing window
w = Window.new("13 MFCC coefficients", Rect(800, 500, 300, 300));
ms = MultiSliderView.new(w, Rect(10, 10, 260, 280));
ms.value_(Array.fill(13, 0.0));
ms.valueThumbSize_(20.0);
ms.indexThumbSize_(20.0);
ms.gap_(0);
w.front;
//set up the sender
sender = NetAddr.new("127.0.0.1", 6448);
// function to run display and send values to wekinator
~mfccDisplay = {
    inf.do {
		~mfccBus.getn(13, { |val| { ms.value_(val * 0.9) }.defer });
		~mfccOsc = ~mfccBus.getnSynchronous(13);
		sender.sendMsg("/wek/inputs", *~mfccOsc); //send bus value
        0.04.wait; //25 frames per second 0.04
    }
}.fork
)

(
var synth;

// modular synthdef
synth = SynthDef(\dcev, { | note, octave = 0, spo = 12, t_trig, atk=0, sus=0, rel=3, ch = nil, port = 0, calibration = 0.1, midiTune = 0, amp = 1,
	ampCh = nil, att = 0.001, dur = 1 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	note = note;
	note = note + (octave * spo) + midiTune;
	note = (note / spo) * calibration;
	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
	Out.ar(ampCh, K2A.ar(Lag.kr(envGen)));
}).add;

n.free; //free the old reciever if it already exists
n = NetAddr("127.0.0.1", 57120);    // create the NetAddr, language port 57120
//a.free; //if there is an old responder ... then free it first
/*a = */OSCdef(\oM1,
	{ arg msg, time; [time, msg].postln;

		~mod1 =	Pmono(\dcev,
			\ch,16,
			\ampCh,12, // rme fireface 800 adat channels
			\trig, 1,
			//\note, Pseq((23..37), inf),
			\degree, Pseq([1],1),
			\scale, Scale.whole,
			\tuning, \harmonic,
			\dur, 0.2,
			\amp, 0.45,
			\atk, 0.001,
			\sus, 0.9,
			\rel, 0.5,
			\calibration, 0.1,
			\midiTune, -12.75,
			\spo, 12,
			\octave, 1,
		);
	},
	'/output_1');

/*b = */OSCdef(\oM2,
	{ arg msg, time; [time, msg].postln;
		~mod1 =	Pmono(\dcev,
			\ch,16,
			\ampCh,12, // rme fireface 800 adat channels
			\trig, 1,
			//\note, Pseq((23..37), 1),
			\degree,Pseq([3],1),
			\scale, Scale.whole,
			\tuning, \harmonic,
			\dur, 0.1,
			\amp, 0.45,
			\atk, 0.001,
			\sus, 0.9,
			\rel, 0.1,
			\octave, 1,
		);
	},
	'/output_2');

/*d = */OSCdef(\oM3,
	{ arg msg, time; [time, msg].postln;
		~mod1 =	Pmono(\dcev,
			\ch,16,
			\ampCh,12, // rme fireface 800 adat channels
			\trig, 1,
			//\note, Pseq((23..37), inf),
			\degree, Pseq([5],1),
			\scale, Scale.whole,
			\tuning, \harmonic,
			\dur, 0.2,
			\amp, 0.45,
			\atk, 0.001,
			\sus, 0.1,
			\rel, 0.1,
			\octave, 1,
		);
	},
	'/output_3');

/*e = */OSCdef(\oM4,
	{ arg msg, time; [time, msg].postln;
		~mod1 =	Pmono(\dcev,
			\ch,16,
			\ampCh,12, // rme fireface 800 adat channels
			\trig, 1,
			//\note, Pseq((23..37), inf),
			\degree, Pseq([7],1),
			\scale, Scale.whole,
			\tuning, \harmonic,
			\dur, 0.2,
			\amp, 0.45,
			\atk, 0.001,
			\sus, 0.1,
			\rel, 0.1,
			\octave, 1,
		);
	},
	'/output_4');

/*f = */OSCdef(\oM5,
	{ arg msg, time; [time, msg].postln;
		~mod1 =	Pmono(\dcev,
			\ch,16,
			\ampCh,12, // rme fireface 800 adat channels
			\trig, 1,
			//\note, Pseq((23..37), inf),
			\degree, Pseq([9],5),
			\scale, Scale.whole,
			\tuning, \harmonic,
			\dur, 0.2,
			\amp, 0.95,
			\atk, 0.001,
			\sus, 0.1,
			\rel, 0.1,
			\octave, 1,
		);
	},
	'/output_5');

/*v = OSCdef(
	\oMod1,
	func: {arg ...args; args.postln},
	path: '/output_1') */
)


// tidy up
(
r.stop;
c.free;
x.free;
w.close;
t.stop;
n.free;
)

//stop synths
(
a.free;
b.free;
d.free;
e.free;
f.free;
~mod1.free;
)

// quit
(
p.free;
s.quit;
)

////// UTILITIES ////////

//dump all nodes to post window
s.queryAllNodes(queryControls);


// aug7 add - plot 13 coefficient values, post them, +1 to match wekinators inputs
c.getn(13, { |val| { val.plot; val.do({ arg item, i; [i+1, item].postln })}.defer });

//monitor all osc
OSCFunc.trace(true);
OSCFunc.trace(false);

// check cpu usage
s.avgCPU;



(
// 2 osc slow morphing pitch and env
~mod1 = Pmono(\dcev,
	\ch,16,
	\ampCh,12, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Prand((0..7),inf),
	\scale, Scale.whole,
	\tuning, \harmonic,
	\dur, /*Pseq([0.3, Rest(0.9)],inf)*/ Pexprand(5.33, 9.79,inf) * 0.1,
	\amp, Pseq((15..45).mirror2, inf) * 0.01,
	\atk, /*0.001,*/ Prand([1,5,9],inf) * 0.1,
	\sus, /*0.05,*/  Prand([1,10,100],inf) *0.01,
	\rel, /*0.5,*/ Prand([1,5,9],inf) *0.1,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq((2..2),inf),
	\port, Pkey(\dur) *2,
);

~mod2 = Pmono(\dcev,
	\ch,17,\ampCh,13, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Prand((0..7),inf),
	\scale, Scale.whole,
	\tuning, \harmonic,
	\dur, /*Pseq([0.3, Rest(0.9)],inf)*/ Pexprand(5.33, 9.79,inf) * 0.1,
	\amp, Pseq((15..65).mirror2, inf) * 0.01,
	\atk, /*0.001,*/ Prand([1,5,9],inf) * 0.1,
	\sus, /*0.05,*/  Prand([1,10,100],inf) *0.01,
	\rel, /*0.5,*/ Prand([1,5,9],inf) *0.1,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq((2..2),inf),
	\port, Pkey(\dur) *2,
);

~mod3 = Pmono(\dcev,
	\ch,18,\ampCh,14, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Prand((0..7),inf),
	\scale, Scale.whole,
	\tuning, \harmonic,
	\dur, /*Pseq([0.3, Rest(0.9)],inf)*/ Pexprand(5.33, 9.79,inf) * 0.1,
	\amp, Pseq((15..65).mirror2, inf) * 0.01,
	\atk, /*0.001,*/ Prand([1,5,9],inf) * 0.1,
	\sus, /*0.05,*/  Prand([1,10,100],inf) *0.01,
	\rel, /*0.5,*/ Prand([1,5,9],inf) *0.1,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq((2..4),inf),
	\port, Pkey(\dur) *2,
);
)


// UTIL: view scale, tuning and degrees
Scale.directory;
Tuning.directory;
Scale.whole.degrees;


// free 3 modular voices
(
~mod1.free;
~mod2.free;
~mod3.free;
)

s.freeAll



///////////////////////SIMPLE RECIEVER///////////////////
//
// Use this block to get synth control from Wekinator
// Place cursor in ( ) below and use cmd + return to execute the synth
// make sure the server is booted before running
// use cmd + . to stop the synth
//
// Run wekinator up with five continuous outputs and sending to port 57120
//
////////////////////////////////////////////////////////////////

(

var synth, responder;

synth = SynthDef("WekiSynth",

	{

	|carFreq = 440, carAmp = 0.2, modFreq = 20, modAmp = 50, panFreq = 0.5|

	var sig, mod, pan;

	modAmp = min(carFreq * 0.95, modAmp);
	mod = Saw.kr(modFreq, modAmp);
	sig = SinOsc.ar(carFreq + mod,0,carAmp);
	pan = SinOsc.kr(panFreq, 0,0.75);
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);

	}

).play;

~receiver.free; //free the old reciever if it already exists
~receiver = NetAddr.new("127.0.0.1", 57120);    // create the NetAddr ... only the language port 57120 actually works
~responder.free; //if there is an old responder ... then free it first
~responder = OSCFunc(
	{ | msg |

		var specs = Array.newClear(5);

		msg.postln;

		specs[0] =  ControlSpec(100, 1000,\exp);
		specs[1] =  ControlSpec(0, 0.5,\lin);
		specs[2] = ControlSpec(0.2, 200,\lin);
		specs[3] = ControlSpec(20, 1000,\lin);
		specs[4] = ControlSpec(0.1, 20,\exp);

		synth.set(\carFreq, specs[0].map(msg[1]));
		synth.set(\carAmp, specs[1].map(msg[2]));
		synth.set(\modFreq, specs[2].map(msg[3]));
		synth.set(\modAmp, specs[3].map(msg[4]));
		synth.set(\panFreq, specs[4].map(msg[5]));

	},
'/wek/outputs');

)

s.quit;