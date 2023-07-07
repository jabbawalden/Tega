class UPlayerSwitchCombatModeModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");

    APlayerVessel Player;
 
    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
    }

    bool ShouldActivate() override
    {
        if (!Player.WasInputActioned(InputNames::FaceButtonTop))
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        return true;
    }

    void OnActivated() override
    {
        // Player.SwitchCombatMode();
    }

    void OnDeactivated() override
    {
        
    }

    void Update(float DeltaTime) override
    {

    }
}