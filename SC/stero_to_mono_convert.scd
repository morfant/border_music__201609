(//Read stereo file to buffer
~number = Array.newClear(11);
11.do{| i |
    ~number[i].free;
    ~number[i] = Buffer.read(s, "/Users/giy/Desktop/border_music/voice/"++i++".wav");
};

~number_han = Array.newClear(11);
11.do{| i |
    ~number_han[i].free;
    ~number_han[i] = Buffer.read(s, "/Users/giy/Desktop/border_music/voice/han_"++i++".wav");
};

~voice = Array.newClear(5);
5.do{| i |
    ~voice[i].free;
    ~voice[i] = Buffer.read(s, "/Users/giy/Desktop/border_music/voice/v"++i++".wav");
};

~v_song = Buffer.read((s, "/Users/giy/Desktop/border_music/voice/song.wav");
)

(//Write as mono file
11.do{| i |
    ~number[i].loadToFloatArray(action: { arg array;
        a = array;
        d = Buffer.loadCollection(s, a.unlace(2).sum*0.5);
        d.write("/Users/giy/Desktop/border_music/voice/"++i++"_mono.wav", "wav", "int16");
    });
};

11.do{| i |
    ~number_han[i].loadToFloatArray(action: { arg array;
        a = array;
        d = Buffer.loadCollection(s, a.unlace(2).sum*0.5);
        d.write("/Users/giy/Desktop/border_music/voice/han_"++i++"_mono.wav", "wav", "int16");
    });
};

5.do{| i |
    ~voice[i].loadToFloatArray(action: { arg array;
        a = array;
        d = Buffer.loadCollection(s, a.unlace(2).sum*0.5);
        d.write("/Users/giy/Desktop/border_music/voice/v"++i++"_mono.wav", "wav", "int16");
    });
};

~v_song.loadToFloatArray(action: { arg array;
        a = array;
        d = Buffer.loadCollection(s, a.unlace(2).sum*0.5);
    d.write("/Users/giy/Desktop/border_music/voice/song_mono.wav", "wav", "int16");
    });

)
