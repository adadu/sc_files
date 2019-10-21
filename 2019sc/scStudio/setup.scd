//basic studio setup w all options
//1. comment out things you don't need
//2. set hardware devices, enable streams
//3. load samples, synthdefs, snippets, limiter
//4. modify midi setup as needed, synths and controllers
//current studio gear set: ff800/828mkii/midiExpressXT/nanoKontrol/bcr2000/wavestation/mks70/
//shout out to co34pt livecode tut

(
//SERVER and BUFFER
//increased buffers for samples
s.options.numBuffers = 1024 * 16;
//this is about 1GB, may vary based on RAM
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

// s.options.outputStreamsEnabled = "11111111";

// motu 828
//s.options.device = "MOTU 828";

// motu 828mk2
//s.options.device = "MOTU 828mk2";



//activate/deactivate channels
s.options.outputStreamsEnabled = "11111111";

"INs".postln;
s.options.numInputBusChannels.postln;
"OUTs".postln;
s.options.numOutputBusChannels.postln;
//LOAD samples to buffers, synthdefs, snippets, limiter, midi, nanoKontrol2
Task({
	3.wait;
	d = Dictionary.new;
	d.add(\foldernames -> PathName(thisProcess.nowExecutingPath.dirname +/+ "../../../../samples/001set/").entries); ///Users/draft/git/samples/001set/ ???
	for (0, d[\foldernames].size-1,
		{arg i; d.add(d[\foldernames][i].folderName -> d[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});
	// UNCOMMENT THIS FOR ANYTHING BUT CORM
	("synthdefs.scd").loadRelative;
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
	//may need to set latency to 0 on linux w ALSA
	//remove comments for use
	//d[\m] = MIDIOut.newByName("MIDI Express XT", "Port 1").latency = (0.200);
	//WS a/d
	//d[\m1] = MIDIOut.newByName("MIDI Express XT", "Port 2").latency = (0.200);
	//MKS-70
	//d[\m2] = MIDIOut.newByName("MIDI Express XT", "Port 3").latency = (0.200);
	//d[\m3] = MIDIOut.newByName("MIDI Express XT", "Port 4").latency = (0.200);
	//d[\m4] = MIDIOut.newByName("MIDI Express XT", "Port 5").latency = (0.200);
	//d[\m5] = MIDIOut.newByName("MIDI Express XT", "Port 6").latency = (0.200);
	//d[\m6] = MIDIOut.newByName("MIDI Express XT", "Port 7").latency = (0.200);
	//d[\m7] = MIDIOut.newByName("MIDI Express XT", "Port 8").latency = (0.200);
	//test w MIDI monitor - for working at work
	//d[\m8] = MIDIOut.newByName("MIDI Monitor (scMIDImonitor)", "MIDI Monitor (scMIDImonitor)").latency = (0.200);
	//set input does n't work
	//d[\n] = MIDIIn.connect;  /*("MIDI Express XT", "Port 3").latency = (0.200);*/
	//nanokontrol2 (modality toolkit quark)
	//k = MKtl(\nk2, "*trol2");
	"Audio & MIDI setup complete".postln;
}).start;
)

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