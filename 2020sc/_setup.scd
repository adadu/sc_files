(
//// START SERVER
/* s.options.outDevice = "Fireface UC Mac (23741446)"; // MIT FIREFACE UC ! ! */
/* s.options.inDevice = "Fireface UC Mac (23741446)"; // MIT FIREFACE UC ! ! */
s.options.outDevice = "Soundflower (2ch)";
//s.options.outDevice = "Soundflower (64ch)";
/* s.options.outDevice = "Built - in Output"; */
//s.options.outDevice = "Fireface UC Mac (23749504)"; // 103
//s.options.inDevice = "Fireface UC Mac (23749504)"; // 103
/* s.options.outDevice = "Fireface UFX (23594117)"; // 112 Fireface */
//s.options.outDevice = "Fireface UFX (23616771)"; // 108 Fireface
//s.options.outDevice == "Fireface UFX (23323333)"; // 110 Fireface

// Allocate memory
s.options.memSize = 8192 * 164;

/* s.options.blockSize = 2048; */
//s.options.blockSize = 1;

// Set sample rate
s.options.sampleRate = nil; // System default
//s.options.sampleRate = 44100;

/* s.options.numInputBusChannels = 0; */
// Number of hardware ins / outs
if (s.options.outDevice == "Fireface UFX (23594117)") { s.options.numOutputBusChannels = 8;
};
if (s.options.outDevice == "Soundflower (64ch)") {s.options.numOutputBusChannels = 64;
};
if (s.options.outDevice == "Fireface UFX (23323333)") { s.options.numOutputBusChannels = 8;
};
if (s.options.outDevice == "Built - in Output") { s.options.numOutputBusChannels = 2;
};

s.options.numInputBusChannels = 20;
/* s.options.numOutputBusChannels = 20; */


// increase this if you are getting drop outs and the message "too many nodes"
s.options.maxNodes = 1024 * 128;

s.options.numAudioBusChannels = 4048;

// Audio meters
//s.meter;

// Increase number of buffers available
s.options.numBuffers = 1024 * 16;

// Server visualisation
//s.plotTree;

// Boot the server

s.reboot;


/* Task({ */
/*     // Load synth defs */
/*     1.wait; */
/*     ("_synthdefs/unison_sampleplayers.scd").load; */
/*     1.wait; */
/*     ("_synthdefs/samples.scd").load; */
/*     1.wait; */
/*     ("_synthdefs/physical.scd").load; */
/*     1.wait; */
/*     ("_synthdefs/effects.scd").load; */
/*     1.wait; */
/*     ("_synthdefs/granular.scd").load; */
/*     1.wait; */
/*     ("_synthdefs/synth.scd").load; */
/*     1.wait; */
/*     ("_synthdefs/feedback - synths.scd").load; */
/*     1.wait; */
/*     ("_synthdefs/expert - sleepers - synths.scd").load; */
/*     "Done loading synth defs".postln; */
/* }).start; */
)

///// LOAD SAMPLE LIBRARIES
(
// Load sound object archive
Task({
    "Loading folders with sound files ".postln;
    3.wait;
    o = Dictionary.new;
    o.add(\foldernames - > PathName("/Users/madskjeldgaard/Desktop/SOUNDCENTRAL/ALGOFODDER").entries);
        for (0, o[ \foldernames ].size - 1,
        {arg i; o.add(o[ \foldernames ][ i ].folderName - >
        o[ \foldernames ][ i ].entries.collect({
            arg sf;
            Buffer.read(s, sf.fullPath);
            });
   );
    "Loaded % ".format(o[ \foldernames ][ i ].folderName.quote).postln;
    });
    //wait, because otherwise it won't work for some reason
    3.wait;
    "Done loading sound files to buffers".postln;
}).start;

)

(
//// RECORD
var datetime = Date.getDate.format(" % d % m % Y_ % H: % M: % S"),
path = "/Users/madskjeldgaard/Desktop/ableton/User\ Library/Sounds/SUPERCOLLIDER_RECORDINGS";

s.record(path ++ "/" ++ "sc_" ++ datetime ++ "." ++ s.recHeaderFormat);

//s.stopRecording
)

ServerOptions.outDevices[5];
s.meter;