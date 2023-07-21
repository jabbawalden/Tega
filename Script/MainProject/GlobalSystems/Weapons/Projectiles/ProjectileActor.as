struct FProjectileData
{
    UPROPERTY()
    float MoveSpeed = 5000.0;
    UPROPERTY()
    float LifeTime = 2.0;
    UPROPERTY()
    FVector MoveDirection;
}

class AProjectileActor : AModActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent, Attach = Root)
    UStaticMeshComponent MeshComp;
    default MeshComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
    default MeshComp.SetCastShadow(false);

    UObject OurInstigator;

    UPROPERTY()
    FDamageData DamageData;
    UPROPERTY()
    FProjectileData ProjectileData;

    FAimData AimData;

    TArray<AActor> IgnoreActors;

    void InitiateProjectile(AActor InInstigator, FVector StartDirection, FAimData NewAimData)
    {
        OurInstigator = InInstigator;
        ProjectileData.MoveDirection = StartDirection;
        AimData = NewAimData;
        IgnoreActors.Add(InInstigator);
        IgnoreActors.Add(this);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime)
    {
        ProjectileData.LifeTime -= DeltaTime;

        if (ProjectileData.LifeTime <= 0.f)
            DestroyActor();

        TraceForTarget();
    }

    void TraceForTarget()
    {
        FHitResult Hit;
        FVector Start = ActorLocation;
        FVector End = ActorLocation + ProjectileData.MoveDirection * (ProjectileData.MoveSpeed * Gameplay::WorldDeltaSeconds);
        System::LineTraceSingle(Start, End, ETraceTypeQuery::WeaponTrace, false, IgnoreActors, EDrawDebugTrace::None, Hit, true);

        if (Hit.bBlockingHit)
        {
            UAIHealthComponent HealthComp = UAIHealthComponent::Get(Hit.Actor);

            if (HealthComp != nullptr)
                HealthComp.DealDamage(DamageData);
            
            DestroyActor();
        }
    }
}