class UCameraVectorModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::InputVectors;

    default Tags.Add(n"Input");
    default Tags.Add(n"Module");
    default Tags.Add(InputNames::CameraInput);

    APlayerVessel Player;

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

    void Update(float DeltaTime) override
    {
        Player.PlayerInputReaderComp.SetConstrainedCameraData(Player.GetPlayerCameraActor().CameraComp.ForwardVector, Player.GetPlayerCameraActor().CameraComp.RightVector);
    }
}