(
~recBufLen = 8;

~recbuf_a.free;~recbuf_b.free;~recbuf_c.free;~recbuf_d.free;~recbuf_e.free;
~recbuf_a = Buffer.alloc(s, s.sampleRate * ~recBufLen, 2);
~recbuf_b = Buffer.alloc(s, s.sampleRate  * ~recBufLen, 2);
~recbuf_c = Buffer.alloc(s, s.sampleRate  * ~recBufLen, 2);
~recbuf_d = Buffer.alloc(s, s.sampleRate  * ~recBufLen, 2);
~recbuf_e = Buffer.alloc(s, s.sampleRate  * ~recBufLen, 2);

SynthDef(\rec,
    {
        arg bufnum = 0, inbus = 100, over = 1, prev = 0.3, gate = 1;
        var sig, env;
        sig = In.ar(inbus, 2);
        env = EnvGen.kr(Env.linen(attackTime: 0.01, sustainTime: ~recBufLen*2 - 0.02, releaseTime: 0.01), gate, doneAction: 2);
        RecordBuf.ar(sig*env, bufnum, recLevel: over, preLevel: prev, loop: 1);

}).add;

SynthDef(\play,
    {
        arg bufnum = 0, out = 100, pan = 0, amp = 1, gate = 1;
        var sig, env;
        sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), loop: 1, doneAction: 0);
        Out.ar(out, Pan2.ar(sig, pan, amp));

}).add;

)