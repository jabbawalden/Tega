class UAIBehaviourDetectPlayerModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(n"AIBehaviourDetectPlayerModule");

    APlayerVessel Player;
    UAIBehaviourComponent BehaviourComp;
    TArray<AActor> IgnoreActors;
 
    void Setup() override
    {
        BehaviourComp = UAIBehaviourComponent::Get(Owner);
        Player = Game::GetPlayer();
        IgnoreActors.Add(Owner);
    }

    bool ShouldActivate() override 
    {
        if (BehaviourComp == nullptr)
            return false;

        if (!PlayerInRange())
            return false;

        if (!PlayerInSight())
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (BehaviourComp == nullptr)
            return true;

        if (!PlayerInRange())
            return true;

        if (!PlayerInSight())
            return true;
        
        return false;
    }

    void OnActivated() override
    {
        BehaviourComp.AggressionState = EAIBehaviourAggressionState::Combat;
    }

    void OnDeactivated() override
    {
        BehaviourComp.AggressionState = EAIBehaviourAggressionState::Idle;
    }

    bool PlayerInRange()
    {
        float Distance = (Owner.ActorLocation - Player.ActorLocation).Size();

        if (Distance <= BehaviourComp.DetectionDistance)
            return true;

        return false;
    }

    bool PlayerInSight()
    {
        FHitResult Hit;

        System::LineTraceSingle(Owner.ActorLocation, Player.ActorLocation, ETraceTypeQuery::Visibility, false, IgnoreActors, EDrawDebugTrace::None, Hit, true);

        if (Hit.bBlockingHit)
        {
            if (Hit.Actor == Player)
                return true;
        }

        return false;
    }
} 