class URotateObjectModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"BasicModule");
    default Tags.Add(n"Rotate");
    
    AModTestOne ModTestOne;
 
    void Setup() override
    {
        ModTestOne = Cast<AModTestOne>(Owner);
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
        Print("ROTATE Blocked");
    }

    void OnUnblocked() override
    {
        Print("ROTATE Unblocked");
    }

    void Update(float DeltaTime) override
    {
        PrintToScreen("ROTATE OBJECT");
        ModTestOne.AddActorWorldRotation(FRotator(40.f * DeltaTime, 0.f, 0.f)); 
    }
}