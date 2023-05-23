write_loop(_, []):-!.
write_loop(Stream, [H|T]) :-
   ((H >= 0, H < 256,
    put_byte(Stream, H),!);
    (H < 0,put_byte(Stream, 0),!);
    (put_byte(Stream, 255))),
    write_loop(Stream, T).

pix_loop(640, 360, _, _, _, _):-!.
pix_loop(CPX, CPY, Stream, CamX, CamY, CamZ) :-
   (CPX =:= 640 -> (NX = -640, NY is CPY + 1, PP is CPY + 1, asserta(generated(CPY)),
                    asserta(generated(PP)), write(CPY), write("c"),nl);
   (XM is CPX - 1, XP is CPX + 1,
    YM is CPY - 1, YP is CPY + 1,
    asserta(generating(CPX, CPY)), asserta(generating(XM, CPY)), asserta(generating(XP, CPY)),
    asserta(generating(CPX, YM)), asserta(generating(XM, YM)), asserta(generating(XP, YM)),
    asserta(generating(CPX, YP)), asserta(generating(XM, YP)), asserta(generating(XP, YP)),
    march_to_point(CamX, CamY, CamZ, CPX, CPY, 0, PixelColor, 0),
    %retract(generating(CPX, CPY)), retract(generating(XM, CPY)), retract(generating(XP, CPY)),
    %retract(generating(CPX, YM)), retract(generating(XM, YM)), retract(generating(XP, YM)),
    %retract(generating(CPX, YP)), retract(generating(XM, YP)), retract(generating(XP, YP)),
    write_loop(Stream, PixelColor),
    NX is CPX + 1,
    NY = CPY)),
   pix_loop(NX, NY, Stream, CamX, CamY, CamZ).

threaded_pix_loop(_, CPY, _, _, _, _) :- CPY > 359,!.
%threaded_pix_loop(-128, Y, Y, _, _, _):-!.
threaded_pix_loop(CPX, CPY, FinalY, CamX, CamY, CamZ) :-
   (generated(CPY),!,
    NY is CPY + 2,
    threaded_pix_loop(-640, NY, FinalY, CamX, CamY, CamZ),!);
   (pixelcolor([CPX, CPY, 0], _),
    NX is CPX + 1,
    threaded_pix_loop(NX, CPY, FinalY, CamX, CamY, CamZ),!);
   (generating(CPX, CPY),
    NX is CPX + 2,
    threaded_pix_loop(NX, CPY, FinalY, CamX, CamY, CamZ),!);
   (CPY < 360,
   ((CPX > 639, NX = -640, NY is CPY + 3, PP is CPY + 1, PM is CPY - 1,
     asserta(generated(CPY)), asserta(generated(PP)), asserta(generated(PM)), write(CPY),nl, !);
   (XM is CPX - 1, XP is CPX + 1,
    YM is CPY - 1, YP is CPY + 1,
    asserta(generating(CPX, CPY)), asserta(generating(XM, CPY)), asserta(generating(XP, CPY)),
    asserta(generating(CPX, YM)), asserta(generating(XM, YM)), asserta(generating(XP, YM)),
    asserta(generating(CPX, YP)), asserta(generating(XM, YP)), asserta(generating(XP, YP)),
    march_to_point(CamX, CamY, CamZ, CPX, CPY, 0, _, 0),
    %retract(generating(CPX, CPY)), retract(generating(XM, CPY)), retract(generating(XP, CPY)),
    %retract(generating(CPX, YM)), retract(generating(XM, YM)), retract(generating(XP, YM)),
    %retract(generating(CPX, YP)), retract(generating(XM, YP)), retract(generating(XP, YP)),
    NX is CPX + 2,
    NY = CPY)),
   threaded_pix_loop(NX, NY, FinalY, CamX, CamY, CamZ),!).



