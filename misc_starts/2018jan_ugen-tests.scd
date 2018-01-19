GrainFMJ.ar(numChannels: 1, trigger: 0, dur: 1, carfreq: 440, modfreq: 200, index: 1, grainAmp: 1, pan: 0, envbufnum: -1, maxGrains: 512, mul: 1, add: 0).play;

{ BlitB3D.ar(freq: 440, mul: 1, add: 0), XLine.kr(8000, 400, 5), 0.005 }.play;