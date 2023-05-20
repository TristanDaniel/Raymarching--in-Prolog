get_dist(X1, Y1, Z1, X2, Y2, Z2, R, Dist) :-
    Dist = sqrt((X1-X2)*(X1-X2) + (Y1-Y2)*(Y1-Y2) + (Z1-Z2)*(Z1-Z2)) - R.

dist_loop([], _, _, _, OutList, Min, MinIdx) :-
    min_list(OutList, Min),
    nth0(MinIdx, OutList, Min),!.
dist_loop([H|T], PointX, PointY, PointZ, OutList, Min, MinIdx) :-
    get_pos(H, PointX, PointY, PointZ, X2, Y2, Z2),
    radius(H, R),
    get_dist(PointX, PointY, PointZ, X2, Y2, Z2, R, Dist),
    D is Dist,
    append(OutList, [D], OL2),
    dist_loop(T, PointX, PointY, PointZ, OL2, Min, MinIdx).

get_pos(P, X1, Y1, Z1, X2, Y2, Z2) :-
    position(P, [X3, Y3, Z3]),
    ((nonvar(X3),X2 is X3,!);X2 is X1),
    ((nonvar(Y3),Y2 is Y3,!);Y2 is Y1),
    ((nonvar(Z3),Z2 is Z3,!);Z2 is Z1).

%Signed distance function
%Returns the distance to the edge of the nearest object
get_closest(CurPos, Obj, Dist, Flag) :-
    elems(Flag, Elems),
    CurPos = [X, Y, Z],
    dist_loop(Elems, X, Y, Z, [], Dist, MinIdx),
    nth0(MinIdx, Elems, Obj).

dist_ratio(Dist, ToAdd, DistR) :-
    DistR is (Dist + ToAdd) / Dist.

fake_slope(X1, Y1, Z1, X2, Y2, Z2, SX, SY, SZ) :-
    get_dist(X1, Y1, Z1, X2, Y2, Z2, 0, Dist),
    TX = (X2 - X1) / Dist,
    TY = (Y2 - Y1) / Dist,
    TZ = (Z2 - Z1) / Dist,
    SX is X1 + TX,
    SY is Y1 + TY,
    SZ is Z1 + TZ.
ref_fake_slope(X1, Y1, Z1, X2, Y2, Z2, SX, SY, SZ) :-
    get_dist(X1, Y1, Z1, X2, Y2, Z2, 0, Dist),
    TX = (X2 - X1) / Dist,
    TY = (Y2 - Y1) / Dist,
    TZ = (Z2 - Z1) / Dist,
    SX is X2 + TX,
    SY is Y2 + TY,
    SZ is Z2 + TZ.

at_light(X, Y, Z, Light) :-
    position(Light, [LX, LY, LZ]),
    get_dist(X, Y, Z, LX, LY, LZ, 0, Dist),
    DE is Dist,
    DE =< 1.

closest_with_light(Light, X, Y, Z, Dist, MinDist) :-
    position(Light, [LX, LY, LZ]),
    get_dist(X, Y, Z, LX, LY, LZ, 0, LDist),
    min_list([Dist, LDist], MinDist).
