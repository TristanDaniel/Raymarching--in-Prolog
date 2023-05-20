offset_march(StartX, StartY, StartZ, CurX, CurY, CurZ, Dist, NewX, NewY, NewZ) :-
    get_dist(StartX, StartY, StartZ, CurX, CurY, CurZ, 0, CurDist),
    OffsetX = CurX - StartX,
    OffsetY = CurY - StartY,
    OffsetZ = CurZ - StartZ,
    move_across_ray(OffsetX, OffsetY, OffsetZ, CurDist, Dist, TempX, TempY, TempZ),
    NewX is TempX + StartX,
    NewY is TempY + StartY,
    NewZ is TempZ + StartZ.

move_across_ray(X, Y, Z, OldDist, Delta, NewX, NewY, NewZ) :-
    dist_ratio(OldDist, Delta, DistR),
    NewZ = Z * DistR,
    NewY = Y * DistR,
    NewX = X * DistR.

march_reflect_start(Obj, CurX, CurY, CurZ, RefColor) :-
    get_pos(Obj, CurX, CurY, CurZ, OX, OY, OZ),
    ref_fake_slope(OX, OY, OZ, CurX, CurY, CurZ, SX, SY, SZ),
    march_reflect(CurX, CurY, CurZ, SX, SY, SZ, RefColor).
march_reflect(SX, SY, SZ, CX, CY, CZ, RefColor) :-
    get_closest([CX, CY, CZ], Obj, Dist, other),
    (   (Dist =< 0.1,
         march_to_light_start(CX, CY, CZ, HitLight),
         march_to_light_start(SX, SY, SZ, HitLight2),
         color(Obj, [OB, OG, OR]),
         HitLight = [LB, LG, LR],
         HitLight2 = [LB2, LG2, LR2],
         %SB is (OB + LB) // 2,
         %SG is (OG + LG) // 2,
         %SR is (OR + LR) // 2,
         SB is round(OB * (((LB + LB2) / 2) / 255)),
         SG is round(OG * (((LG + LG2) / 2) / 255)),
         SR is round(OR * (((LR + LR2) / 2) / 255)),
         RefColor = [SB, SG, SR],!);
    (offset_march(SX, SY, SZ, CX, CY, CZ, Dist, NX, NY, NZ),
     march_reflect(SX, SY, SZ, NX, NY, NZ, RefColor))).


