s.quit;

// 4ch stripped down
(
s.quit;

//set number of inputs and outputs
s.options.numInputBusChannels= 10;
s.options.numOutputBusChannels= 10;

// connect first to input channels with system
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2,system:capture_3,system:capture_4,system:capture_5,system:capture_6,system:capture_7,system:capture_8,system:capture_9,system:capture_10");
// connect all output channels with system
// rme fireface800 1-10 analog audio out, 10-11 spdif, 12-20 adat 1 out (0 is ch1, and linux jack won't allow enable/disable streams)
"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1,system:playback_2,system:playback_3,system:playback_4,system:playback_5,system:playback_6,system:playback_7,system:playback_8,system:playback_9,system:playback_10");

// setup for using Audient iD4 usb, would need alsa
// "SC_JACK_DEFAULT_INPUTS".setenv("iD4:capture_1,iD4:capture_2");
// "SC_JACK_DEFAULT_OUTPUTS".setenv(iD4:playback_1, iD4:playback_2");

//increase memory
s.options.memSize = 4 * 8192;

s.boot;
)


(
~checkMyServerOutputs = { arg server, decoder;
    server.serverRunning.if({
        (decoder.numOutputs > server.options.numOutputBusChannels).if({
            "Number of Server output bus channels is less than number required by Decoder!".warn;
            "Server Outputs: %\n".postf(server.options.numOutputBusChannels);
            "Decoder Outputs: %\n\n".postf(decoder.numOutputs);
            "Update number of Server outputs as illustrated here: ".post;
            "http://doc.sccode.org/Classes/ServerOptions.html#examples".postln;
        }, {
            "Server has an adequate number of output bus channels for use with this Decoder!".postln;
        })
    })
}
)

// choose decoder
// Quad
~decoder = FoaDecoderMatrix.newQuad(k: 'dual');
// periphonic (3D), 8ch
//~decoder = FoaDecoderMatrix.newPeri(k: 'dual')

// inspect
~decoder.kind
~checkMyServerOutputs.value(s, ~decoder)


(
var decoder;

// define our deocder
decoder = ~decoder;

// allocate four channels for routing
a = Bus.audio(s, 4);

// Encoding Synth
SynthDef(\foaEncode3, {arg outBus, duration = 0.05, theta, phi;
    var src, foa, env;

    // our mono source
    src = PinkNoise.ar(-6.dbamp);

    // amplitude scaling envelope
    env = EnvGen.kr(
            Env([0, 1, 0], [0.5, 0.5], \sin),
            timeScale: duration,
            doneAction: 2);

    // Encode into our foa signal
    foa = FoaPanB.ar(src, theta, phi, env);

    Out.ar(outBus, foa);
}).add;

// Decoding Synth
SynthDef(\foaDecode, {arg inBus;
    var foa, out;

    // read in 4 channels (B-format) from inBus
    foa = In.ar(inBus, 4);

    // decode to stereo
    out = FoaDecode.ar(foa, decoder);

     Out.ar(0, out);
}).add;

)


// start the decoder, reading bus 'a' at the \tail
b = Synth(\foaDecode, [\inBus, a], 1, \addToTail);

// use a Routine to start many encoded signals at random angles
(
Routine.run({
    200.do({
        Synth(\foaEncode3, [\outBus, a, \theta, pi.rand2, \phi, 1]);
        0.1.wait;
    })
});
)


b.free; // free the decoder
a.free; // free the audio bus


// free the synth
a.free;


// define ~renderDecode
(
~renderDecode = { arg in, decoder;
    var kind;
    var fl, bl, br, fr;
    var fc, lo;
    var sl, sr;
    var flu, blu, bru, fru;
    var fld, bld, brd, frd;
    var slu, sru, sld, srd;


    kind = decoder.kind;

    case
        { decoder.numChannels == 2 }
            {
                // decode to stereo (or binaural)
                FoaDecode.ar(in, decoder)
            }
        { kind == 'quad' }
            {
                // decode (to quad)
                #fl, bl, br, fr = FoaDecode.ar(in, decoder);

                // reorder output to match speaker arrangement
                [fl, fr, bl, br]
            }
        { kind == '5.0' }
            {
                // decode (to 5.0)
                #fc, fl, bl, br, fr = FoaDecode.ar(in, decoder);
                lo = Silent.ar;

                // reorder output to match speaker arrangement
                [fl, fr, fc, lo, bl, br]
            }
        { kind == 'panto' }
            {
                // decode (to hex)
                #fl, sl, bl, br, sr, fr = FoaDecode.ar(in, decoder);

                // reorder output to match speaker arrangement
                [fl, fr, sl, sr, bl, br]
            }
        { kind == 'peri' }
            {
                // decode (to cube)
                #flu, blu, bru, fru, fld, bld, brd, frd = FoaDecode.ar(in, decoder);

                // reorder output to match speaker arrangement
                [flu, fru, blu, bru, fld, frd, bld, brd]
            }
        { kind == 'diametric' }
            {
                // decode (to bi-rectangle)
                #fl, fr, slu, sru, br, bl, srd, sld = FoaDecode.ar(in, decoder);

                // reorder output to match speaker arrangement
                [fl, fr, bl, br, slu, sru, sld, srd]
            };
}
)



// implement pan4

(
SynthDef.new(\def4, {
arg dur, attack=0.01, release=1.0,
	t_gate=1, out, freq=442, cutoff=5500,
rq=1, panX=0.0, panY=0.0, amp=0.5;

var env = EnvGen.kr(Env.perc(attack, release), t_gate, timeScale: dur, doneAction: 2);
var sig = DPW3Tri.ar(freq: freq, mul: env);
sig = RLPF.ar(sig, cutoff.clip(20.0, 20000.0), rq.clip(0.0,1.0));
sig = Pan4.ar(sig, panX, panY, amp);
Out.ar(0, sig);
}).add;
)


//clean up randomness
(
Ndef(\polySaw,
	Pbind(\instrument, \def4,
	//\dur, Prand([1,1,2,1,4] * 0.08125, inf),
	//\type, Pseq([\note,\note,\rest],inf),//Pexprand(0.5, 0.2, inf),

		\degree, (Prand([Pseries(20, -1, 19), Pseries(10, -1, 9), Pseries(30, -3, 4)],inf) + Pseq([1,2,5,3,2,2,1,1],inf)),
	\detune, 0, //multiply hard super fm nearing additive
	\attack, Pkey(\dur) * 0.01,//0.01,// Prand((1..10) * 0.001,inf),
	\release,Pkey(\dur) * 2.5, //Pseq([1.3,0.2],inf) *2,//Prand((10..20) * 0.1,inf),
	\amp, 0.1,
	\scale, Scale.dorian, //Scale.diminished, //Scale.minor, //, Scale.major],inf), //Scale.dorian, Scale.mixolydian, Scale.locrian, Scale.lydianMinor,
	\tuning, Tuning.pythagorean, //Tuning.mean6,//pythagorean,
	\dur,0.1,
	//\dur, Pseq([3,0.3],inf) * 0.1,
	//\dur, Pseq([Pgeom(0.07, 1.01, 60)],inf) * 0.5,
	//\dur, Pexpodec(100,inf) + 0.1,
	//\dur, Pseq([1,2,3,4,1,1,2,1] * 0.5, inf),
	//\swm, 0.9, //Pexpodec(100,inf) + 0.01,//Phprand(0.39, 1.0, inf),
	\octave,3,//Pseq((-5..-5),inf),
	//\strum,Pseq((1..10) * 0.1, inf), //separate chords
	//\numHarm, 7,//add harmonics or choose?
	//\harmonics,10,
	//\legato,2,
	\panX,Pn(Pseries(-1.0,0.02,100),inf).trace, //Prand((1.0..-1.0), inf).trace,
	\panY,Pn(Pseries(1.0,-0.01,200),inf),//Prand((-1.0..1.0), inf).trace,
		//\out,0
));
)
Ndef.clear;

Ndef(\polySaw).play;
Ndef(\polySaw).fadeTime =2;
Ndef(\polySaw).clear(2);