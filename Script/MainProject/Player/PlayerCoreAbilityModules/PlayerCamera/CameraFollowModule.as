class UCameraFollowModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(n"CameraControlModule");
    default Tags.Add(PlayerGenericTags::Camera);

    APlayerVessel Player;
    UFrameMovementComponent MoveComp;
    FVector CameraLocation;

    FVector ZOffset;

    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
        MoveComp = UFrameMovementComponent::Get(Player);
    }

    bool ShouldActivate() override
    {
        return true;
    }

    bool ShouldDeactivate() override
    {
        return false;
    }

    void OnActivated() override
    {
        CameraLocation = Player.MeshRoot.WorldLocation;
        Player.GetPlayerCameraActor().ActorLocation = CameraLocation;
    }

    void OnDeactivated() override
    {
        
    }

    void Update(float DeltaTime) override
    {
        CameraLocation = Math::VInterpTo(CameraLocation, Player.CharacterRoot.WorldLocation, DeltaTime, Player.GetCameraChaseSettings().CameraLocationFollowInterp);

        float Dot = Player.GetViewDirection().DotProduct(MoveComp.GetGroundPlane());
        PrintToScreen(f"{Dot=}");

        FVector TargetZOffset = FVector(0.0);

        if (Dot > 0.0)
        {
            //Weird solution to ensure dot always ends at 1.0
            //Figure out better method later
            float UpDot = 89 / Player.GetCameraControlSettings().MinPitchClamp;
            UpDot *= Dot;
            UpDot = Math::Clamp(UpDot, 0.0, 1.0);

            float UpOffsetAmount = Player.GetCameraControlSettings().MaxUpViewOffset * UpDot; 
            TargetZOffset = MoveComp.GetGroundPlane() * UpOffsetAmount;
        }
        else if (Dot < 0.0)
        {
            //Weird solution to ensure dot always ends at 1.0
            //Figure out better method later
            float DownDot = 49.5 / Math::Abs(Player.GetCameraControlSettings().MaxPitchClamp);
            DownDot *= Math::Abs(Dot);
            DownDot = Math::Clamp(DownDot, 0.0, 1.0);

            float DownOffsetAmount = Player.GetCameraControlSettings().MaxDownViewOffset * DownDot; 
            TargetZOffset = MoveComp.GetGroundPlane() * DownOffsetAmount;
        }

        ZOffset = Math::VInterpTo(ZOffset, TargetZOffset, DeltaTime, Player.GetCameraControlSettings().VerticalViewOffsetInterp);

        PrintToScreen(f"{ZOffset=}");

        Player.GetPlayerCameraActor().ActorLocation = CameraLocation + ZOffset;
    }
}