position(camera, [0, 0, -650]).
position(floor, [_, -364, _]).
position(ceiling, [_, 364, _]).
position(lwall, [644, _, _]).
position(rwall, [-644, _, _]).
position(bwall, [_, _, 644]).
position(fourthwall, [_, _, 0]).
position(sphere1, [550, -200, 500]).
position(sphere2, [-65, 50, 100]).
position(sphere3, [40, -5, 322]).
position(light1, [30, 80, 2]).
position(light2, [-400, -300, 600]).

elems(fromcamera, List) :-
    List = [floor, ceiling, lwall, rwall,
            bwall, sphere1, sphere2, sphere3].
elems(other, List) :-
    List = [floor, ceiling, lwall, rwall,
            bwall, fourthwall, sphere1, sphere2, sphere3].

lights(List) :-
    List = [light1, light2].

radius(sphere1, 150).
radius(sphere2, 85).
radius(sphere3, 75).
radius(floor, 0).
radius(ceiling, 0).
radius(lwall, 0).
radius(rwall, 0).
radius(bwall, 0).
radius(fourthwall, 0).
radius(light1, 0).
radius(light2, 0).

luminance(light1, 950).
luminance(light2, 320).

color(sphere1, [0, 255, 50]). %B, G, R. Green
color(sphere2, [255, 100, 0]). %Blue
color(sphere3, [55, 0, 248]). %Purple
color(floor, [255, 255, 255]). %Red
color(ceiling, [255, 255, 255]).
color(lwall, [138, 86, 255]). %Pinkish red
color(rwall, [138, 86, 255]).
color(bwall, [0, 182, 239]). %Different purple
color(fourthwall, [219, 182, 0]).
color(light1, [500, 500, 500]).
color(light2, [255, 255, 0]).

pixelcolor([-1000,-1000,-1000],[0, 0, 0]).
:- dynamic pixelcolor/2.

%material(floor, reflective).
%material(ceiling, reflective).
%material(lwall, reflective).
%material(rwall, reflective).
%material(bwall, reflective).
%material(fourthwall, reflective).
material(sphere1, reflective).
material(_, flat).

