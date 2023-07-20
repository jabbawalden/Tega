class UCameraFollowModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(n"CameraControlModule");
    default Tags.Add(PlayerGenericTags::Camera);

    APlayerVessel Player;
    FVector CameraLocation;
 
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
        CameraLocation = Player.MeshRoot.WorldLocation;
        Player.GetPlayerCameraActor().ActorLocation = CameraLocation;
    }

    void OnDeactivated() override
    {
        
    }

    void Update(float DeltaTime) override
    {
        CameraLocation = Math::VInterpTo(CameraLocation, Player.CharacterRoot.WorldLocation, DeltaTime, Player.GetCameraChaseSettings().CameraLocationFollowInterp);
        Player.GetPlayerCameraActor().ActorLocation = CameraLocation;
    }
}