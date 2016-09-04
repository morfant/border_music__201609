//Buffer read

(
~v_song.free;~v_laughing.free;
~v_laughing = Buffer.read(s, "/Users/giy/Desktop/border_music/voice/laugh_mono.wav");

~voice = Array.newClear(5);
5.do{| i |
    ~voice[i].free;
    ~voice[i] = Buffer.read(s, "/Users/giy/Desktop/border_music/voice/v"++i++"_mono.wav");
};


~v_song = Buffer.read(s, "/Users/giy/Desktop/border_music/voice/song_mono.wav", action: {
    l = ~v_song.numFrames/5; //length of a part.
    ~v_song_part = Array.newClear(5);

    5.do{| i |
        ~v_song_part[i].free;
        ~v_song_part[i] = Buffer.read(s, "/Users/giy/Desktop/border_music/voice/song_mono.wav", l * i, l * (i+1) );
    };

});

~number = Array.newClear(11);
11.do{| i |
    ~number[i].free;
    ~number[i] = Buffer.read(s, "/Users/giy/Desktop/border_music/voice/"++i++"_mono.wav");
};

~number_han = Array.newClear(11);
11.do{| i |
    ~number_han[i].free;
    ~number_han[i] = Buffer.read(s, "/Users/giy/Desktop/border_music/voice/han_"++i++"_mono.wav");
};




SynthDef(\bufRead,
	{|out = 102, bufnum = 0, gate = 1, amp = 1, pan = 0, rate = 1, loop = 1, st = 0, dn = 0 |
        var sig;
        sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, startPos: st, loop: loop, doneAction: dn);
        Out.ar(out, Pan2.ar(sig, pan, amp));
}).add;


SynthDef(\bufReadEnv,
	{|out = 108, bufnum = 0, gate = 1, amp = 1, pan = 0, rate = 1, loop = 0, st = 0, dn = 2 |
        var sig, env, pansig;
		sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, startPos: st, loop: loop, doneAction: dn);
        env = EnvGen.kr(Env.perc(0.4, 0.4, curve: 2), gate);
        pansig = LFNoise0.kr(4);
        Out.ar(out, Pan2.ar(sig*env, pansig, amp));
}).add;


)



/*
//Test
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number[0]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number[1]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number[2]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number[3]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number[4]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number[5]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number[6]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number[7]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number[8]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number[9]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number[10]]);

a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number_han[0]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number_han[1]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number_han[2]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number_han[3]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number_han[4]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number_han[5]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number_han[6]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number_han[7]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number_han[8]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number_han[9]]);
a = Synth(\bufReadEnv, [\out, 0, \bufnum, ~number_han[10]]);


~v_a.play;
~v_b.play;
~v_c.play;
~v_d.play;
~v_e.play;
~v_song.play;

a = Synth(\bufRead, [\out, 0, \loop, 1, \bufnum, ~v_a]);
a = Synth(\bufRead, [\out, 0, \loop, 1, \bufnum, ~v_b]);
a = Synth(\bufRead, [\out, 0, \loop, 1, \bufnum, ~v_c]);
a = Synth(\bufRead, [\out, 0, \loop, 1, \bufnum, ~v_d]);
a = Synth(\bufRead, [\out, 0, \loop, 0, \bufnum, ~v_e, \dn, 2]);
a = Synth(\bufRead, [\out, 0, \loop, 1, \bufnum, ~v_song]);


~v_song_parts[0].play
~v_song_parts[1].play
~v_song_parts[2].play
~v_song_parts[3].play
~v_song_parts[4].play

*/