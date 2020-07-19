(
var modularcalibration = (

    // Get the frequency of the oscillator
    // And post it to a control bus
    trackOscillatorInput: {| self, oscillatorInput=5|

        {
        var in = SoundIn.ar(oscillatorInput); //In.ar(5, 1);
        var freq, hasFreq;

        # freq, hasFreq = Pitch.kr(in);

        Out.kr(self.controlBusses.frequencyBus, freq);
        }
    },

    // Raise or lower the cv output according to frequency value
    checkFreq: {|self, targetFreq=200|

        self.controlBusses.frequencyBus.get{|value|
            "Current frequency: %".format(value).postln;
            case
                { value.round == targetFreq} {10.do{"perfect!!".postln}}
                { value < targetFreq} {"too low".postln; self.changeCV(0.01)}
                { value > targetFreq} {"too high".postln;self.changeCV(-0.01) }
            }

    },

    changeCV: {|self, changeValue|
        var currentValue;

        self.controlBusses.cvOut.get{|val| currentValue = val };
        currentValue.postln;
        self.controlBusses.cvOut.set{currentValue + changeValue};

    },

    cvSynth: {|self, hardwareOut=15|
        {
            Out.ar(hardwareOut, K2A.ar(In.kr(self.controlBusses.cvOut)))
        }
    },

    // init
    init: {|self|
        self.controlBusses = ();
        self.controlBusses.frequencyBus = Bus.control(s,1);
        self.controlBusses.cvOut = Bus.control(s,1);
        //self.controlBusses.cvOut.set(0);

        self.cvSynth.play;
        self.trackOscillatorInput.play;

        fork{
            loop{
                self.checkFreq.value; 0.1.wait
            }
        }
    }
);

modularcalibration.init;
modularcalibration.controlBusses.cvOut.scope;
)
s.meter;