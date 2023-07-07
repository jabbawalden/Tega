enum EAttackTraceShape
{
    Line,
    Sphere,
    Box
}

struct FAIAttackTraceSettings
{
    UPROPERTY()
    EAttackTraceShape TraceShape;

    UPROPERTY()
    float TraceLength = 10.f;
    UPROPERTY(meta = (EditCondition="TraceShape == EAttackTraceShape::Sphere", EditConditionHides))
    float TraceRadius = 32.f;
    UPROPERTY(meta = (EditCondition="TraceShape == EAttackTraceShape::Box", EditConditionHides))
    FVector TraceBoxExtents = FVector(40.0);
}

UCLASS(Abstract)
class AAIAttackBaseActor : AModActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent MeshRoot;

    TArray<AActor> IgnoreActors;

    AActor AttackInstigator;

    UPROPERTY(EditDefaultsOnly, Category = "Attack Settings")
    FAIAttackTraceSettings AttackTraceSettings;

    UPROPERTY(EditDefaultsOnly, Category = "Speed Settings")
    float MoveSpeed = 4000.f;

    UPROPERTY(EditDefaultsOnly, Category = "Speed Settings")
    bool bUseAcceleration = false;

    UPROPERTY(EditDefaultsOnly, Category = "Speed Settings", meta = (EditCondition = "bUseAcceleration", EditConditionHides))
    float StartSpeed = 500.f;
    UPROPERTY(EditDefaultsOnly, Category = "Speed Settings", meta = (EditCondition = "bUseAcceleration", EditConditionHides))
    float AccelerationSpeed = 3000.f;
    float EndSpeed;

    float LifeInterval = 10.f;
    float LifeTime;

    AActor AttackTarget;
    
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        LifeTime = System::GameTimeInSeconds + LifeInterval;

        IgnoreActors.Add(this);
        IgnoreActors.Add(AttackInstigator);

        if (bUseAcceleration)
        {
            EndSpeed = MoveSpeed; 
            MoveSpeed = StartSpeed;
        }
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if (bUseAcceleration)
        {
            MoveSpeed = Math::FInterpConstantTo(MoveSpeed, EndSpeed, DeltaSeconds, AccelerationSpeed);
        }

        if (System::GameTimeInSeconds > LifeTime)
            DestroyActor();
    }

    void RunAttackTrace(FVector Start, FVector Direction)
    {
        FHitResult Hit;
        FVector End = Start + Direction * AttackTraceSettings.TraceLength;

        switch(AttackTraceSettings.TraceShape)
        {
            case EAttackTraceShape::Line:
                System::LineTraceSingle(Start, End, ETraceTypeQuery::Visibility, false, IgnoreActors, EDrawDebugTrace::ForOneFrame, Hit, true);
                break;
            case EAttackTraceShape::Sphere:
                System::SphereTraceSingle(Start, End, AttackTraceSettings.TraceRadius, ETraceTypeQuery::Visibility, false, IgnoreActors, EDrawDebugTrace::ForOneFrame, Hit, true);
                break;
            case EAttackTraceShape::Box:
                System::BoxTraceSingle(Start, End, AttackTraceSettings.TraceBoxExtents, Direction.Rotation(), ETraceTypeQuery::WeaponTrace, false, IgnoreActors, EDrawDebugTrace::ForOneFrame, Hit, true);
                break;
        }

        if (Hit.bBlockingHit)
        {
            UPlayerHealthComponent HealthComp = UPlayerHealthComponent::Get(Hit.Actor);

            if (HealthComp != nullptr)
            {
            }

            DestroyActor();
        }
    }
}