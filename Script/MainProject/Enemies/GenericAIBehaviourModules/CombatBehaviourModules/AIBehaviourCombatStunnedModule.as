class UAIBehaviourCombatStunnedModule : UAIBehaviourCombatBaseModule
{
    float StunRecoveryTime;

    bool ShouldActivate() override
    {
        if (Super::ShouldActivate() == false)  
            return false;

        if (BehaviourComp.CombatState != EAIBehaviourCombatState::Stunned)
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (Super::ShouldDeactivate() == true)  
            return true;

        if (BehaviourComp.CombatState != EAIBehaviourCombatState::Stunned)
            return true;

        if (System::GameTimeInSeconds > StunRecoveryTime)
            return true;

        return false;
    }

    void OnActivated() override
    {
        StunRecoveryTime = System::GameTimeInSeconds + BehaviourComp.StunDuration;
    }

    void OnDeactivated() override
    {
        BehaviourComp.ConsumeStun();
        BehaviourComp.SetRecovery();
    }

    void Update(float DeltaTime) override
    {
        PrintToScreen("STUNNED");
    }
}