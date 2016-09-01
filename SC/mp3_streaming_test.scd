
// Let's read in an internet radio stream and warp it a bit.
// First we need a synthdef:
s.boot;
(
SynthDef("help_mp3_01", { |bufnum = 0|
    var son, wibble;
    son = DiskIn.ar(2, bufnum);
    //     wibble = LFPar.kr(0.1).range(0.5, 2.0);
    //     son = PitchShift.ar(son, pitchRatio: wibble);
    Out.ar(0, son);
}).load(s);
)

// Now let's create the MP3 object and cue it into a Buffer.

// Choose one of these two:
// (a) a stream URL - note the use of the second argument to indicate a remote stream
m = MP3("http://stream.resonance.fm:8000/resonance-extra", \readurl);

m.start;
// Now you can use it almost like any other file, by reading from m.fifo
b = Buffer.cueSoundFile(s, m.fifo, 0, 2);
x = Synth("help_mp3_01", [\bufnum, b.bufnum], addAction:\addToTail);
m.playing;
// You can stop and restart the piping (with a bit of a delay) - note what happens
m.stop;
m.playing;
m.restart;
m.playing;
// Please remember to tidy up after yourself:
x.free;
b.close; b.free;
m.finish;