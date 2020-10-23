//basic studio setup w all options
//1. comment out things you don't need
//2. set hardware devices, enable streams
//3. load samples, synthdefs, snippets, limiter
//4. modify midi setup as needed, synths and controllers
//current studio gear set: ff800/828mkii/midiExpressXT/nanoKontrol/bcr2000/wavestation/mks70/
//shout out to co34pt livecode tut

(
s.quit;
//SERVER and BUFFER
//increased buffers for samples
s.options.numBuffers = 1024 * 16;
//20 is 1 GB, 24 is 16 GB
s.options.memSize=2.pow(20);
//boot the server
s.boot;

//PROXYSPACE
//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 2;

//HARDWARE audio io settings
//////////////// LINUX ////////////////////
//set number of inputs and outputs
s.options.numInputBusChannels= 10;
s.options.numOutputBusChannels= 20;

// connect first to input channels with system

"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2,system:capture_3,system:capture_4,system:capture_5,system:capture_6,system:capture_7,system:capture_8,system:capture_9,system:capture_10,system:capture_11,system:capture_12,system:capture_13,system:capture_14,system:capture_15,system:capture_16,system:capture_17,system:capture_18,system:capture_19,system:capture_20");

// connect all output channels with system
// rme fireface800 1-10 analog audio out, 10-11 spdif, 12-20 adat 1 out (0 is ch1, and linux jack won't allow enable/disable streams)

"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1,system:playback_2,system:playback_3,system:playback_4,system:playback_5,system:playback_6,system:playback_7,system:playback_8,system:playback_9,system:playback_10,system:playback_11,system:playback_12,system:playback_13,system:playback_14,system:playback_15,system:playback_16,system:playback_17,system:playback_18,system:playback_19,system:playback_20");

// setup for using Audient iD4 usb, would need alsa
//"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2");
//"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1, system:playback_2");


"INs".postln;
s.options.numInputBusChannels.postln;
"OUTs".postln;
s.options.numOutputBusChannels.postln;
//LOAD samples to buffers, synthdefs, snippets, limiter, midi, nanoKontrol2

Task({
	3.wait;
	d = Dictionary.new;
	d.add(\foldernames -> PathName(/*thisProcess.nowExecutingPath.dirname +/+*/ "~/git/samples/001set/").entries);
	for (0, d[\foldernames].size-1,
		{arg i; d.add(d[\foldernames][i].folderName -> d[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});

	//load synthDefs
	("synthdefs2020.scd").loadRelative;

	//loads snippets from setup folder
	//("Snippets.scd").loadRelative;

	3.wait;

	//activate StageLimiter (BatLib quark)
	StageLimiter.activate;

	//MIDI
	// list midi sources
	//MIDIClient.sources;
	//MIDIClient.destinations;
	MIDIClient.init;
	5.wait;
	//modified to work w MKS-70 via MIDI Express XT, but fuck w latency
	//set latency to 0 on linux w ALSA, was 0.200 on macOS

	//////////////// LINUX MIDI ////////////////////
	// FULL STUDIO SETUP

	// OUT
	// 00 MPG
	d[\m0] = MIDIOut.newByName("mid16x", "mid16x MIDI 1").latency = (0); // (0.2555)
	// 01 WS
	d[\m1] = MIDIOut.newByName("mid16x", "mid16x MIDI 2").latency = (0); // (0.2555)
	// 02 MKS
	d[\m2] = MIDIOut.newByName("mid16x", "mid16x MIDI 3").latency = (0); // (0.2555)
	// 03 MMT
	d[\m3] = MIDIOut.newByName("mid16x", "mid16x MIDI 4").latency = (0); // (0.2555)
	// 04 PROsolo
	d[\m4] = MIDIOut.newByName("mid16x", "mid16x MIDI 5").latency = (0); // (0.2555)
	// 05 FF800
	//d[\m5] = MIDIOut.newByName("mid16x", "mid16x MIDI 6").latency = (0); // (0.2555)
	// 06 BCRdin
	d[\m6] = MIDIOut.newByName("mid16x", "mid16x MIDI 7").latency = (0); // (0.2555)
	// 07
	//d[\m7] = MIDIOut.newByName("mid16x", "mid16x MIDI 8").latency = (0); // (0.2555)
	// 09 NK2
	//d[\m8] = MIDIOut.newByName("mid16x", "mid16x MIDI 9").latency = (0); // (0.2555)
	// 10 LINNusb
	d[\m9] = MIDIOut.newByName("mid16x", "mid16x MIDI 10").latency = (0); // (0.2555)
	// MIDIsnoop
	//d[\m10] = MIDIOut.newByName("midisnoop", "MIDI Input"); // (0.2555)

	// 11 OXY
	//d[\m8] = MIDIOut.newByName("mid16x", "mid16x MIDI 9").latency = (0); // (0.2555)


	// IN
	// 00 MPG
	// 01 WS
	// 02 MKS
	// 03 MMT
	// 04
	// 05 FF800
	// 06 BCRdin
	// 07
	// 08 OXY
	// 09 NK2
	// 10 LINNusb
	// MIDIsnoop

	//nanokontrol2 (modality toolkit quark)
	//k = MKtl(\nk2, "*trol2");

	"Audio & MIDI setup complete".postln;
}).start;
)

s.quit;


// testing
//sending MIDI notes to MKS-70
(
p.clock.tempo = 150/60;
~mk1 = Pbind(\type, \midi, \midicmd, \noteOn, \midiout, d[\m0], \chan,1, \scale, Scale.dorian, \degree, Prand((23..55),inf), /* Pseq([Prand((1..16), inf,5), Prand((1..16), inf,7), Prand((1..16), inf,3), Prand((1..16), inf,2)], inf),*/ \dur, Pbjorklund2(Pexprand(2,8).round(1),16,inf,Pwhite(2,4).asStream)/23,\amp,Pexprand (0.8, 0.99, inf), \octave, 2).play;
)

(
p.clock.tempo = 150/60;
~mk2 = Pbind(\type, \midi, \midicmd, \noteOn, \midiout, d[\m1], \chan,0, \scale, Scale.dorian, \degree, Prand((23..55),inf), /* Pseq([Prand((1..16), inf,5), Prand((1..16), inf,7), Prand((1..16), inf,3), Prand((1..16), inf,2)], inf),*/ \dur, Pbjorklund2(Pexprand(2,8).round(1),16,inf,Pwhite(2,4).asStream)/23,\amp,Pexprand (0.8, 0.99, inf), \octave, 2).play;
)

(
p.clock.tempo = 150/60;
~mk2 = Pbind(\type, \midi, \midicmd, \noteOn, \midiout, d[\m4], \chan,0, \scale, Scale.dorian, \degree, Prand((23..55),inf), /* Pseq([Prand((1..16), inf,5), Prand((1..16), inf,7), Prand((1..16), inf,3), Prand((1..16), inf,2)], inf),*/ \dur, Pbjorklund2(Pexprand(2,8).round(1),16,inf,Pwhite(2,4).asStream)/23,\amp,Pexprand (0.8, 0.99, inf), \octave, 2).play;
)


//shows samples and midi
d.keys;
(
~mk1.free;
128.do({ |pitch| d[\m0].noteOff(0, pitch, 0);
	//d[\m1].noteOff(0, pitch, 0);
});
)

//test MKS-70 sysex messages - through MPG-70 is ideal
//MKS-70 sysex
// Upper/A F0 41 39 00 24 20 01 30 VAL F7
// Lower/B F0 41 39 00 24 20 02 30 VAL F7 MSB 00 LSB 25
// MSB 01 LSB 25 00-7F
(
~sysExArray = Pbind(
    \type, \midi,
    \midicmd, \sysex,
	\midiout, d[\m0],
	\array, Ptuple([0xf0, 0x41, 0x36, 0x00, 0x24, 0x20, 0x01,
		//0x36, Prand((0..80), inf), //env2 sus param, value
		//0x37, Prand((0..60), inf), //env2 rel param, value
		0x22, Prand((20..127), inf), //LPF Cutoff param, value
		0x0D, Pseq((1..127), inf, 2), //DCO 1 Tune param, value
		//0x13, 62, /*Pseq((1..127), inf, 3),*/ //DCO 2 Tune param, value
		//0x0C, Pexprand(40, 127, inf),
		0x0C, Pexprand(0, 127, inf), //DCO 1 Waveform param, value
		0xf7])
    .collect { |array| [array.as(Int8Array)] },  // <<-- brackets here
	\dur, Pbjorklund2(Pexprand(2,11).round(1),33,inf,Pwhite(1,5).asStream)/4,
).play;
)



(
~sysExArray.stop;
128.do({ |pitch| d[\m2].noteOff(0, pitch, 0); });
)



l = Prand([2,9,8],inf);

(
p.clock.tempo = 150/60;
~c = Pbind(\instrument,\bplay,\buf,Prand([d["clap"][1], /*d["clap"][3], d["clap"][2], d["clap"][0]]*/],inf),\dur,Pbjorklund2(Pexprand(1,2).round(1),16,inf,Pwhite(2,4).asStream)/8,\amp,0.49,\rate,Prand([1,1.3,8],inf));
~c2 = Pbind(\instrument,\bplaym,\buf,d["hhc"][0],\dur,Pbjorklund2(Prand([2,3,4],inf),16,inf,Pwhite(2,4).asStream)/16,\amp,0.99,\rate,1);
~k = Pbind(\instrument,\bplaym,\buf,d["kick"][0],\dur,Pbjorklund2(Pseq((1..4),inf),32,inf,0.asStream)/32,\amp,0.79,\rate,1);
~snare = Pbind(\instrument,\bplaym,\buf,d["sn"][3],\dur,Pbjorklund2(Pseq((1..2),inf),16,inf,0.asStream)/16,\amp,0.99,\rate,1);
~c.play;
~c2.play;
~k.play;
~snare.play;
)
~c.free;
~c2.free;
~k.free;
~snare.free;
//snare running forwards and back
(
p.clock.tempo = 150/60;
~sn = Pbind(\instrument,\bplay,\buf,d["sn"][3],\dur,Pbjorklund2(Pexprand(1,4).round(1),32,inf,Pwhite(1,4).asStream)/64,\amp, Pexprand(0.16, 0.99, inf), \rate,Pexprand(0.83, 11.53,inf), \pan, Pbjorklund2(Pexprand(8,16).round(1),16,inf,Pwhite(1,5).asStream)/2 * Prand((-1..1),inf));
~sn.play;
)
~sn.free;



s.record(duration: 5);
s.stopRecording;

//modular control test
(
p.clock.tempo = 150/60;
~o2 = Pmono(\dcev,
	\ch,12,\ampCh,13,
	\trig, 1,
	\degree, Pshuf((23..43),inf),
	\scale, Scale.major(\sruti),
	\dur, Pbjorklund2(Pseq((1..4),inf),16,inf,1.asStream)/16,  //+ Prand([0.33,Rest(0.33), Rest(0.33)],inf) * 1, //Pbjorklund2(Pseq((3..1),inf),16,inf,1.asStream)/1,
	\amp, Pexprand(0.7, 1, inf),
	\atk, Prand([1,10,5,1],inf)*0.001,
	\sus,Prand([1,5,1,1,2],inf)*0.04,
	\rel,Prand([1,3,10,1],inf)*0.01,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, -2,
	\port, Pseq([0,0,0.6,0,0.3],inf)
	); //Pexprand(0.03,0.5,inf));
~o2.play;

~o3 = Pmono(\dcev,
	\ch,16,\ampCh,17,
	\trig, 1,
	\degree, Pseq((23..37),inf),
	\scale, Scale.major(\sruti),
	\dur, Pbjorklund2(Pseq((3..1),inf),16,inf,1.asStream)/1,
	\amp, 0.68,//Pexprand(0.68, 0.95, inf),
	\atk, Pseq([1,3],inf)*0.1,
	\sus,Pseq([1,3,5],inf)*0.05,
	\rel,Pseq([1,4,5],inf)*0.01,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, -6,
	//\port, Pseq([0,0,0.6,0,0.3],inf)
	); //Pexprand(0.03,0.5,inf));
~o3.play;
)

// load alsa module
//sudo modprobe snd-mtpav
//lists cards
//cat /proc/asound/cards
//list cards
// aplay -l

//see also mads startup attmpt
// _setup or https://github.com/madskjeldgaard/sc-startup-file/blob/master/_setup.scd

/*SAMPLES
clap
cymb - cymbal
hhc - high hat closed
hho - high hat open
kick - kick drum
perc - percussion
rim
sfx - sound effects
sn - snare
tom
*/