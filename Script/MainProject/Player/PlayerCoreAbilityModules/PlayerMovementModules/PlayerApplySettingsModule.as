class UPlayerApplySettingsModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Initiation;

    default Tags.Add(n"Module");
    default Tags.Add(PlayerGenericTags::Movement);

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
        Player.UpdateMovementSettings();
        Player.UpdateCameraSettings();
    }
}