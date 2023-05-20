:- consult(scene),
   %consult(filewrite),
   consult(pixloop),
   consult(mathstuff),
   consult(cammarch),
   consult(lightmarch),
   consult(reflectmarch).

main :-
    open("720p4withlightlight.bmp", write, Stream, [encoding(octet)]),
    write_header(Stream),
    write_pixels(Stream),
    close(Stream),
    retractall(pixelcolor(_,_)),
    retractall(generated(_)).


write_header(Stream) :-
    header(Header),
    write_loop(Stream, Header).

write_pixels(Stream) :-
    startx(X),
    starty(Y),
    position(camera, [CX, CY, CZ]),
    write("Starting threads"),nl,
    %thread_create(threaded_pix_loop(-128, -128, -96, CX, CY, CZ), T1, [detached(false)]),
    thread_create(threaded_pix_loop(-640, -360, -64, CX, CY, CZ), T2, [detached(true)]),
    thread_create(threaded_pix_loop(-638, -360, -32, CX, CY, CZ), T3, [detached(true)]),
    thread_create(threaded_pix_loop(-636, -360, 0, CX, CY, CZ), T4, [detached(true)]),
    thread_create(threaded_pix_loop(-634, -360, 32, CX, CY, CZ), T5, [detached(true)]),
    thread_create(threaded_pix_loop(-640, -358, 64, CX, CY, CZ), T6, [detached(true)]),
    thread_create(threaded_pix_loop(-638, -358, 96, CX, CY, CZ), T7, [detached(true)]),
    thread_create(threaded_pix_loop(-640, 0, 128, CX, CY, CZ), T8, [detached(true)]),
    %thread_create(threaded_pix_loop(-128, -68, 128, CX, CY, CZ), T9, [detached(false)]),
    %thread_create(threaded_pix_loop(-128, -64, 128, CX, CY, CZ), T10, [detached(false)]),
    %thread_create(threaded_pix_loop(-128, -60, 128, CX, CY, CZ), T11, [detached(false)]),
    %thread_join(T1, _),
    write("threads done, making image"),nl,
    pix_loop(X, Y, Stream, CX, CY, CZ).
    %thread_join(T2, _),
    %thread_join(T3, _),
    %thread_join(T4, _),
    %thread_join(T5, _),
    %thread_join(T6, _),
    %thread_join(T7, _),
    %thread_join(T8, _).
    %thread_join(T9, _),
    %thread_join(T10, _),
    %thread_join(T11, _).


header(Header) :-
    Header =
    [66, 77,  117, 255, 2,  0,   0, 0,  0,  0,
     54,  0,   0,  0, 40,  0,   0, 0,  0,  5,
      0,  0,   208,  2,  0,  0,   1, 0, 24,  0,
      0,  0,   0,  0,  0,  0,   0, 0, 35, 46,
      0,  0,  35, 46,  0,  0,   0, 0,  0,  0,
      0,  0,   0,  0].

startx(-640).
starty(-360).

:- dynamic generated/1.













