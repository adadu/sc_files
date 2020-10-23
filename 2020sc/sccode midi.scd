s.quit
(
s.waitForBoot({
	var gen, swingify;
	var presets;
	var composite;

	if (MIDIClient.initialized.not) { MIDIClient.init; };

	// update to connect to your own midi keyboard here
	~midiout = MIDIOut.newByName("MIDI Express XT", "Port 1");
	//	MIDIEndPoint("LinnStrument MIDI", "LinnStrument MIDI", -1123053513)
	//	MIDIEndPoint("MIDI Express XT", "Port 1", -814276563)


		/* EDITOR SETUP SHORTCUT: sets Cmd+period as shortcut to stop
		all MIDI sound (for testing as emergency stop shortcut) */
		CmdPeriod.add({(0..127).do{arg n; m.noteOff(0, n)}});


	t= TempoClock.default;
	t.tempo;
	t.tempo_(80/60); // 72 beats per minute

	~percmap = (
		\laser: 27,
		\whip: 28,
		\scratchpush: 29,
		\scratchpull: 30,
		\stickclick: 31,
		\metronomeclick:32,
		\metronomebell:34,
		\bassdrum:35,
		\kickdrum:36,
		\snarecrossstick:37,
		\snaredrum:38,
		\handclap:39,
		\electricsnaredrum:40,
		\floortom2:41,
		\hihatclosed:42,
		\floortom1:43,
		\hihatfoot:44,
		\lowtom:45,
		\hihatopen:46,
		\lowmidtom:47,
		\highmidtom:48,
		\crashcymbal:49,
		\hightom:50,
		\ridecymbal:51,
		\chinacymbal:52,
		\ridebell:53,
		\tambourine:54,
		\splashcymbal:55,
		\cowbell:56,
		\crashcymbal2:57,
		\vibraslap:58,
		\ridecymbal2:59,
		\highbongo:60,
		\lowbongo:61,
		\congadeadstroke:62,
		\conga:63,
		\tumba:64,
		\hightimbale:65,
		\lowtimbale:66,
		\highagogo:67,
		\lowagogo:68,
		\cabasa:69,
		\maracas:70,
		\whistleshort:71,
		\whistlelong:72,
		\guiroshort:73,
		\guirolong:74,
		\claves:75,
		\highwoodblock:76,
		\lowwoodblock:77,
		\cuicahigh:78,
		\cuicalow:79,
		\trianglemute:80,
		\triangleopen:81,
		\shaker:82,
		\sleighbell:83,
		\belltree:84,
		\castagnets:85,
		\surdudeadstroke:86,
		\surdu:87,
		\snaredrumrod:91,
		\oceandrum:92,
		\snaredrumbrush:93
	);

	gen = {
		| pattern="x.x.",
		instrument=\kickdrum,
		midiout=nil,
		repeat=1,
		division=8,
		midichannel=9,
		amplitudeerrors=0,
		timingerrors=0,
		percmap = nil|

		Pn(
			Pbind(
				\type, \midi,
				\midicmd, \noteOn,
				\midiout, midiout,
				\chan, midichannel,
				\midinote, Prout({
					pattern.do({
						| character |
						if (character != $.) {
							percmap[instrument].yield;
						} {
							Rest(0).yield;
						};
					});
				}),
				\amp, Prout({
					pattern.do({
						| character |
						if (character == $X) {
							(0.8 + (amplitudeerrors/2.0).rrand(amplitudeerrors/2.0.neg)).yield;
						} {
							if (character == $x) {
								(0.5 + (amplitudeerrors/2.0).rrand(amplitudeerrors/2.0.neg)).yield;
							} {
								0.yield;
							};
						};
					});
				}),
				\dur, Prout({
					var durations = pattern.collectAs({1.0/division}, Array);
					var totalduration = pattern.size * (1.0/division);
					var durations_with_errors = durations.collect({
						| dur |
						dur + (timingerrors/2.0).rrand(timingerrors/2.0.neg);
					}).normalizeSum * totalduration;
					durations_with_errors.do({ |el|
						el.yield;
					});
			})),
			repeat);
	};


	presets = (
		\ummtss : [
			["x.X.", \kickdrum, 4],
			[".x.x", \hihatclosed, 4],
		],

		\billiejean : [
			["X.......X.......", \kickdrum, 8],
			["....X.......X...", \snaredrum, 8],
			["X.X.X.X.X.X.X.X.", \hihatclosed, 8],
		],

		\thefunkydrummer : [
			["X.X...X...X..X..", \kickdrum, 8],
			["....X..X.X.XX..X", \snaredrum, 8],
			["XXXXXXX.XXXXX.XX", \hihatclosed, 8],
			[".......X.....X..", \hihatopen, 8],
		],

		\impeachthepresident : [
			["X......XX.....X.", \kickdrum, 8],
			["....X.......X...", \snaredrum, 8],
			["X.X.X.XXX...X.X.", \hihatclosed, 8],
			["..........X.....", \hihatopen, 8],
		],

		\whentheleveebreaks : [
			["XX.....X..XX....", \kickdrum, 8],
			["....X.......X...", \snaredrum, 8],
			["X.X.X.X.X.X.X.X.", \hihatclosed,8],
		],

		\walkthisway : [
			["X......XX.X.....", \kickdrum, 8],
			["....X.......X...", \snaredrum, 8],
			["..X.X.X.X.X.X.X.", \hihatclosed, 8],
			["X...............", \hihatopen, 8],
		],

		\itsanewday : [
			["X.X.......XX...X", \kickdrum, 8],
			["....X.......X...", \snaredrum, 8],
			["X.X.X.X.X.X.X.X.", \hihatclosed, 8],
		],

		\papawastoo : [
			["X......XX.X....X", \kickdrum, 8],
			["....X.......X...", \snaredrum, 8],
			["....X...X.X.X.XX", \hihatclosed, 8],
			["....X...........", \tambourine, 8],
		],

		\thebigbeat : [
			["X..X..X.X.......", \kickdrum, 8],
			["....X.......X...", \snaredrum, 8],
			["....X.......X...", \handclap, 8],
		],

		\ashleysroachclip : [
			["X.X...X..XX.....", \kickdrum, 8],
			["....X.......X...", \snaredrum, 8],
			["X.X.X.X.X...X.X.", \hihatclosed, 8],
			["..........X.....", \hihatopen, 8],
			["XxXxXxXxXxXxXxXx", \tambourine, 8],
		],

		\takemetothemardigras : [
			["X.........X..X..X..X......X.....", \kickdrum, 8],
			["....X.......X.......X..X.X..X...", \snaredrum, 8],
			["X.X.X.XXX.X.X.XXX...X.XXX.X.X...", \hihatclosed, 8],
			["..............................X.", \hihatopen, 8],
			["X.X..X...X..X...X.X..X...X..X...", \highagogo, 8],
			["....X..X..X..X.X....X..X..X..X.X", \lowagogo, 8],
		],

		\syntheticsubstitution : [
			["X.X....X.XXX...XX.X....X.XXX...X", \kickdrum, 8],
			["....X.......X.......X.......X...", \snaredrum, 8],
			["X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.", \hihatclosed, 8],
			["..................X.............", \hihatopen, 8]
		],

		\amenbrother : [
			["X.X.......XX....X.X.......XX....X.X.......X.......XX......X.....", \kickdrum, 8],
			["....X..X.X..X..X....X..X.X..X..X....X..X.X....X..X..X..X.X....X.", \snaredrum, 8],
			["X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X...X.X.", \ridecymbal, 8],
			["..........................................................X.....", \hihatopen, 8]
		],

		\apache : [
			["X.........X.....X.X.......X.....X.X.......X.....X.X.......X.....", \kickdrum, 8],
			["....X....X..X..X....X....X..X..X....X....X..X..X....X....X..X..X", \snaredrum, 8],
			["X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.", \hihatclosed, 8],
			["X.........X.....X.XX..........X...X.............X.....XX...X..X.", \conga, 8],
			["....X..X.X..X..X....X..X.XX.XX..X..XX..X.XX..XX....XX.......XX..", \congadeadstroke, 8],
		],

		\rock1 : [
			["X.X...X.X.X...X.", \kickdrum, 8],
			["....X.......X...", \snaredrum, 8],
			["X.X.X.X.X.X.X.X.", \hihatclosed, 8]
		],

		\techno1 : [
			["X...X...X...X.X.", \kickdrum, 8],
			["....X.......X...", \snaredrum, 8],
			[".........X......", \hihatclosed, 8],
			["...X...X...X...X", \hihatopen, 8],
		],

		\hiphop1 : [
			["X......X..X..X.X", \kickdrum, 8],
			["....X.......X...", \snaredrum, 8],
			["X.X.X.X.X.X.X.X.", \hihatclosed, 8],
		],

		\sonclave : [
			["X..XX..XX..XX..X", \kickdrum, 8],
			["X..X..X...X.X...", \stickclick, 8],
			["XXXXXXXXXXXXXXXX", \ridecymbal2, 8],
		],

		\rumba : [
			["X..XX..XX..XX..X", \kickdrum, 8],
			["X..X...X..X.X...", \stickclick, 8],
			["XXXXXXXXXXXXXXXX", \ridecymbal2, 8],
		],

		\bossanova : [
			["X..XX..XX..XX..X", \kickdrum, 8],
			["X..X..X...X..X..", \stickclick, 8],
			["XXXXXXXXXXXXXXXX", \ridecymbal2, 8],
		],

		\soukous : [
			["X...X...X...X.X.", \kickdrum, 8],
			["X..X..X.X..X..X.", \stickclick, 8],
			["X..X..X..XX.....", \lowagogo, 8],
		],

		\gahu : [
			["X...X...X...X.X.", \kickdrum, 8],
			["..XX..XX..XX..XX", \stickclick, 8],
			["X..X..X...X...X.", \lowagogo, 8],
		],

		\shiko : [
			["X...X.X.X...X.X.", \kickdrum, 8],
			["..XX..XX..XX..XX", \stickclick, 8],
			["X...X.X...X.X...", \lowagogo, 8],
		],

		\phasingshiko : [
			["X...X.X.X...X.X.", \kickdrum, 8],
			["..XX..X.X..XX..XX", \stickclick, 8],
			["X...X.X...X.X...", \lowagogo, 8],
		],

		\poly : [
			["X.X.x.X.x.X.", \kickdrum, 6],
			["X.X.X.x.", \hihatclosed, 4],
			["X..X....x.X..x", \stickclick, 7],
		],

	);

	composite = Ppar(presets[\thebigbeat].collect({|el|
		gen.(
			pattern: el[0],
			instrument: el[1],
			midiout: ~midiout,
			repeat: inf,
			division: el[2],
			midichannel: 0,
			amplitudeerrors:0, //0.1,
			timingerrors: 0, //0.02,
			percmap: ~percmap);
	}));
	~player = composite.play;

});
)