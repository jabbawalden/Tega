class AAIProjectileMovingBall : AAIAttackBaseActor
{
    default MoveSpeed = 4000.f;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Super::BeginPlay();
        LifeTime = System::GameTimeInSeconds + LifeInterval;
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        Super::Tick(DeltaSeconds);
        
        ActorLocation += ActorForwardVector * MoveSpeed * DeltaSeconds;
        RunAttackTrace(ActorLocation, ActorForwardVector);
    }
}