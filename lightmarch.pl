%new light plan:
%for each point, determine if light is impacting it.
%for each light source,
% check if point is too far from light. if so, light is not impacting;
% if light is within reach (luminance), determine light color and
% strength;
% if object is obstrucing light source, light is not impacting.
%if no light is impacting, make very dark.
%if light is impacting, then,
% determine total light impact.
%  modify light color based on strength, and average.
% for each wavelength (r/g/b), find proportion out of full 255.
% multiply wavelength of object color with light strength.
% add minimum light base to prevent full black and to balance with 0
% impact areas.
%  minimum base is "very dark". likely object wavelength / 8.

march_to_light_start(StartX, StartY, StartZ, [BCB, BCG, BCR], FinalColor) :-
    lights(L),
    MinB is BCB / 4,
    MinG is BCG / 4,
    MinR is BCR / 4,
    light_loop(L, StartX, StartY, StartZ, 0, [0, 0, 0], LightColor),
    LightColor = [LCB, LCG, LCR],
    B is round((BCB * (LCB / 255)) + MinB),
    G is round((BCG * (LCG / 255)) + MinG),
    R is round((BCR * (LCR / 255)) + MinR),
    FinalColor = [B, G, R],!.

light_loop([], _, _, _, 0, _, [0, 0, 0]) :- !.
light_loop([], _, _, _, Impacted, [TB, TG, TR], LightColor) :-
    LCB is TB,% / Impacted,
    LCG is TG,% / Impacted,
    LCR is TR,% / Impacted,
    LightColor = [LCB, LCG, LCR], !.
light_loop([Light|T], StartX, StartY, StartZ, Impacted, TotalLight, LightColor) :-
    get_pos(Light, StartX, StartY, StartZ, LightX, LightY, LightZ),
    luminance(Light, Lum),
    get_dist(StartX, StartY, StartZ, LightX, LightY, LightZ, 0, DL),
    DistToLight is DL,
    ((Lum =< DistToLight,
      light_loop(T, StartX, StartY, StartZ, Impacted, TotalLight, LightColor),!);
     (march_to_light(Light, StartX, StartY, StartZ, LightImpacts, LC),
      ((LightImpacts = 0,
       light_loop(T, StartX, StartY, StartZ, Impacted, TotalLight, LightColor),!);
       (NewImpact is Impacted + 1,
        TotalLight = [TB, TG, TR],
        LC = [LB, LG, LR],
        NB is TB + LB,
        NG is TG + LG,
        NR is TR + LR,
        light_loop(T, StartX, StartY, StartZ, NewImpact, [NB, NG, NR], LightColor),!)))).

march_to_light(Light, StartX, StartY, StartZ, Impacted, LightColor) :-
    get_pos(Light, StartX, StartY, StartZ, LX, LY, LZ),
    fake_slope(StartX, StartY, StartZ, LX, LY, LZ, SX, SY, SZ),
    march_to_light_cont(Light, StartX, StartY, StartZ, SX, SY, SZ, 1, Impacted, LightColor).

march_to_light_cont(Light, StartX, StartY, StartZ, CurX, CurY, CurZ, DistMarched, Impacted, LightColor) :-
    get_closest([CurX, CurY, CurZ], _, Dist, light),
    closest_with_light(Light, CurX, CurY, CurZ, Dist, MinDist),
    luminance(Light, Lum),
    ((at_light(CurX, CurY, CurZ, Light),
      color(Light, [LB, LG, LR]),
      DistMarched < Lum,
      LumRatio is 1 - (DistMarched / Lum),
      ALB = (LB * LumRatio),
      ALG = (LG * LumRatio),
      ALR = (LR * LumRatio),
      Impacted = 1,
      LightColor = [ALB, ALG, ALR],!);
     ((Dist =< 0.01; Lum =< DistMarched),
       Impacted = 0,
       LightColor = [0, 0, 0],!);
     (offset_march(StartX, StartY, StartZ, CurX, CurY, CurZ, MinDist, NewX, NewY, NewZ),
      NewDist is DistMarched + MinDist,
      march_to_light_cont(Light, StartX, StartY, StartZ, NewX, NewY, NewZ, NewDist, Impacted, LightColor))).




%march_to_light_start(StartX, StartY, StartZ, HitLight, BaseColor) :-
%    lights(L),
%    BaseColor = [BCB, BCG, BCR],
%    AB is BCB / 4,
%    AG is BCG / 4,
%    AR is BCR / 4,
%    light_march_loop(L, StartX, StartY, StartZ, [AB, AG, AR],
%    HitLight).

% march_to_light_cont(Light, StartX, StartY, StartZ, CurX, CurY, CurZ, DistMarched, HitLight) :-
%    get_closest([CurX, CurY, CurZ], _, Dist, light),
%    closest_with_light(Light, CurX, CurY, CurZ, Dist, MinDist),
%    (   (at_light(CurX, CurY, CurZ, Light),
%         color(Light, [LB, LG, LR]),
%         luminance(Light, Lum),
%         DistMarched < Lum,
%         LumRatio is 1 - (DistMarched / Lum),
%         ALB = (LB * LumRatio),
%         ALG = (LG * LumRatio),
%         ALR = (LR * LumRatio),
%         HitLight = [ALB, ALG, ALR]);
%        ((Dist =< 0.01;
%         (luminance(Light, Lum),
%           Lum =< DistMarched)),
%         HitLight = [0, 0, 0]);
%        (offset_march(StartX, StartY, StartZ, CurX, CurY, CurZ,
%        MinDist, NewX, NewY, NewZ),
%         NewDist is DistMarched + MinDist,
%         march_to_light_cont(Light, StartX, StartY, StartZ, NewX, NewY,
%         NewZ, NewDist, HitLight))).

%march_to_light(Light, StartX, StartY, StartZ, HitLight) :-
%    get_pos(Light, StartX, StartY, StartZ, LX, LY, LZ),
%    fake_slope(StartX, StartY, StartZ, LX, LY, LZ, SX, SY, SZ),
%    march_to_light_cont(Light, StartX, StartY, StartZ, SX, SY, SZ, 1,
%    HitLight).

%light_march_loop([], _, _, _, TempLight, HitLight):-
%    TempLight = [HB, HG, HR],
    %B is floor(HB),
    %G is floor(HG),
    %R is floor(HR),
%    HitLight = [HB, HG, HR],!.
%light_march_loop([H|T], StartX, StartY, StartZ, TempLight, HitLight) :-
%    get_pos(H, StartX, StartY, StartZ, LX, LY, LZ),
%    luminance(H, Lum),
%    get_dist(StartX, StartY, StartZ, LX, LY, LZ, 0, DistToLight),
%    DL is DistToLight,
%   ((Lum =< DL,
%     TempLight = [NB, NG, NR],!);
%    (march_to_light(H, StartX, StartY, StartZ, HitLight2),
%     HitLight2 = [HLB, HLG, HLR],
%    ((nonvar(HLB),
%      nonvar(HLG),
%      nonvar(HLR),
%      TempLight = [TLB, TLG, TLR],
%      NB = (HLB + TLB) / 2,
%      NG = (HLG + TLG) / 2,
%      NR = (HLR + TLR) / 2,!);
%     (TempLight = [NB, NG, NR])))),
%     light_march_loop(T, StartX, StartY, StartZ, [NB, NG, NR],
%     HitLight).














