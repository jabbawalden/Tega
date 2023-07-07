class UTemplateModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");

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

    void Update(float DeltaTime) override
    {

    }
}