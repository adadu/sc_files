//Load setup file to get examples working
("setup.scd").loadRelative;

s.quit
//RECORD
s.record(duration: 20);
s.stopRecording;

//MIDI local
MIDIIn.connectAll;
MIDIdef.cc(\test1, {arg ...args; args.postln}, 0, 0);
MIDIFunc.cc({arg ...x; x.postln; });
// match cc 1


(
// MIDIdef.cc(key, func, ccNum, chan, srcID, argTemplate, dispatcher)

MIDIdef.cc(\mod, {
	arg val;
	c=val.linlin(0, 127, -0.5, 5);
	~sn.set(\rate, c);
	~sn1.set(\rate, c);
	~sn2.set(\rate, c); }, 5, 0);

MIDIdef.noteOn(\green, {
	~sn.play; }, 60, 0);

MIDIdef.noteOff(\greenOff, {
	~sn.free; }, 60, 0);

MIDIdef.noteOn(\white, {
	~sn1.play; }, 61, 0);

MIDIdef.noteOff(\whiteOff, {
	~sn1.free; }, 61, 0);

MIDIdef.noteOn(\red, {
	~sn2.play; }, 62, 0);

MIDIdef.noteOff(\redOff, {
	~sn2.free; }, 62, 0);

)


a.free

//snare running forwards and back
(
p.clock.tempo = 150/60;
~sn = Pbind(\instrument,\bplay,\buf,d["sn"][3],\dur,Pbjorklund2(Pexprand(1,4).round(1),32,inf,Pwhite(1,4).asStream)/64,\amp, Pexprand(0.16, 0.99, inf), \rate, 1/*Pexprand(0.83, 11.53,inf)*/, \pan, Pbjorklund2(Pexprand(8,16).round(1),16,inf,Pwhite(1,5).asStream)/2 * Prand((-1..1),inf));
)

~sn.free;

(
p.clock.tempo = 150/60;
~sn1 = Pbind(\instrument,\bplay,\buf,d["sn"][9],\dur,Pbjorklund2(Pexprand(1,4).round(1),32,inf,Pwhite(1,4).asStream)/128,\amp, Pexprand(0.16, 0.99, inf), \rate, 1/*Pexprand(0.83, 11.53,inf)*/, \pan, Pbjorklund2(Pexprand(8,16).round(1),16,inf,Pwhite(1,5).asStream)/2 * Prand((-1..-1),inf));
)

~sn1.free;

(
p.clock.tempo = 150/60;
~sn2 = Pbind(\instrument,\bplay,\buf,d["sn"][6],\dur,Pbjorklund2(Pexprand(16,24).round(1),32,inf,Pwhite(1,4).asStream)/256,\amp, Pexprand(0.16, 0.99, inf), \rate, 1/*Pexprand(0.83, 11.53,inf)*/, \pan, Pbjorklund2(Pexprand(8,16).round(1),16,inf,Pwhite(1,5).asStream)/2 * Prand((-1..1),inf));
)

~sn2.free;




s.freeAll;
p.free
s.quit

