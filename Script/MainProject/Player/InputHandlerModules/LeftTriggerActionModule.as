class URightTriggerActionModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::InputActions;

    default Tags.Add(n"Module");
    default Tags.Add(n"Input");
    default Tags.Add(InputNames::LeftTrigger);

    APlayerVessel Player;

    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
    }

    bool ShouldActivate() override
    {
        if (Player.PlayerInputReaderComp.bLeftTriggerActioned)
            return true;
        
        return false;
    }

    bool ShouldDeactivate() override
    {
        return true;
    }

    void OnDeactivated() override
    {
        Player.PlayerInputReaderComp.bLeftTriggerActioned = false;
    }
}