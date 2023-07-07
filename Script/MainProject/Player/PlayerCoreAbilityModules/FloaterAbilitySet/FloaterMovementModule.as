class UFloaterMovementModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::CalculateMovement;

    default Tags.Add(n"Module");
    default Tags.Add(n"FloaterModule");
    default Tags.Add(n"FloaterMovementModule");

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

    void OnActivated() override
    {
        
    }

    void OnDeactivated() override
    {
        
    }

    void Update(float DeltaTime) override
    {
        PrintToScreen("FLOATER ACTIVE");
    }
}