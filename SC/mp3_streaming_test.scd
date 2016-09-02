
// Let's read in an internet radio stream and warp it a bit.
// First we need a synthdef:
s.boot;
(
SynthDef("str_read", { |bufnum = 0|
    var son, wibble;
    son = DiskIn.ar(2, bufnum);
    //     wibble = LFPar.kr(0.1).range(0.5, 2.0);
    //     son = PitchShift.ar(son, pitchRatio: wibble);
    Out.ar(0, son);
}).add;

)

// Now let's create the MP3 object and cue it into a Buffer.

// Choose one of these two:
// (a) a stream URL - note the use of the second argument to indicate a remote stream
m = MP3("http://stream.resonance.fm:8000/resonance-extra", \readurl);
m = MP3("http://mp3s.nc.u-tokyo.ac.jp/OTSUCHI_CyberForest.mp3", \readurl);

n.start;
m.start;
// Now you can use it almost like any other file, by reading from m.fifo
b = Buffer.cueSoundFile(s, m.fifo, 0, 2);
c = Buffer.cueSoundFile(s, n.fifo, 0, 2);

x = Synth("str_read", [\bufnum, b.bufnum], addAction:\addToTail);
y = Synth("str_read", [\bufnum, c.bufnum], addAction:\addToTail);
m.playing;
n.playing;
// You can stop and restart the piping (with a bit of a delay) - note what happens
m.stop;
n.stop;
m.playing;
m.restart;
m.playing;
// Please remember to tidy up after yourself:
x.free;
y.free;
b.close; b.free;
c.close; c.free;
m.finish;
n.finish;