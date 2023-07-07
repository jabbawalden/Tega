enum EAIBehaviourAggressionState
{
    Idle,
    Combat
}

enum EAIBehaviourCombatState
{
    Recovery,
    Attacking,
    Stunned,
    CustomBehaviour
}

class UAIBehaviourComponent : UActorComponent
{
    EAIBehaviourAggressionState AggressionState;
    EAIBehaviourCombatState CombatState;

    UPROPERTY(Category = "Modules", EditDefaultsOnly)
    UModuleSheet BehaviourSheet;
    
    UPROPERTY(Category = "Aggression Settings")
    float DetectionDistance = 5000.f;

    UPROPERTY(Category = "Combat Settings")
    float StunDuration = 2.f;

    UPROPERTY(Category = "Combat Settings")
    float RecoveryTime = 1.f;

    UPROPERTY(Category = "Combat Settings")
    bool bAttacksInterruptable;

    UPROPERTY(Category = "Combat Settings")
    float RotationSpeed = 80.f;

    AModActor ModOwner;

    private bool bIsStunned = false;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        ModOwner = Cast<AModActor>(Owner);
        ModOwner.AddModuleSheet(BehaviourSheet);
        UAIHealthComponent HealthComp = UAIHealthComponent::Get(Owner); 
        HealthComp.OnAIDeath.AddUFunction(this, n"OnDeath");
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {

    }

    void SetStunned()
    {
        if (bIsStunned)
            return;

        CombatState = EAIBehaviourCombatState::Stunned;
        bIsStunned = true;
    }

    void SetRecovery()
    {
        if (bIsStunned)
            return;

        CombatState = EAIBehaviourCombatState::Recovery;
    }

    void SetAttacking()
    {
        if (bIsStunned)
            return;

        CombatState = EAIBehaviourCombatState::Attacking;
    }

    void ConsumeStun()
    {
        if (bIsStunned)
        {
            bIsStunned = false;
        }
    }

    UFUNCTION()
    void OnDeath()
    {
        BehaviourSheet;
        ModOwner.RemoveModuleSheet(BehaviourSheet);
        Print("On Add " + Name + " BehaviourSheet Owner " + BehaviourSheet.ModuleArray[0].Owner);   
    }
}