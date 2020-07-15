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
// p=ProxySpace.push(s);
//start tempo clock
// p.makeTempoClock;
//give proxyspace a tempo
// p.clock.tempo = 2;

//HARDWARE audio io settings
//////////////// LINUX ////////////////////
//set number of inputs and outputs
s.options.numInputBusChannels= 10;
s.options.numOutputBusChannels= 20;

// connect first to input channels with system
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2,system:capture_3,system:capture_4,system:capture_5,system:capture_6,system:capture_7,system:capture_8,system:capture_9,system:capture_10,");
/*system:capture_11,system:capture_12,system:capture_13,system:capture_14,system:capture_15,system:capture_16,system:capture_17,system:capture_18,system:capture_19,system:capture_20*/

// connect all output channels with system
// rme fireface800 1-10 analog audio out, 10-11 spdif, 12-20 adat 1 out (0 is ch1, and linux jack won't allow enable/disable streams)
"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1,system:playback_2,system:playback_3,system:playback_4,system:playback_5,system:playback_6,system:playback_7,system:playback_8,system:playback_9,system:playback_10,system:playback_11,system:playback_12,system:playback_13,system:playback_14,system:playback_15,system:playback_16,system:playback_17,system:playback_18,system:playback_19,system:playback_20");
// setup for using Audient iD4 usb, would need alsa
// "SC_JACK_DEFAULT_INPUTS".setenv("iD4:capture_1,iD4:capture_2");
// "SC_JACK_DEFAULT_OUTPUTS".setenv(iD4:playback_1, iD4:playback_2");

//////////////// MAC OS ///////////////////
//list audio io devices
//ServerOptions.devices;
//built in macOS output
//s.options.device= "Built-in Output";
//rme fireface800
//s.options.device="Fireface 800 (3EC)";
//s.options.numInputBusChannels = 8;
//s.options.numOutputBusChannels = 8;
//Fireface w/ ADAT channel outs activated
//s.options.numOutputBusChannels = 20;
//s.options.outputStreamsEnabled = "11111111111111111111";
// motu 828
//s.options.device = "MOTU 828";
// motu 828mk2
//s.options.device = "MOTU 828mk2";
//activate/deactivate channels
//s.options.outputStreamsEnabled = "11111111";

"INs".postln;
s.options.numInputBusChannels.postln;
"OUTs".postln;
s.options.numOutputBusChannels.postln;
//LOAD samples to buffers, synthdefs, snippets, limiter, midi, nanoKontrol2

Task({
	3.wait;
	d = Dictionary.new;
	// MAC - d.add(\foldernames -> PathName(thisProcess.nowExecutingPath.dirname +/+ "../../../../samples/001set/").entries);
	d.add(\foldernames -> PathName(/*thisProcess.nowExecutingPath.dirname +/+*/ "/home/jea/git/samples/001set/").entries);
	for (0, d[\foldernames].size-1,
		{arg i; d.add(d[\foldernames][i].folderName -> d[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});

	//load synthDefs
	//("synthdefs2020.scd").loadRelative;

	//loads snippets from setup folder
	//("Snippets.scd").loadRelative;

	3.wait;

	//activate StageLimiter (BatLib quark)
	StageLimiter.activate;

	//MIDI
	// list midi sources
	MIDIClient.sources;
	MIDIClient.init;
	5.wait;
	//modified to work w MKS-70 via MIDI Express XT, but fuck w latency
	//set latency to 0 on linux w ALSA, was 0.200 on macOS

	//////////////// LINUX MIDI ////////////////////
	//remove comments for use
	//BCR 2000
	//d[\m] = MIDIOut.newByName("MTPAV on parallel port", "MTP direct 1").latency = (0.2555);
	//WS a/d
	//d[\m1] = MIDIOut.newByName("MTPAV on parallel port", "MTP direct 2").latency = (0.2555);
	//MKS-70
	//d[\m3] = MIDIOut.newByName("MTPAV on parallel port", "MTP direct 3").latency = 0; //(0.2555);
	d[\m4] = MIDIOut.newByName("Fireface800", "Fireface800 MIDI 1").latency = 0; //(0.2555);

	    //d[\m5] = MIDIOut.newByName("Virtual Raw MIDI 3-0", "VirMIDI 3-0").latency = 0; //(0.2555);
		//d[\m6] = MIDIOut.newByName("Virtual Raw MIDI 3-1", "VirMIDI 3-1").latency = 0; //(0.2555);
		//d[\m7] = MIDIOut.newByName("Virtual Raw MIDI 3-2", "VirMIDI 3-2").latency = 0; //(0.2555);
		//d[\m8] = MIDIOut.newByName("Virtual Raw MIDI 3-3", "VirMIDI 3-3").latency = 0; //(0.2555);


	//MMT-8, RME Fireface, MOTU 828, Kenton, Linnstrument
	//d[\m3] = MIDIOut.newByName("MIDI Express XT", "Port 4").latency = (0.200);
	//d[\m4] = MIDIOut.newByName("MIDI Express XT", "Port 5").latency = (0.200);
	//d[\m5] = MIDIOut.newByName("MIDI Express XT", "Port 6").latency = (0.200);
	//d[\m6] = MIDIOut.newByName("MIDI Express XT", "Port 7").latency = (0.200);
	//d[\m7] = MIDIOut.newByName("MIDI Express XT", "Port 8").latency = (0.200);
	//d[\m8] = MIDIOut.newByName("MIDIPort32", "Port 1").latency = (0.200);
//MIDIClient.destinations[2].uid.postln

	//////////////// MAC OS MIDI ///////////////////
	//remove comments for use
	//BCR 2000
	// d[\m] = MIDIOut.newByName("MIDI Express XT", "Port 1").latency = (0);
	//WS a/d
	// d[\m1] = MIDIOut.newByName("MIDI Express XT", "Port 2").latency = (0);
	//MKS-70
	// d[\m2] = MIDIOut.newByName("MIDI Express XT", "Port 3").latency = (0);
	//MMT-8, RME Fireface, MOTU 828, Kenton, Linnstrument
	//d[\m3] = MIDIOut.newByName("MIDI Express XT", "Port 4").latency = (0.200);
	//d[\m4] = MIDIOut.newByName("MIDI Express XT", "Port 5").latency = (0.200);
	//d[\m5] = MIDIOut.newByName("MIDI Express XT", "Port 6").latency = (0.200);
	//d[\m6] = MIDIOut.newByName("MIDI Express XT", "Port 7").latency = (0.200);
	//d[\m7] = MIDIOut.newByName("MIDI Express XT", "Port 8").latency = (0.200);
	//d[\m8] = MIDIOut.newByName("MIDIPort32", "Port 1").latency = (0.200);

	//test w MIDI monitor - for working at work
	//d[\m9] = MIDIOut.newByName("MIDI Monitor (scMIDImonitor)", "MIDI Monitor (scMIDImonitor)").latency = (0.200);
	//set input does n't work
	//d[\n] = MIDIIn.connect;  /*("MIDI Express XT", "Port 3").latency = (0.200);*/
	//nanokontrol2 (modality toolkit quark)
	//k = MKtl(\nk2, "*trol2");
	"Audio & MIDI setup complete".postln;
}).start;
)


// testing
//sending MIDI notes to MKS-70
(
~mk1 = Pbind(\type, \midi, \midicmd, \noteOn, \midiout, d[\m4], \scale, Scale.minor, \degree, Pseq([ Prand((23..37),inf),Prand((23..37),inf),Prand((23..37),inf)],inf), /* Pseq([Prand((1..16), inf,5), Prand((1..16), inf,7), Prand((1..16), inf,3), Prand((1..16), inf,2)], inf),*/ \dur, Pbjorklund2(Pexprand(2,8).round(1),16,inf,Pwhite(2,4).asStream)/16,\amp,Pexprand (0.8, 1, inf), \octave, 0);
)

~mk1player = ~mk1.play;
~mk1player.stop;
~mk1player.pause;
~mk1player.play;
~mk1player.clear;

// doesn't work
(
~mk1Filter = Pbind(\type, \midi, \midicmd, \control, \midiout, d[\m4], \chan,0, \ctlNum, 23, \value, Pseq((0..16),inf).trace, \dur, 0.1);
)

~mk1Filterplayer = ~mk1Filter.play;
~mk1Filterplayer.stop;
~mk1Filterplayer.pause;
~mk1Filterplayer.play;
~mk1Filterplayer.clear;


// PANIC BUTTON
128.do({ |pitch| d[\m4].noteOff(0, pitch, 0); });



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