class UAIBehaviourCombatAttackModule : UAIBehaviourCombatBaseModule
{
    private float AttackTime;

    TArray<UAIAttackBaseComponent> AttackCompArray;
    APlayerVessel Player;

    void Setup() override
    {
        Super::Setup();
        Owner.GetComponentsByClass(AttackCompArray);
        Player = Game::GetPlayer();
    }

    bool ShouldActivate() override
    {
        if (Super::ShouldActivate() == false)  
            return false;

        if (BehaviourComp.CombatState != EAIBehaviourCombatState::Attacking)
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (Super::ShouldDeactivate() == true)  
            return true;

        if (BehaviourComp.CombatState != EAIBehaviourCombatState::Attacking)
            return true;

        return false;
    }

    void OnActivated() override
    {
        Super::OnActivated();

        for (UAIAttackBaseComponent AttackComp : AttackCompArray)
        {
            AttackComp.RunAttack(Player);
        }
    }

    void OnDeactivated() override
    {
        BehaviourComp.SetRecovery();

        for (UAIAttackBaseComponent AttackComp : AttackCompArray)
        {
            AttackComp.FinishAttack();
        }
    }

    void Update(float DeltaTime) override
    {
        PrintToScreen("ATTACKING");
    }
}