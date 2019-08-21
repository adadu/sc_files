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
    fft = FFT(LocalBuf(1024), in);  // for sampling rates 44100 and 48000
    //fft = FFT(LocalBuf(2048), in);  // for sampling rates 88200 and 96000

    array = MFCC.kr(fft);

    Out.kr(0, array); // control bus out
    Out.ar(0, Pan2.ar(in)); // audio bus out
}.play
)

c = Bus(\control, 0, 13);

// Continuous graphical display of MFCC values; free routine before closing window
(
var ms;

w = Window.new("13 MFCC coefficients", Rect(200, 400, 300, 300));
ms = MultiSliderView.new(w, Rect(10, 10, 260, 280));
ms.value_(Array.fill(13, 0.0));
ms.valueThumbSize_(20.0);
ms.indexThumbSize_(20.0);
ms.gap_(0);
w.front;

r = {
    inf.do {
		c.getn(13, { |val| { ms.value_(val * 0.9) }.defer });
        0.04.wait; // 25 frames per second
    }
}.fork
)

// SEND to Wekinator
//////////////////////////SIMPLE SENDER//////////////////////////
/////
///// Use this block to send 13 MFCCs as Wekinator inputs
///// Run Wekinator with 13 inputs, select All dynamic time warping
///// Select how many words to detect, and 1 for silence
/////
/////////////////////////////////////////////////////////////////
(
var sender;
//set up the sender
sender = NetAddr.new("127.0.0.1", 6448);


Routine.run({
	inf.do{
		t = c.getnSynchronous(13);
		sender.sendMsg("/wek/inputs", *t); //send bus value
		(1/61).wait; //0.016393442622951
	};
});
)


// tidy up
(
r.stop;
/*b.free;*/
c.free;
x.free;
w.close;
t.stop;
)

// quit
s.quit;

// aug7 add - plot 13 coefficient values, post them, +1 to match wekinators inputs
c.getn(13, { |val| { val.plot; val.do({ arg item, i; [i+1, item].postln })}.defer });

//monitor all osc
OSCFunc.trace(true);
OSCFunc.trace(false);

// check cpu usage
s.avgCPU;


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