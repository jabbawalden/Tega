class UAIAttackConstantComponent : UAIAttackBaseComponent
{
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Super::BeginPlay();
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if (System::GameTimeInSeconds > AttackTime)
        {
            ActivateAttack();
        }
    }

    void RunAttack(AActor Target) override
    {
        Super::RunAttack(Target);
    }
}