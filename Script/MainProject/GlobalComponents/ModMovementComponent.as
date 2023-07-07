struct FGroundedCheck
{
    bool bIsGrounded = false;
    FVector HitPoint;
    float Depenetrate;
}

class UModMovementComponent : UActorComponent
{
    FVector Velocity;

    TArray<FVector> FrameVelocityArray;

    float Gravity = 2000.f;

    float GroundTraceDistance;

    float GroundTraceMinDistance = 1000.f;

    bool bIsGrounded = false;

    TArray<AActor> IgnoreActors;

    UPrimitiveComponent PrimComp;

    FVector BoundingBox;

    TArray<FVector> BoxLocations;

    void InitializeComponent(UPrimitiveComponent Collider)
    {
        IgnoreActors.Add(Owner);

        PrimComp = Collider;

        UBoxComponent BoxComp = Cast<UBoxComponent>(Collider);

        if (BoxComp != nullptr)
        {
            BoundingBox = PrimComp.GetBoundingBoxExtents();

            BoxLocations.Add(FVector(BoundingBox.X, -BoundingBox.Y, 0.f));
            BoxLocations.Add(FVector(-BoundingBox.X, BoundingBox.Y, 0.f));
            BoxLocations.Add(FVector(BoundingBox.X, BoundingBox.Y, 0.f));
            BoxLocations.Add(FVector(-BoundingBox.X, -BoundingBox.Y, 0.f));
        }

    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime)
    {
        // MakeMove(DeltaTime);

        // FHitResult Hit;

        // FVector Start = Owner.ActorLocation;
        // FVector End = Start + -FVector::UpVector * 4000.f;

        // System::LineTraceSingle(Start, End, ETraceTypeQuery::Visibility, false, IgnoreActors, EDrawDebugTrace::ForOneFrame, Hit, true, FLinearColor::Red);

        //TODO Use these to calculate if grounded
        // FVector ColliderCompLoc = PrimComp.WorldLocation - FVector(0.f, 0.f, BoundingBox.Z / 2);

        for (FVector Loc : BoxLocations)
        {
            FVector RelativeLocForward = PrimComp.ForwardVector * Loc.X;
            FVector RelativeLocRight = PrimComp.RightVector * Loc.Y;
            FVector FinalLoc = Owner.ActorLocation + RelativeLocForward + RelativeLocRight;
        }
    }

    void CalculateVelocity(FVector InVelocity)
    {
        FVector FrameVelocity;


        Velocity = InVelocity;
    }

    void AddMove(FVector DeltaOffset)
    {
        FrameVelocityArray.Add(DeltaOffset);

        // FHitResult Hit;
        // Owner.AddActorWorldOffset(DeltaOffset, true, Hit, false);
    }

    FGroundedCheck GroundCheck(float DeltaTime)
    {
        FGroundedCheck GroundedCheck;

        FHitResult Hit;

        GroundTraceDistance = Math::Clamp(GroundTraceDistance, GroundTraceMinDistance, Gravity);
        PrintToScreen("GroundTraceDistance: " + GroundTraceDistance);

        FVector Start = Owner.ActorLocation;
        FVector End = Start + -FVector::UpVector * 4000.f;

        System::LineTraceSingle(Start, End, ETraceTypeQuery::Visibility, false, IgnoreActors, EDrawDebugTrace::ForOneFrame, Hit, true, FLinearColor::Red);

        if (Hit.bBlockingHit)
        {
            GroundedCheck.bIsGrounded = true;
            GroundedCheck.HitPoint = Hit.ImpactPoint;
            return GroundedCheck;
        }

        return GroundedCheck;
    }

    bool IsAirborne()
    {
        return false;
    }
}