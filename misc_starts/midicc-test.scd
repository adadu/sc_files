// Initialise MIDI connection

MIDIClient.init;
MIDIClient.destinations;


(
var mOut = MIDIOut.newByName("Native Instruments FM8 Virtual Input", "Native Instruments FM8 Virtual Input");
// Pattern for MIDI notes
p = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, mOut,
	\chan, 0,
	\note, Prand([0, 2, 4, 9, 7], inf),
	         \midiout, mOut,
         	  \db, Pbrown(0, -6, 1, inf),
         	  \dur, Pseq([2, 1, 1], inf)
).play(quant:1);
)

(
var mOut = MIDIOut.newByName("Native Instruments FM8 Virtual Input", "Native Instruments FM8 Virtual Input");

// Pattern for CC 3
q = Pbind(\type, \midi,
	\midicmd, \control,
	\midiout, mOut,
	\chan, 0,
	      \control, Pseq((0..127),inf),
	\dur, 0.1,
          \ctlNum, 2
).play(quant:1);
)

(
var mOut = MIDIOut.newByName("Native Instruments FM8 Virtual Input", "Native Instruments FM8 Virtual Input");

// Pattern for CC 4
r = Pbind(\type, \midi,
	\midicmd, \control,
	\midiout, mOut,
	\chan, 0,
	\control, Pseq((0..127),inf),
		\dur, 0.1,
          \ctlNum, 3
).play(quant:1);
)

(
var mOut = MIDIOut.newByName("Native Instruments FM8 Virtual Input", "Native Instruments FM8 Virtual Input");

// Pattern for CC 4
r = Pbind(\type, \midi,
	\midicmd, \control,
	\midiout, mOut,
	\chan, 0,
	\control, Pseq((0..30),inf),
		\dur, 0.1,
          \ctlNum, 3
).play(quant:1);
)
