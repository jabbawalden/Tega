class UAIBehaviourCombatFacePlayerHorizontalModule : UAIBehaviourCombatBaseModule
{
    APlayerVessel Player;
    AEnemyBase EnemyOwner;
    
    void Setup() override
    {
        Super::Setup();
        Player = Game::GetPlayer();
        EnemyOwner = Cast<AEnemyBase>(Owner);
    }

    bool ShouldActivate() override
    {
        if (Super::ShouldActivate() == false)  
            return false;

        if (BehaviourComp.AggressionState != EAIBehaviourAggressionState::Combat)
            return false;

        if (BehaviourComp.CombatState == EAIBehaviourCombatState::Stunned)
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (Super::ShouldDeactivate() == true)  
            return true;

        if (BehaviourComp.AggressionState != EAIBehaviourAggressionState::Combat)
            return true;

        if (BehaviourComp.CombatState == EAIBehaviourCombatState::Stunned)
            return true;

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
        FVector Dir = Player.ActorLocation - EnemyOwner.ActorLocation;
        float Dot = Dir.GetSafeNormal().DotProduct(FVector::UpVector);
        // PrintToScreen("Dot: " + Dot);
        
        Dir = Dir.ConstrainToPlane(FVector::UpVector);
        FQuat TargetQuat = Dir.ToOrientationQuat();
        FQuat NewQuat = Math::QInterpConstantTo(EnemyOwner.ActorRotation.Quaternion(), TargetQuat, DeltaTime, 2.f);
        EnemyOwner.ActorRotation = NewQuat.Rotator();
    }
}