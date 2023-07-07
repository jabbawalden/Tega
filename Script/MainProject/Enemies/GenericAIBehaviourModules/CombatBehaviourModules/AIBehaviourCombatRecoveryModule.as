class UAIBehaviourCombatRecoveryModule : UAIBehaviourCombatBaseModule
{
    float RecoveryTime;

    bool ShouldActivate() override
    {
        if (Super::ShouldActivate() == false)  
            return false;

        if (BehaviourComp.CombatState != EAIBehaviourCombatState::Recovery)
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (Super::ShouldDeactivate() == true)  
            return true;

        if (BehaviourComp.CombatState != EAIBehaviourCombatState::Recovery)
            return true;

        if (System::GameTimeInSeconds > RecoveryTime)
            return true;

        return false;
    }

    void OnActivated() override
    {
        RecoveryTime = System::GameTimeInSeconds + BehaviourComp.RecoveryTime;
    }

    void OnDeactivated() override
    {
        BehaviourComp.SetAttacking();
    }

    void Update(float DeltaTime) override
    {
        PrintToScreen("RECOVERING");
    }
}