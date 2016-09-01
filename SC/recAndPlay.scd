(
var bufLen = 8;
~buf_a.free;~buf_b.free;~buf_c.free;~buf_d.free;~buf_e.free;
~buf_a = Buffer.alloc(s, s.sampleRate * bufLen, 2);
~buf_b = Buffer.alloc(s, s.sampleRate  * bufLen, 2);
~buf_c = Buffer.alloc(s, s.sampleRate  * bufLen, 2);
~buf_d = Buffer.alloc(s, s.sampleRate  * bufLen, 2);
~buf_e = Buffer.alloc(s, s.sampleRate  * bufLen, 2);

SynthDef(\rec,
    {
        arg bufnum = 0, inbus = 100, over = 1, prev = 0.3, gate = 1;
        var sig, env;
        sig = In.ar(inbus, 2);
        env = EnvGen.kr(Env.linen(attackTime: 0.01, sustainTime: 9.98, releaseTime: 0.01), gate, doneAction: 2);
        RecordBuf.ar(sig*env, bufnum, recLevel: over, preLevel: prev, loop: 1);

}).add;

SynthDef(\play,
    {
        arg bufnum = 0, out = 0, pan = 0, amp = 1, gate = 1;
        var sig;
        sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), loop: 1, doneAction: 0);
        Out.ar(out, Pan2.ar(sig, pan, amp));

}).add;

)