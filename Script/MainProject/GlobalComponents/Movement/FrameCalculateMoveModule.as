// event void FOnModuleUpdate(float DeltaTime);

class UFrameCalculateMoveModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::RunMovement;

    default Tags.Add(n"ComponentMakeMovementModule");
    
    // FOnModuleUpdate OnModuleUpdate;

    UFrameMovementComponent FrameMoveComp;

    void Setup() override
    {
        FrameMoveComp = UFrameMovementComponent::Get(Owner);
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
        FrameMoveComp.Update(DeltaTime);
        
        // OnModuleUpdate.Broadcast(DeltaTime);
    }
}