class AAIProjectileFollow : AAIAttackBaseActor
{
    default MoveSpeed = 1000.f;

    UPROPERTY(EditDefaultsOnly, Category = "Rotation Settings")
    float RotationSpeed = 120.f;

    UPROPERTY(EditDefaultsOnly, Category = "Rotation Settings")
    bool bUseRotationAcceleration = false;

    UPROPERTY(EditDefaultsOnly, Category = "Rotation Settings", meta = (EditCondition = "bUseRotationAcceleration", EditConditionHides))
    float StartRotationSpeed = 30.f;
    UPROPERTY(EditDefaultsOnly, Category = "Rotation Settings", meta = (EditCondition = "bUseRotationAcceleration", EditConditionHides))
    float AccelerationRotationSpeed = 90.f;
    float EndRotationSpeed;


    UPROPERTY(EditDefaultsOnly, Category = "Rotation Settings")
    bool bStopRotatingAfterTime = false;
    UPROPERTY(EditDefaultsOnly, Category = "Rotation Settings", meta = (EditCondition = "bStopRotatingAfterTime", EditConditionHides))
    float StopRotationInterval = 3.f;

    float StopRotationTime;

    default LifeInterval = 6.f;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Super::BeginPlay();

        if (bUseRotationAcceleration)
        {
            EndRotationSpeed = RotationSpeed;
            RotationSpeed = StartRotationSpeed;
        }

        if (bStopRotatingAfterTime)
        {
            StopRotationTime = System::GameTimeInSeconds + StopRotationInterval;
        }
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        Super::Tick(DeltaSeconds);

        if (bStopRotatingAfterTime)
        {
            if (System::GameTimeInSeconds < StopRotationTime)
            {
                RunRotationOverTime(DeltaSeconds);
            }
        }
        else
        {
            RunRotationOverTime(DeltaSeconds);
        }

        ActorLocation += ActorForwardVector * MoveSpeed * DeltaSeconds;
        RunAttackTrace(ActorLocation, ActorForwardVector);
    }

    void RunRotationOverTime(float DeltaSeconds)
    {
        RotationSpeed = Math::FInterpConstantTo(RotationSpeed, EndRotationSpeed, DeltaSeconds, AccelerationRotationSpeed);
        FRotator TargetRot = (AttackTarget.ActorLocation - ActorLocation).Rotation();
        ActorRotation = Math::RInterpConstantTo(ActorRotation, TargetRot, DeltaSeconds, RotationSpeed);
    }
}