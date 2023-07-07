class UButtomTopActionModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::InputActions;

    default Tags.Add(n"Module");
    default Tags.Add(n"Input");
    default Tags.Add(InputNames::FaceButtonTop);

    APlayerVessel Player;

    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
    }

    bool ShouldActivate() override
    {
        if (Player.PlayerInputReaderComp.bFaceButtonTopActioned)
            return true;
        
        return false;
    }

    bool ShouldDeactivate() override
    {
        return true;
    }

    void OnDeactivated() override
    {
        Player.PlayerInputReaderComp.bFaceButtonTopActioned = false;
    }
}