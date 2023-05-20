march_to_light_start(StartX, StartY, StartZ, HitLight) :-
    lights(L),
    light_march_loop(L, StartX, StartY, StartZ, [122.5, 122.5, 122.5], HitLight).

march_to_light_cont(Light, StartX, StartY, StartZ, CurX, CurY, CurZ, DistMarched, HitLight) :-
    get_closest([CurX, CurY, CurZ], _, Dist, other),
    closest_with_light(Light, CurX, CurY, CurZ, Dist, MinDist),
    (   (at_light(CurX, CurY, CurZ, Light),
         color(Light, [LB, LG, LR]),
         luminance(Light, Lum),
         DistMarched < Lum,
         LumRatio is abs(1 - (min((DistMarched * 1),Lum) / Lum)),
         ALB = (LB * LumRatio),
         ALG = (LG * LumRatio),
         ALR = (LR * LumRatio),
         HitLight = [ALB, ALG, ALR]);
        ((Dist =< 0.01;
         (luminance(Light, Lum),
           Lum =< DistMarched)),
         HitLight = [_, _, _]);
        (offset_march(StartX, StartY, StartZ, CurX, CurY, CurZ, MinDist, NewX, NewY, NewZ),
         NewDist is DistMarched + MinDist,
         march_to_light_cont(Light, StartX, StartY, StartZ, NewX, NewY, NewZ, NewDist, HitLight))).

march_to_light(Light, StartX, StartY, StartZ, HitLight) :-
    position(Light, [LX, LY, LZ]),
    fake_slope(StartX, StartY, StartZ, LX, LY, LZ, SX, SY, SZ),
    march_to_light_cont(Light, StartX, StartY, StartZ, SX, SY, SZ, 1, HitLight).

light_march_loop([], _, _, _, TempLight, HitLight):-
    TempLight = [HB, HG, HR],
    %B is floor(HB),
    %G is floor(HG),
    %R is floor(HR),
    HitLight = [HB, HG, HR],!.
light_march_loop([H|T], StartX, StartY, StartZ, TempLight, HitLight) :-
    position(H, [LX, LY, LZ]),
    luminance(H, Lum),
    get_dist(StartX, StartY, StartZ, LX, LY, LZ, 0, DistToLight),
    DL is DistToLight,
   ((Lum =< DL,
     TempLight = [NB, NG, NR],!);
    (march_to_light(H, StartX, StartY, StartZ, HitLight2),
     HitLight2 = [HLB, HLG, HLR],
    ((nonvar(HLB),
      nonvar(HLG),
      nonvar(HLR),
      TempLight = [TLB, TLG, TLR],
      NB = (HLB + TLB) / 2,
      NG = (HLG + TLG) / 2,
      NR = (HLR + TLR) / 2,!);
     (TempLight = [NB, NG, NR])))),
     light_march_loop(T, StartX, StartY, StartZ, [NB, NG, NR], HitLight).
