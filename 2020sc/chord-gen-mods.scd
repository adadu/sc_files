//https://github.com/madskjeldgaard/sc-startup-file/blob/master/generative-chords.scd

s.quit

(
s.quit;
//set number of inputs and outputs
s.options.numInputBusChannels= 2;
s.options.numOutputBusChannels= 2;
//increase memory
s.options.memSize = 32786;
// for iD4
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2");
"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1,system:playback_2");
s.boot;
)

(
s.quit;
//set number of inputs and outputs
s.options.numInputBusChannels= 10;
s.options.numOutputBusChannels= 20;

//increase memory
s.options.memSize = 32786;
//s.options.hardwareBufferSize = 128;
// connect first to input channels with system
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2,system:capture_3,system:capture_4,system:capture_5,system:capture_6,system:capture_7,system:capture_8,system:capture_9,system:capture_10");
// connect all output channels with system
// rme fireface800 1-10 analog audio out, 10-11 spdif, 12-20 adat 1 out (0 is ch1, and linux jack won't allow enable/disable streams)
"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1,system:playback_2,system:playback_3,system:playback_4,system:playback_5,system:playback_6,system:playback_7,system:playback_8,system:playback_9,system:playback_10,system:playback_11,system:playback_12,system:playback_13,system:playback_14,system:playback_15,system:playback_16,system:playback_17,system:playback_18,system:playback_19,system:playback_20");

// setup for using Audient iD4 usb, would need alsa
// "SC_JACK_DEFAULT_INPUTS".setenv("iD4:capture_1,iD4:capture_2");
// "SC_JACK_DEFAULT_OUTPUTS".setenv(iD4:playback_1, iD4:playback_2");
s.boot;
)

//Pattern Guide 06b: Time Based Patterns




(
// Chord progressions
var triads = Array.new;

// Function that generates chord progressions
var x4chords = {|progLength=4|

    var maxChordNum=12;

    var numOfChords=maxChordNum.pow(progLength); // Set maximum to the biggest amount of possible combinations

	{{maxChordNum.rand}.dup(progLength)}.dup(numOfChords);

};

// Make the chord progressions into triads
/*
triads = x4chords.(4).do{|item, i|
    Array.fill(item.size, {|y| item[i][y]+2 });
};
*/

//triads[1..5].postln;
h=x4chords.(3);

~triads = h.do{|item, i| Array.fill(item.size, {|y| item[y]+2 }); };

)

// INVERTED TRIADS???
/*
~p1[0] = Pbind(
    \instrument, \pmPerc,
    \degree, Pstutter(2, Pseq(triads[1], inf)),
    \scale, Scale.minor,
    \octave, 4,
    \cutoff, 500,
    \dur, Pseq([0.25, Rest(0.5)],inf),
    \atk, 0,
    \rel, 0,
    \out, 0
).trace();
~p1.play(fadeTime:8);
*/

//attempt to add portamento fails freq = Lag.kr(freq, port)

(
SynthDef.new(\iter, {
	arg dur, freq=40, attack=0.005, release=0.3, t_gate=1, amp=1, swm;
	var sig = 0;
	var env = EnvGen.kr(Env.perc(attack, release), t_gate, timeScale: dur, doneAction: 2);
	10.do{
		var temp = VarSaw.ar(
			freq * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			{swm}!2,
			env*0.05 //each osc has own env
		);
		sig = sig + temp;
	};
	Out.ar(0, sig * amp);
}).add;
)

(
SynthDef.new(\iterMistake, {
	arg dur, freq=40, attack=0.005, release=0.3, t_gate=1, amp=1, swm, freqlag;
	var sig = 0;
	var env = EnvGen.kr(Env.perc(attack, release), t_gate, timeScale: dur, doneAction: 2);
	freq = freq*Lag.kr(freq, freqlag);
	10.do{
		var temp = VarSaw.ar(
			freq * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			{swm}!2,
			env*0.05 //each osc has own env
		);
		sig = sig + temp;

		//sig = sig * env*0.5; //allows more separation between voices
	};
	//sig = sig * env;
	Out.ar(0, sig * amp);
}).add;
)

//saved state at 2/29 2:29

(
Ndef(\polySaw, Pbind(\instrument, \iter,
	//\dur, Prand([1,1,2,1,4] * 0.08125, inf),
	\type, Pseq([\note,\note,\rest,\note,\rest],inf),//Pexprand(0.5, 0.2, inf),
	\degree, Pshuf([~triads[2]+~triads[4]+~triads[10.rand],
		~triads[2]+~triads[3]+~triads[10.rand],
		~triads[3]+~triads[5]+~triads[10.rand],
		~triads[7]+~triads[9]+~triads[10.rand]],inf),
	\attack, Pkey(\dur) * 4,//0.01,// Prand((1..10) * 0.001,inf),
	\release,Pkey(\dur) * 1.5,//Prand((10..20) * 0.1,inf),
	\amp, 0.8,
	\scale, Scale.minor, //Scale.diminished, Scale.major],inf), //Scale.dorian, Scale.mixolydian, Scale.locrian, Scale.lydianMinor,
	\tuning, Tuning.pythagorean,
	\dur, Pseq([Pgeom(0.07, 1.01, 75)],inf) * 10,//Pseq([1,2,3,4,1,1,2,1] * 0.5, inf), //Pgeom(0.07, 1.01, inf),
	\swm, Phprand(0.49, 1.0, inf), //Pexpodec(50,inf) + 0.01,
	\octave,Pseq((2..4),inf)

));
)
Ndef(\polySaw).play;
Ndef(\polySaw).fadeTime =4;
Ndef(\polySaw).clear(2);


(
Ndef(\polySaw, Pbind(\instrument, \iter,
	//\dur, Prand([1,1,2,1,4] * 0.08125, inf),
	\type, \note, //Pseq([\note,\note,\rest,\note,\rest],inf),//Pexprand(0.5, 0.2, inf),
	\degree, Pseq([~triads[2],~triads[4],~triads[3],~triads[5],~triads[7],~triads[9],~triads[12]],inf).trace,
	//\detune, Pkey(\degree) * Pseq((1423..1466),inf) *2,
	\attack, Pkey(\dur) * Pseq((10..40),inf) * Pkey(\dur)* 0.01,
	\release,Pkey(\dur) * Pseq((10..20),inf) * Pkey(\dur)* 0.3,
	\amp, 0.8,
	\scale, Scale.mixolydian, //Scale.diminished, Scale.major],inf), //Scale.dorian, Scale.mixolydian, Scale.locrian, Scale.lydianMinor,
	\tuning, Tuning.pythagorean,
	\dur, Pseq([Pgeom(0.07, 1.01, 30)],inf) * 1,
	//\dur, Pseq([1,2,3,4,1,1,2,1] * 0.1, inf), //Pgeom(0.07, 1.01, inf),
	\swm, Pexpodec(20,inf) + 0.01,//Phprand(0.79, 0.95, inf), //
	\octave,Pseq((4..4),inf),
	\strum,0.01,
	//\numHarm, 6,
	//\harmonics, 7

));
)

(
Ndef(\polySaw, Pbind(\instrument, \iter,
	//\dur, Prand([1,1,2,1,4] * 0.08125, inf),
	\type, Pseq([\note,\note,\rest,\note,\rest],inf),//Pexprand(0.5, 0.2, inf),
	\degree, Pshuf([~triads[2]+~triads[4]+~triads[10.rand],
		~triads[2]+~triads[3]+~triads[10.rand],
		~triads[3]+~triads[5]+~triads[10.rand],
		~triads[7]+~triads[9]+~triads[10.rand]],inf),
	\attack, Pkey(\dur) * 0.01,// Prand((1..10) * 0.001,inf),
	\release,Pkey(\dur) * Prand((10..20) * 1.4,inf),
	\amp, 0.8,
	\scale, Scale.minor, //Scale.diminished, Scale.major],inf), //Scale.dorian, Scale.mixolydian, Scale.locrian, Scale.lydianMinor,
	\tuning, Tuning.pythagorean,
	\dur, Pseq([Pgeom(0.07, 1.01, 75) * Pgeom(0.07, 1.01, 1) * Pwhite(1,10)], inf),
	\swm, Phprand(0.49, 1.0, inf), //Pexpodec(50,inf) + 0.01,
	\octave,Pseq((2..4),inf),
	\strum,Pseq((5..25).mirror1*0.01,inf) * 5
));
)

//fast melodic ish
(
Ndef(\polySaw, Pbind(\instrument, \iter,
	\dur, Pseq([1,1,2,1,1,4] * 0.08125, inf),
	//\type, Pseq([\note,\note,\rest],inf),//Pexprand(0.5, 0.2, inf),
	\degree, Pseq([~triads[2]+~triads[4]+~triads[10.rand],
		~triads[2]+~triads[3]+~triads[10.rand],
		~triads[3]+~triads[5]+~triads[10.rand],
		~triads[7]+~triads[9]+~triads[10.rand]],inf),
	\detune, Pkey(\degree) * Pseq((1423..1466),inf),
	\attack, Pkey(\dur) * 0.001,//0.01,// Prand((1..10) * 0.001,inf),
	\release,Pkey(\dur) * Pseq((10..110).mirror * 0.5,inf) * 1,//,
	\amp, 0.9,
	\scale, Scale.mixolydian, //Scale.diminished, Scale.major],inf), //Scale.dorian, Scale.mixolydian, Scale.locrian, Scale.lydianMinor,
	\tuning, Tuning.pythagorean,//pythagorean,
	\dur, Pseq([ Pgeom(0.07, 1.01, 50), Pgeom(0.07, 1.01, 60), Pgeom(0.07, 1.01, 70) ],inf) * 1,
	//\dur, Pseq([1,2,3,4,1,1,2,1] * 0.1, inf), //Pgeom(0.07, 1.01, inf),
	\swm, Pseq((1..99).mirror * 0.01,inf),//0.99,// Phprand(0.89, 1.0, inf), //
	//\ctranspose, Pseq([1,1,1,5].mirror,inf),
	\octave,Pseq((2..3).mirror2,inf), //over 10 seems to go into dc offset zone
	\strum,Pseq((5..25).mirror1*0.01,inf) * 1,
	\numHarm, Pseq((3..7).mirror,inf),
));
)

// experiments

(
Ndef(\polySaw, Pbind(\instrument, \iter,
	//\dur, Prand([1,1,2,1,4] * 0.08125, inf),
	\type, Pseq([\note,\note,\rest],inf),//Pexprand(0.5, 0.2, inf),

	\degree, Pshuf(
		[~triads[10.rand]+~triads[10.rand]+~triads[10.rand]+~triads[10.rand],
		~triads[10.rand]+~triads[10.rand]+~triads[10.rand]+~triads[10.rand],
		~triads[10.rand]+~triads[10.rand]+~triads[10.rand]+~triads[10.rand],
		~triads[10.rand]+~triads[10.rand]+~triads[10.rand]+~triads[10.rand]],inf),
	\detune, Pkey(\degree)/*~triads[10.rand]+~triads[10.rand]+~triads[10.rand]+~triads[10.rand]*/ * Pseq((1433..1463),inf).stutter(10), //multiply hard super fm nearing additive
	\attack, Pkey(\dur) * Pwhite(0.99,8,inf),//0.01,// Prand((1..10) * 0.001,inf),
	\release,Pkey(\dur) * 7,//Pseq([1.3,0.2],inf) *4,//Prand((10..20) * 0.1,inf),
	\amp, 0.7,
	\scale, Scale.minor, //Scale.diminished, //, Scale.major],inf), //Scale.dorian, Scale.mixolydian, Scale.locrian, Scale.lydianMinor,
	\tuning, Tuning.pythagorean, //Tuning.mean6,
	//\dur, Pseq([3,0.3],inf) * 0.03,
	\dur, Pseq([Pgeom(0.07, 1.01, 60)].mirror,inf) * Pexprand(0.01,0.5,inf) * 4,
	//\dur, Pexpodec(100,inf) + 0.1,
	//\dur, Pseq([1,2,3,4,1,1,2,1] * 0.5, inf),
	\swm, Pwhite(0.11, 0.99, inf), //0.93, //Pexpodec(100,inf) + 0.01,//Phprand(0.39, 1.0, inf),
	\octave,-10,//Pseq((-5..-5),inf),
	//\strum,Pseq((1..10) * 0.1, inf), //separate chords
	\numHarm, 2,//add harmonics or choose?
	\harmonics,1,
	//\legato,0.4
));
)

//clean up randomness
(
Ndef(\polySaw, Pbind(\instrument, \iter,
	//\dur, Pshuf([1,1,2,1] * 0.08125, inf),
	//\type, Pseq([\note,\note,\rest],inf),//Pexprand(0.5, 0.2, inf),

	\degree, Prand(
		[~triads[1]+~triads[2]+~triads[3]+~triads[4],
		~triads[2]+~triads[3]+~triads[4]+~triads[5],
		~triads[3]+~triads[4]+~triads[5]+~triads[6],
		~triads[4]+~triads[5]+~triads[6]+~triads[7]],inf),
	\detune, Pkey(\degree)/*~triads[10.rand]+~triads[10.rand]+~triads[10.rand]+~triads[10.rand]*/ * Pseq((200..300).mirror2,inf),// Pseq((1433..1449),inf) * 1.25, //multiply hard super fm nearing additive
	\attack, Pkey(\dur) * 0.01,//0.01,// Prand((1..10) * 0.001,inf),
	\release,Pkey(\dur) * 0.9,//Pseq([1.3,0.2],inf) *4,//Prand((10..20) * 0.1,inf),
	\amp, 0.2,
	\scale, Scale.minor, //Scale.diminished, //Scale.minor, //, Scale.major],inf), //Scale.dorian, Scale.mixolydian, Scale.locrian, Scale.lydianMinor,
	\tuning, Tuning.pythagorean, //Tuning.mean6,//pythagorean,
	\dur, Pexprand(0.08125, 0.90, inf),
	//\dur, Pseq([3,0.3],inf) * 0.1,
	//\dur, Pseq([Pgeom(0.07, 1.01, 60)],inf) * 1,
	//\dur, Pexpodec(100,inf) + 0.1,
	//\dur, Pseq([1,2,3,4,1,1,2,1] * 0.5, inf),
	\swm, Pexpodec(10,inf) + 0.01,//Phprand(0.39, 1.0, inf),
	\octave,0,//Pseq((-5..-5),inf),
	//\strum,Pseq((1..10) *0.1, inf), //separate chords
	\numHarm, 5,//add harmonics or choose?
	//\harmonics,5
	//\legato,2
));
)

//Mar 1 furhuring LOW dark drone

//attempting Pdefn mod to mod pitch with envelop ~v1env
// might looks at proxyspace or how look again at how ndef could achieve
(
Ndef(\polySaw2, Pbind(\instrument, \iter,
	//\dur, Prand([1,1,2,1,4] * 0.08125, inf),
	//\type, Pseq([\note,\note,\rest],inf),//Pexprand(0.5, 0.2, inf),

	\degree, Pdefn(\v1degree,Pseq(
		[~triads[1]+~triads[2]+~triads[3]+~triads[4],
		~triads[2]+~triads[3]+~triads[4]+~triads[5],
		~triads[3]+~triads[4]+~triads[5]+~triads[6],
			~triads[4]+~triads[5]+~triads[6]+~triads[7]],inf)),
	\detune, (~triads[2]++~triads[1]+~triads[0]++~triads[3] *30).postln,// Pkey(\degree).next(3)/*~triads[10.rand]+~triads[10.rand]+~triads[10.rand]+~triads[10.rand]*/// Pseq((1433..1449),inf) * 1.25, //multiply hard super fm nearing additive
	\attack, Pkey(\dur) * 0.01,//0.01,// Prand((1..10) * 0.001,inf),
	\release,Pkey(\dur) * 1.1,//Pseq([1.3,0.2],inf) *4,//Prand((10..20) * 0.1,inf),
	\amp, 0.7,
	//\scale, Scale.major, //Scale.diminished, //Scale.minor, //, Scale.major],inf), //Scale.dorian, Scale.mixolydian, Scale.locrian, Scale.lydianMinor,
	//\tuning, Tuning.pythagorean, //Tuning.mean6,//pythagorean,
	\dur, Pdefn(\v1dur,10),
	//\dur, Pseq([3,0.3],inf) * 0.1,
	//\dur, Pseq([Pgeom(0.07, 1.01, 60)],inf) * 1,
	//\dur, Pexpodec(100,inf) + 0.1,
	//\dur, Pseq([1,2,3,4,1,1,2,1] * 0.5, inf),
	\swm, 0.2, //Pexpodec(100,inf) + 0.01,//Phprand(0.39, 1.0, inf),
	\octave,0,//Pseq((-5..-5),inf),
	//\strum,Pseq((1..10) *0.01, inf), //separate chords
	//\numHarm, 1,//add harmonics or choose?
	//\harmonics,5
	//\legato,2
	\ctranspose, Prand((-3..3),inf),
));
)
Ndef(\polySaw2).play;


(
Pdefn(\v1degree, Pseq(
		[~triads[1]+~triads[2]+~triads[3]+~triads[4],
		~triads[2]+~triads[3]+~triads[4]+~triads[5],
		~triads[3]+~triads[4]+~triads[5]+~triads[6],
		~triads[4]+~triads[5]+~triads[6]+~triads[7]],inf) + ~v1env);

)
Pdefn(\v1dur,0.08);

~v1env = Pseg(levels: [1.0,0.4,0.2,0.0], durs: Array.fill(10,Pwhite(1,10)), curves: \exp, repeats:inf);
~v1env.play;
~v1env.clear;


~triads[1].postln;
~triads[2].postln;
~triads[3].postln;
~triads[4].postln;

~triads[1..7].postln;

~triads[1]++~triads[2]++~triads[3].postln;

(
Ndef(\polySaw, Pbind(\instrument, \iter,
	//\dur, Prand([1,1,2,1,4] * 0.08125, inf),
	\type, Pseq([\note,\note,\rest],inf),//Pexprand(0.5, 0.2, inf),
	\degree, Pseq(
		[ ~triads[1]+~triads[2]+~triads[3]+~triads[4],
		~triads[2]+~triads[3]+~triads[4]+~triads[5],
		~triads[3]+~triads[4]+~triads[5]+~triads[6],
		~triads[4]+~triads[5]+~triads[6]+~triads[7] ],inf).trace,
	\detune, Pkey(\degree) *1300,// Pkey(\degree).next(3)/*~triads[10.rand]+~triads[10.rand]+~triads[10.rand]+~triads[10.rand]*/// Pseq((1433..1449),inf) * 1.25, //multiply hard super fm nearing additive
	\attack, Pkey(\dur) * 0.01,//0.01,// Prand((1..10) * 0.001,inf),
	\release,Pkey(\dur) * 3.9,//Pseq([1.3,0.2],inf) *4,//Prand((10..20) * 0.1,inf),
	\amp, 0.99,
	\scale, Scale.major, //Scale.diminished, //Scale.minor, //, Scale.major],inf), //Scale.dorian, Scale.mixolydian, Scale.locrian, Scale.lydianMinor,
	\tuning, Tuning.pythagorean, //Tuning.mean6,//pythagorean,
	\dur, 2,
	\dur, Pseq([3,0.3],inf) * 0.1,
	//\dur, Pseq([Pgeom(0.07, 1.01, 60)],inf) * 1,
	//\dur, Pexpodec(100,inf) + 0.1,
	\dur, Pseq([1,2,3,4,1,1,2,1] * 0.1, inf),
	\swm, 0.89, //Pexpodec(100,inf) + 0.01,//Phprand(0.39, 1.0, inf),
	\octave,1,//Pseq((-5..-5),inf),
	//\strum, 0.2, //Pseq((1..10) *0.01, inf), //separate chords
	//\numHarm, 1,//add harmonics or choose?
	//\harmonics,5
	//\legato,2
));
)


// look at List and Array help files

Ndef(\polySaw).set(\dur,Pseq([Pgeom(0.07, 1.01, 80)],inf).asStream * 2).clear;
Ndef(\polySaw).set(Pseq([3,0.3],inf).asStream * 0.5).clear;


Ndef(\polySaw).play;
Ndef(\polySaw).fadeTime =5;
Ndef(\polySaw).clear(2);

Scale.directory;
Tuning.directory;

// recording function
s.record(duration: 120);
s.stopRecording;
//open location of where recordings are stored
Platform.recordingsDir.openOS;

//kill stuck synths
thisProcess.platform.killAll("scsynth supernova");

// Simple test of Mads default SC synth
(
Ndef(\mads, Pbind(\dur, Pseq([1,1,2,1,1] * 1.08125, inf), \degree,
	Pseq([~triads[2]+~triads[4],
		~triads[2]+~triads[2],
		~triads[3]+~triads[5],
		~triads[7]+~triads[11]] *0.1,inf), \pan,Pshuf((-99..99)*0.01,inf), \release,Pseq((1..20) * 0.3,inf), \cutoff, 250,
	\rq, 1,/*Prand((10..30)*0.01,inf),*/ \out,0));
)
Ndef(\mads).play;
Ndef(\mads).clear;