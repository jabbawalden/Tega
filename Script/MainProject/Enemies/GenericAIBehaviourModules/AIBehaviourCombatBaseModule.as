class UAIBehaviourCombatBaseModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(n"AIBehaviourCombat");

    UAIBehaviourComponent BehaviourComp;
    UAIHealthComponent HealthComp;
 
    void Setup() override
    {
        BehaviourComp = UAIBehaviourComponent::Get(Owner);
        HealthComp = UAIHealthComponent::Get(Owner);
    }

    bool ShouldActivate() override
    {
        if (BehaviourComp == nullptr)
            return false;

        if (BehaviourComp.AggressionState != EAIBehaviourAggressionState::Combat)
            return false;

        if (!HealthComp.IsAlive())
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (BehaviourComp == nullptr)
            return true;

        if (BehaviourComp.AggressionState != EAIBehaviourAggressionState::Combat)
            return true;

        if (!HealthComp.IsAlive())
            return true;

        return false;
    }
}