// boot server
s.boot

// init for one port midi interface
MIDIIn.connect;

// synthdef
(
SynthDef(\sound,{arg freq=440, amp=0;
var sig, saw ;
saw= Saw.ar(freq);
sig=saw*amp;
Out.ar(0,sig.dup(2))
}).add;
)

// synth
a= Synth(\sound);

// assign cc controls manually
MIDIdef.cc(\ampCC, {arg ampVal ...args; a.set(\amp, ampVal/127); args.postln}, 0);
MIDIdef.cc(\freqCC, {arg freqVal ...args; a.set(\freq, freqVal/127*200); args.postln}, 1);