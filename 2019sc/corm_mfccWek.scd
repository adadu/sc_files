// RME Fireface800 audio io
(
s.options.device="Fireface 800 (3EC)";
s.options.numInputBusChannels = 8;
s.options.numOutputBusChannels = 8;
s.boot
)

// OSC Communication
(
x = {
    var in, fft, array;
    //in = PlayBuf.ar(1, d, BufRateScale.kr(d), 1, 0, 1);
	in = SoundIn.ar(6);
    fft = FFT(LocalBuf(1024), in);
    array = MFCC.kr(fft);
    Out.kr(0, array); // control bus out
    Out.ar(0, Pan2.ar(in)); // audio bus out
}.play
)

c = Bus(\control, 0, 13); // create control bus

(
var ms, sender;
// Continuous graphical display of MFCC values; free routine before closing window
w = Window.new("13 MFCC coefficients", Rect(200, 400, 300, 300));
ms = MultiSliderView.new(w, Rect(10, 10, 260, 280));
ms.value_(Array.fill(13, 0.0));
ms.valueThumbSize_(20.0);
ms.indexThumbSize_(20.0);
ms.gap_(0);
w.front;
//set up the sender
sender = NetAddr.new("127.0.0.1", 6448);
// function to run display and send values to wekinator
r = {
    inf.do {
		c.getn(13, { |val| { ms.value_(val * 0.9) }.defer });
		t = c.getnSynchronous(13);
		sender.sendMsg("/wek/inputs", *t); //send bus value
        0.01.wait; // 50 milliseconds   //25 frames per second 0.04
    }
}.fork
)

// tidy up
(
r.stop;
c.free;
x.free;
w.close;
t.stop;
)

// quit
s.quit;


////// UTILITIES ////////
// aug7 add - plot 13 coefficient values, post them, +1 to match wekinators inputs
c.getn(13, { |val| { val.plot; val.do({ arg item, i; [i+1, item].postln })}.defer });

//monitor all osc
OSCFunc.trace(true);
OSCFunc.trace(false);

// check cpu usage
s.avgCPU;


(
var synth, responder;
// modular synthdef
synth = SynthDef(\dcenv);
// modular synthdef initial values
~mod1 = Pmono(\dcev,
	\ch,13,\ampCh,12, // rme fireface 800 adat channels
	\trig, 1,
	\degree, 23,
	\scale, Scale.major(\sruti),
	\dur, 0.1,
	\amp, 0.99,//Pexprand(0.68, 0.95, inf),
	\atk, 0.001, //Pseq([1,3],inf)*0.1,
	\sus, 0.05,  //Pseq([1,3,5],inf)*0.05,
	\rel, 0.5, //Pseq([1,4,5],inf)*0.01,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, -6,
	);

~mod2 = Pmono(\dcev,
	\ch,15,\ampCh,14,
	\trig, 1,
	\degree, 23,
	\scale, Scale.major(\sruti),
	\dur, 0.1,
	\amp, 0.99,//Pexprand(0.68, 0.95, inf),
	\atk, 0.001, //Pseq([1,3],inf)*0.1,
	\sus, 0.05,  //Pseq([1,3,5],inf)*0.05,
	\rel, 0.5, //Pseq([1,4,5],inf)*0.01,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, -6,
	);

/*~mod1.play;
~mod2.play;*/

~receiver.free; //free the old reciever if it already exists
~receiver = NetAddr.new("127.0.0.1", 57120);    // create the NetAddr ... only the language port 57120 actually works
~responder.free; //if there is an old responder ... then free it first
~responder = OSCFunc(
	{ | msg |
		var specs = Array.newClear(5);
		msg.postln;
	}, '/wek/outputs');
)



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