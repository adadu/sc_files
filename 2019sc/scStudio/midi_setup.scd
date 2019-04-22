(
 //increase number of buffers the server has access to for loading samples
 s.options.numBuffers = 1024 * 16;
 //increase the memory available to the server
 s.options.memSize = 8192 * 64;
 //boot the server
 s.boot;
 //display the oscilloscope
 s.scope;
 //start proxyspace
 p=ProxySpace.push(s);
 //start tempo clock
 p.makeTempoClock;
 //give proxyspace a tempo
 p.clock.tempo = 2;
 Task({
 	3.wait;
  	d = Dictionary.new;
  	d.add(\foldernames -> PathName(thisProcess.nowExecutingPath.dirname +/+ "../samples/set1").entries);
	for (0, d[\foldernames].size-1,
		{arg i; d.add(d[\foldernames][i].folderName -> d[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});
  	("SynthDefs.scd").loadRelative;
  	//loads snippets from setup folder
  	("Snippets.scd").loadRelative;
 	//wait, because otherwise it won't work for some reason
 	3.wait;
  	//activate StageLimiter - Part of the BatLib quark
  	StageLimiter.activate;

	//midi
	MIDIClient.init;
	5.wait;
  	"Setup done!".postln;
	10.wait;
	//modified to work w MKS-70 via MIDI Express XT, but fuck w latency
	//may need to set latency to 0 on linux w ALSA
	d[\m] = MIDIOut.newByName("MIDI Express XT", "Port 3").latency = (0.2000);
	//nanokontrol2 (modality toolkit quark)
	k = MKtl(\nk2, "*trol2");
	"MIDI only setup complete".postln;

 }).start;
 )

s.latency


