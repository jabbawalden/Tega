class UMoveObjectModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;
    
    default Tags.Add(n"BasicModule");
    default Tags.Add(n"Move");
    
    AModActor OurActor;
 
    void Setup() override
    {
        OurActor = Cast<AModActor>(Owner);
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

    void OnBlocked() override
    {

    }

    void OnUnblocked() override
    {

    }

    void Update(float DeltaTime) override
    {
        PrintToScreen("Move Object ACTIVE");
    }

    void OnRemoved() override
    {
        Print("Move Object REMOVED");
    }
}