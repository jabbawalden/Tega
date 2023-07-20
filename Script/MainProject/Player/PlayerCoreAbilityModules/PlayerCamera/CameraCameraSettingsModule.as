class UCameraCameraSettingsModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(n"CameraCameraSettingsModule");
    default Tags.Add(PlayerGenericTags::Camera);

    APlayerVessel Player;
    float TEMPInterp = 3.8f;
 
    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
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
        Player.GetPlayerCameraActor().SpringArm.TargetArmLength = Player.GetCameraOffsetSettings().TargetArmLength;
        // Player.GetPlayerCameraActor().SpringArm.RelativeLocation = OffsetSpringTarget;
        // Player.GetPlayerCameraActor().CameraComp.RelativeLocation = OffsetCameraTarget;
        Player.GetPlayerCameraActor().CameraComp.FieldOfView = Player.GetCameraFOVSettings().FOV;
    }

    void OnDeactivated() override
    {
        
    }

    void Update(float DeltaTime) override
    {
        float TargetLength = Math::FInterpTo(Player.GetPlayerCameraActor().SpringArm.TargetArmLength, Player.GetCameraOffsetSettings().TargetArmLength, DeltaTime, TEMPInterp);
        Player.GetPlayerCameraActor().SpringArm.TargetArmLength = TargetLength;
        PrintToScreen(f"{TargetLength=}");
        PrintToScreen(f"{Player.GetPlayerCameraActor().SpringArm.TargetArmLength=}");
        
        float TargetSpringOffsetX = Math::FInterpTo(Player.GetPlayerCameraActor().SpringArm.RelativeLocation.X, Player.GetCameraOffsetSettings().SpringArmOffsetX, DeltaTime, TEMPInterp);;
        float TargetSpringOffsetY = Math::FInterpTo(Player.GetPlayerCameraActor().SpringArm.RelativeLocation.Y, Player.GetCameraOffsetSettings().SpringArmOffsetY, DeltaTime, TEMPInterp);;
        float TargetSpringOffsetZ = Math::FInterpTo(Player.GetPlayerCameraActor().SpringArm.RelativeLocation.Z, Player.GetCameraOffsetSettings().SpringArmOffsetZ, DeltaTime, TEMPInterp);;
        FVector OffsetSpringTarget = FVector(TargetSpringOffsetX, TargetSpringOffsetY, TargetSpringOffsetZ);
        Player.GetPlayerCameraActor().SpringArm.RelativeLocation = OffsetSpringTarget;
        // Player.GetPlayerCameraActor().SpringArm.TargetOffset = OffsetSpringTarget;

        float TargetCameraOffsetX = Math::FInterpTo(Player.GetPlayerCameraActor().CameraComp.RelativeLocation.X, Player.GetCameraOffsetSettings().CameraOffsetX, DeltaTime, TEMPInterp);;
        float TargetCameraOffsetY = Math::FInterpTo(Player.GetPlayerCameraActor().CameraComp.RelativeLocation.Y, Player.GetCameraOffsetSettings().CameraOffsetY, DeltaTime, TEMPInterp);;
        float TargetCameraOffsetZ = Math::FInterpTo(Player.GetPlayerCameraActor().CameraComp.RelativeLocation.Z, Player.GetCameraOffsetSettings().CameraOffsetZ, DeltaTime, TEMPInterp);;
        FVector OffsetCameraTarget = FVector(TargetCameraOffsetX, TargetCameraOffsetY, TargetCameraOffsetZ);
        Player.GetPlayerCameraActor().CameraComp.RelativeLocation = OffsetCameraTarget;
        
        float TargetFOV = Math::FInterpTo(Player.GetPlayerCameraActor().CameraComp.FieldOfView, Player.GetCameraFOVSettings().FOV, DeltaTime, TEMPInterp);;
        Player.GetPlayerCameraActor().CameraComp.FieldOfView = TargetFOV;
    }
}