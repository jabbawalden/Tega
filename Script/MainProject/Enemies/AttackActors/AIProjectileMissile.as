class AAIProjectileMissile : AAIAttackBaseActor
{
    default MoveSpeed = 100.f;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Super::BeginPlay();
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        Super::Tick(DeltaSeconds);
        // Move based on direction towards target
        // ActorLocation += ActorForwardVector * MoveSpeed * DeltaSeconds;
        RunAttackTrace(ActorLocation, ActorForwardVector);
    }
}