class APlayerProjectile : AModActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    UBoxComponent BoxComp;
    default BoxComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);

    UPROPERTY(DefaultComponent, Attach = BoxComp)
    UStaticMeshComponent MeshComp;
    default MeshComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
    default MeshComp.SetCastShadow(false);

    UObject OurInstigator;

    float MoveSpeed = 18000.f;
    float LifeTime = 1.5f;

    TArray<AActor> IgnoreActors;

    void InitiateProjectile(AActor InInstigator)
    {
        OurInstigator = InInstigator;
        IgnoreActors.Add(InInstigator);
        IgnoreActors.Add(this);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime)
    {
        ActorLocation += ActorForwardVector * MoveSpeed * DeltaTime;

        LifeTime -= DeltaTime;

        if (LifeTime <= 0.f)
            DestroyActor();

        TraceForTarget();
    }

    void TraceForTarget()
    {
        FHitResult Hit;
        FVector Start = ActorLocation;
        FVector End = ActorLocation + ActorForwardVector * (MoveSpeed + 1000.f) * Gameplay::WorldDeltaSeconds;
        System::LineTraceSingle(Start, End, ETraceTypeQuery::WeaponTrace, false, IgnoreActors, EDrawDebugTrace::None, Hit, true);

        if (Hit.bBlockingHit)
        {
            UAIHealthComponent HealthComp = UAIHealthComponent::Get(Hit.Actor);

            if (HealthComp != nullptr)
                HealthComp.DealDamage(1.f);
            
            DestroyActor();
        }
    }
}