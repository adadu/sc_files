s.boot

m=SimpleMIDIFile.read("/Users/draft/repos/sc/004-sc-beginnings-MAY17/midi/Bobby_McFerrin_-_Dont_Worry_Be_Happy.mid");
x=m.p(inst: \iter).trace;
y=x.iter.all(());
m.midiEvents.dopostln;
m.free;
p=Pseq(y, 2).play;