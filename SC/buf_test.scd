~recbuf_a.play;
~recbuf_b.play;
~recbuf_c.play;
~recbuf_d.play;
~recbuf_e.play;
~recbuf_b = Buffer.alloc(s, s.sampleRate  * bufLen, 2);
~recbuf_c = Buffer.alloc(s, s.sampleRate  * bufLen, 2);
~recbuf_d = Buffer.alloc(s, s.sampleRate  * bufLen, 2);
~recbuf_e = Buffer.alloc(s, s.sampleRate  * bufLen, 2);



(
~grp_rec = Group.new(s);
~grp = Group.new(s).addAfterMsg(~grp_rec);

~mixer = Synth(\mixer, [\out, 0, \amp, 0.6,
    \amp1, 1, \amp2, 0.1, \amp3, 0.1, \amp4, 0.44, \amp5, 0.3, \amp6, 0.5,
    \pan1, 0, \pan2, -0.2, \pan3, 0.2, \pan4, 0, \pan5, 0, \pan6, 0,
    \ths , 0.5, \slB, 1, \slA, 1, \clpTime, 0.01, \relTime, 0.1
]);


a = Synth(\bufRead, [\out, 100, \loop, 1, \bufnum, ~v_a]);


~rec = Synth.after(~mixer, \rec, [\inbus, 100, \bufnum, ~recbuf_a, \over, 1, \prev, 0]);


b = Synth(\rec, [\inbus, 100, \bufnum, ~recbuf_a, \over, 1, \prev, 0]);

c = Synth(\play, [\bufnum, ~recbuf_a]);

)

~recbuf_a.play;
