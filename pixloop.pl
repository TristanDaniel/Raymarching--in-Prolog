write_loop(_, []):-!.
write_loop(Stream, [H|T]) :-
   ((H >= 0, H < 256,
    put_byte(Stream, H),!);
    (H < 0,put_byte(Stream, 0),!);
    (put_byte(Stream, 255))),
    write_loop(Stream, T).

pix_loop(640, 360, _, _, _, _):-!.
pix_loop(CPX, CPY, Stream, CamX, CamY, CamZ) :-
   (CPX =:= 640 -> (NX = -640, NY is CPY + 1, write(CPY),nl);
   (march_to_point(CamX, CamY, CamZ, CPX, CPY, 0, PixelColor, 0),
    write_loop(Stream, PixelColor),
    NX is CPX + 1,
    NY = CPY)),
   pix_loop(NX, NY, Stream, CamX, CamY, CamZ).

threaded_pix_loop(_, 360, _, _, _, _) :- !.
%threaded_pix_loop(-128, Y, Y, _, _, _):-!.
threaded_pix_loop(CPX, CPY, FinalY, CamX, CamY, CamZ) :-
   (generated(CPY),
    NY is CPY + 1,
    threaded_pix_loop(-640, NY, FinalY, CamX, CamY, CamZ),!);
   (pixelcolor([CPX, CPY, 0], _),
    NX is CPX + 1,
    threaded_pix_loop(NX, CPY, FinalY, CamX, CamY, CamZ),!);
   (CPY < 360,
   ((CPX > 639, NX = -640, NY is CPY + 2, asserta(generated(CPY)), write(CPY),nl, !);
   (march_to_point(CamX, CamY, CamZ, CPX, CPY, 0, _, 0),
   NX is CPX + 2,
   NY = CPY)),
   threaded_pix_loop(NX, NY, FinalY, CamX, CamY, CamZ)).



