class UAIAttackBurstComponent : UAIAttackBaseComponent
{
    UPROPERTY(Category = "Attack Settings", EditDefaultsOnly)
    int BurstCount = 1;

    int CurrentBurstCount;

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
            CurrentBurstCount++;
        }

        if (CurrentBurstCount >= BurstCount)
        {
            BehaviourComp.SetRecovery();
            CurrentBurstCount = 0;
        }
    }
}