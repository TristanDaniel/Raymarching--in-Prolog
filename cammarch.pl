march_cont(CurX, CurY, CurZ, PixColor) :-
    get_closest([CurX, CurY, CurZ], Obj, Dist, fromcamera),
    (   (   Dist =< 0.1,
            ((material(Obj, reflective),
             march_reflect_start(Obj, CurX, CurY, CurZ, RefColor),
             PixColor = RefColor,!);
            (color(Obj, [CX, CY, CZ]),
             march_to_light_start(CurX, CurY, CurZ, HitLight),
             HitLight = [LCX, LCY, LCZ],
             (%(AAFlag = 0,
             %  position(camera, [CamX, CamY, CamZ]),
             %  LeftX is CurX - 1,
             %  RightX is CurX + 1,
             %  UpY is CurY + 1,
             %  DownY is CurY - 1,
             %  (
             %      pixelcolor([LeftX, CurY, CurZ], [LCB, LCG, LCR]);
             %      march_to_point(CamX, CamY, CamZ, LeftX, CurY, CurZ, [LCB, LCG, LCR], 1)),
             %  (
             %      pixelcolor([RightX, CurY, CurZ], [RCB, RCG, RCR]);
             %      march_to_point(CamX, CamY, CamZ, RightX, CurY, CurZ, [RCB, RCG, RCR], 1)),
             %  (
             %      pixelcolor([LeftX, UpY, CurZ], [LUCB, LUCG, LUCR]);
             %      march_to_point(CamX, CamY, CamZ, LeftX, UpY, CurZ, [LUCB, LUCG, LUCR], 1)),
             %  (
             %      pixelcolor([RightX, UpY, CurZ], [RUCB, RUCG, RUCR]);
             %      march_to_point(CamX, CamY, CamZ, RightX, UpY, CurZ, [RUCB, RUCG, RUCR], 1)),
             %  (
             %      pixelcolor([LeftX, DownY, CurZ], [LDCB, LDCG, LDCR]);
             %      march_to_point(CamX, CamY, CamZ, LeftX, DownY, CurZ, [LDCB, LDCG, LDCR], 1)),
             %  (
             %      pixelcolor([RightX, DownY, CurZ], [RDCB, RDCG, RDCR]);
             %      march_to_point(CamX, CamY, CamZ, RightX, DownY, CurZ, [RDCB, RDCG, RDCR], 1)),
             %  (
             %      pixelcolor([CurX, UpY, CurZ], [UCB, UCG, UCR]);
             %      march_to_point(CamX, CamY, CamZ, CurX, UpY, CurZ, [UCB, UCG, UCR], 1)),
             %  (
             %      pixelcolor([CurX, DownY, CurZ], [DCB, DCG, DCR]);
             %      march_to_point(CamX, CamY, CamZ, CurX, DownY, CurZ, [DCB, DCG, DCR], 1)),
             %  AAB is round(((CX + LCB + RCB + UCB + DCB + LUCB + RUCB + LDCB + RDCB) / 8) * (LCX / 255)),
             %  AAG is round(((CY + LCG + RCG + UCG + DCG + LUCG + RUCG + LDCG + RDCG) / 8) * (LCY / 255)),
             %  AAR is round(((CZ + LCR + RCR + UCR + DCR + LUCR + RUCR + LDCR + RDCR) / 8) * (LCZ / 255)),
             %  PixColor = [AAB, AAG, AAR],
             %  asserta(pixelcolor([CurX, CurY, CurZ], PixColor)),
             %  !);
            %CLX is (CX + LCX) // 2,
            %CLY is (CY + LCY) // 2,
            %CLZ is (CZ + LCZ) // 2,
            (CLX is round(CX * (LCX / 255)),
             CLY is round(CY * (LCY / 255)),
             CLZ is round(CZ * (LCZ / 255)),
            PixColor = [CLX, CLY, CLZ],
            asserta(pixelcolor([CurX, CurY, CurZ], PixColor)),
             !))))
        );
    position(camera, [CameraX, CameraY, CameraZ]),
    offset_march(CameraX, CameraY, CameraZ, CurX, CurY, CurZ, Dist, NewX, NewY, NewZ),
    march_cont(NewX, NewY, NewZ, PixColor)).

march_to_point(StartX, StartY, StartZ, DestX, DestY, DestZ, PixColor, AAFlag) :-
    ((pixelcolor([DestX, DestY, DestZ], PixColorBeforeAA),!);
    get_closest([StartX, StartY, StartZ], _, Dist, fromcamera),
    fake_slope(StartX, StartY, StartZ, DestX, DestY, DestZ, SX, SY, SZ),
    DeltaDist is Dist - 1,
    position(camera, [CameraX, CameraY, CameraZ]),
    offset_march(CameraX, CameraY, CameraZ, SX, SY, SZ, DeltaDist, NewX, NewY, NewZ),
    march_cont(NewX, NewY, NewZ, PixColorBeforeAA),
    asserta(pixelcolor([DestX, DestY, DestZ], PixColorBeforeAA))),
    ((AAFlag = 0,super_sample_aa(DestX, DestY, DestZ, PixColorBeforeAA, PixColor),!);PixColor = PixColorBeforeAA).

super_sample_aa(CurX, CurY, CurZ, PixColor, AAColor) :-
    position(camera, [CamX, CamY, CamZ]),
    LeftX is CurX - 1,
    RightX is CurX + 1,
    UpY is CurY + 1,
    DownY is CurY - 1,
    (
       pixelcolor([LeftX, CurY, CurZ], [LCB, LCG, LCR]);
       march_to_point(CamX, CamY, CamZ, LeftX, CurY, CurZ, [LCB, LCG, LCR], 1)),
    (
       pixelcolor([RightX, CurY, CurZ], [RCB, RCG, RCR]);
       march_to_point(CamX, CamY, CamZ, RightX, CurY, CurZ, [RCB, RCG, RCR], 1)),
    (
       pixelcolor([LeftX, UpY, CurZ], [LUCB, LUCG, LUCR]);
       march_to_point(CamX, CamY, CamZ, LeftX, UpY, CurZ, [LUCB, LUCG, LUCR], 1)),
    (
       pixelcolor([RightX, UpY, CurZ], [RUCB, RUCG, RUCR]);
       march_to_point(CamX, CamY, CamZ, RightX, UpY, CurZ, [RUCB, RUCG, RUCR], 1)),
    (
       pixelcolor([LeftX, DownY, CurZ], [LDCB, LDCG, LDCR]);
       march_to_point(CamX, CamY, CamZ, LeftX, DownY, CurZ, [LDCB, LDCG, LDCR], 1)),
    (
       pixelcolor([RightX, DownY, CurZ], [RDCB, RDCG, RDCR]);
       march_to_point(CamX, CamY, CamZ, RightX, DownY, CurZ, [RDCB, RDCG, RDCR], 1)),
    (
       pixelcolor([CurX, UpY, CurZ], [UCB, UCG, UCR]);
       march_to_point(CamX, CamY, CamZ, CurX, UpY, CurZ, [UCB, UCG, UCR], 1)),
    (
       pixelcolor([CurX, DownY, CurZ], [DCB, DCG, DCR]);
       march_to_point(CamX, CamY, CamZ, CurX, DownY, CurZ, [DCB, DCG, DCR], 1)),
    PixColor = [CB, CG, CR],
    %LightColor = [LightCB, LightCG, LightCR],
    AAB is round(((CB + LCB + RCB + UCB + DCB + LUCB + RUCB + LDCB + RDCB) / 8)),%  * (LightCB / 255)),
    AAG is round(((CG + LCG + RCG + UCG + DCG + LUCG + RUCG + LDCG + RDCG) / 8)),%  * (LightCG / 255)),
    AAR is round(((CR + LCR + RCR + UCR + DCR + LUCR + RUCR + LDCR + RDCR) / 8)),%  * (LightCR / 255)),
    AAColor = [AAB, AAG, AAR].


