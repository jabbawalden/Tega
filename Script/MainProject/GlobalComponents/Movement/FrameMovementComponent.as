class UFrameMovementComponent : UActorComponent
{
    UFrameCalculateMoveModule MakeMovementModule;

    UPROPERTY()
    bool bApplyCornerSlide = true;
    private bool bShouldCornerApplySlide;

    UPROPERTY(meta = (EditCondition="bApplySlide", EditConditionHides))
    private float CornerSlideTargetForce = 300.0;

    UPROPERTY(meta = (EditCondition="bApplySlide", EditConditionHides))
    private float CornerSlideInterp = 1000.0;

    private float CornerSlideForce;
    private FVector LastSavedSlideDirection;
    private FVector LastSlideImpactPoint;
    private FVector LastSlideImpactNormal;

    //TODO setup gravity logic internally
    UPROPERTY()
    bool bApplyGravity = true;

    UPROPERTY()
    float MaxSlopeDot = 0.85;

    //Velocity collection this frame
    TArray<FVector> VelocityCollection;
    FVector Velocity;

    //Impulse collections this frame 
    TArray<FVector> ImuplseCollection;
    //Drag for impulses
    float ImpulseReduction = 0.975f;

    //Player sphere component
    //To make more generic, this will need to be setup later for applying different collision types
    USphereComponent PlayerSphereComp;

    TArray<AActor> FrameMoveIgnoreActors;

    TArray<FHitResult> FrameHits;
    FVector MoveThisFrame;
    FVector PredictedMove;

    bool bTEMPHaveDrawn;

    private bool bIsGrounded;
    private FVector TotalVelocityPreCalc;

    bool bDeltaVelocityApplied;
    bool bImpulseApplied;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        AModActor ModActor = Cast<AModActor>(Owner);
        APlayerModPawn PlayerPawn = Cast<APlayerModPawn>(Owner);
        
        //Due to circular dependancy, we must use this roundabout method to update movement in the correct module group
        MakeMovementModule = Cast<UFrameCalculateMoveModule>(NewObject(this, UFrameCalculateMoveModule::StaticClass())); 
        // MakeMovementModule.OnModuleUpdate.AddUFunction(this, n"Update");

        if (ModActor != nullptr)
            ModActor.AddModule(MakeMovementModule);

        if (PlayerPawn != nullptr)
            PlayerPawn.AddModule(MakeMovementModule);

        FrameMoveIgnoreActors.Add(Owner);
    }

    void InitSphereComponent(USphereComponent Comp)
    {
        PlayerSphereComp = Comp;
    }

    void AddDeltaVelocityToFrame(FVector NewVelocity)
    {
        VelocityCollection.Add(NewVelocity);
        bDeltaVelocityApplied = true;
    }

    //Runs internally?
    //May need solution if gravity too hard to make smooth
    void ApplyGravity()
    {

    }

    void AddImpulse(FVector Impulse)
    {
        ImuplseCollection.Add(Impulse);
        bImpulseApplied = true;
    }

    // Runs in RunMovement group
    UFUNCTION()
    void Update(float DeltaTime)
    {
        Velocity = FVector(0.0); 
        FVector Impulses; 
        FVector LastLoc = Owner.ActorLocation;

        for (FVector CurrentVelocity : VelocityCollection)
        {
            Velocity += CurrentVelocity;
        }

        TArray<FVector> ImuplsesToRemove;

        for (FVector& CurrentVelocity : ImuplseCollection)
        {
            Impulses += CurrentVelocity;
            CurrentVelocity *= ImpulseReduction;

            // Print("CurrentVelocity in Impulse: " + CurrentVelocity);

            if (CurrentVelocity.Size() <= 0.025f)
                ImuplsesToRemove.Add(CurrentVelocity);
        }

        for (FVector& CurrentVelocity : ImuplsesToRemove)
        {
            ImuplseCollection.Remove(CurrentVelocity);
        }

        Velocity += Impulses;
        PredictedMove = Owner.ActorLocation + Velocity;

        if (bApplyCornerSlide)
        {
            //Issues with going over slanted corners
            if (bShouldCornerApplySlide)
            {
                // System::DrawDebugArrow(Owner.ActorLocation, Owner.ActorLocation + (PredictedMove - LastSlideImpactPoint).GetSafeNormal() * 500.0, 2.0, FLinearColor::Yellow, 10, 5.0);

                FVector HitToPredicted = (PredictedMove - LastSlideImpactPoint).GetSafeNormal();
                FVector VRight = HitToPredicted.ConstrainToPlane(LastSlideImpactNormal).CrossProduct(HitToPredicted);
                LastSavedSlideDirection = HitToPredicted.CrossProduct(VRight).GetSafeNormal();

                CornerSlideForce = Math::FInterpConstantTo(CornerSlideForce, CornerSlideTargetForce, DeltaTime, CornerSlideInterp * 2.0);
                // System::DrawDebugArrow(Owner.ActorLocation, Owner.ActorLocation + LastSavedSlideDirection * 500.0, 10.0, FLinearColor::Teal, 0.1, 5.0);
            }
            else
            {
                CornerSlideForce = Math::FInterpConstantTo(CornerSlideForce, 0.0, DeltaTime, CornerSlideInterp);
            }
            
            PredictedMove += LastSavedSlideDirection * CornerSlideForce * DeltaTime;
        }

        bShouldCornerApplySlide = false;

        if (Owner.ActorLocation != PredictedMove)
        {
            bIsGrounded = false;

            int Iterations = 0;
            int MaxIterations = 20;
            
            FHitResult MainHit;
            // System::SphereTraceSingle(PlayerSphereComp.WorldLocation, PredictedMove + Velocity.GetSafeNormal(), PlayerSphereComp.SphereRadius, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, MainHit, true, FLinearColor::Red);
            System::SphereTraceSingle(PlayerSphereComp.WorldLocation, PredictedMove, PlayerSphereComp.SphereRadius, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, MainHit, true, FLinearColor::Red);
            FVector TraceDirection = Velocity.GetSafeNormal();

            //Still vulnerable to dashing through messy collision when at 15 frames
            //But best version of the system so far.
            while (Iterations < MaxIterations && MainHit.bBlockingHit)
            { 
                Iterations++;

                if (!bIsGrounded)
                    bIsGrounded = GroundedCheck(MainHit);

                FVector DepenetrationOffset = GetDepenetrationOffset(PredictedMove, MainHit.ImpactNormal, MainHit.ImpactPoint, DeltaTime);
                // Print("DepenetrationOffset: " + DepenetrationOffset);
                TraceDirection = MainHit.ImpactNormal;  
                PredictedMove += DepenetrationOffset;

                for (FVector& CurrentVelocity : ImuplseCollection)
                {
                    FVector RemoveImpulse = CurrentVelocity.ConstrainToDirection(-DepenetrationOffset.GetSafeNormal());
                    CurrentVelocity -= RemoveImpulse;
                }
                
                //Must trace slightly smaller than the current radiius so as not to get the same wall hit
                System::SphereTraceSingle(PredictedMove, PredictedMove + TraceDirection, PlayerSphereComp.SphereRadius - 1, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, MainHit, true, FLinearColor::Red);
            }

            PrintToScreen("bShouldCornerApplySlide: " + bShouldCornerApplySlide);
            PrintToScreen("bIsGrounded: " + bIsGrounded);

            // System::SphereTraceMulti(Owner.ActorLocation, PredictedMove, PlayerSphereComp.SphereRadius, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, FrameHits, true, FLinearColor::Red);
            PrintToScreen("Iterations: " + Iterations);

            //Sliding off edges
            // Owner.ActorLocation = PredictedMove;

            if (Iterations < MaxIterations)
                Owner.ActorLocation = PredictedMove;
            else
            {
                PrintToScreen("WE ARE OVER MAX");
            }

            System::SphereTraceSingle(PredictedMove, PredictedMove - FVector::UpVector * 10, PlayerSphereComp.SphereRadius - 1, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, MainHit, true, FLinearColor::Red);

            if (MainHit.bBlockingHit)
            {
                float SlopeDot = MainHit.ImpactNormal.DotProduct(FVector::UpVector);
                PrintToScreen("SlopeDot: " + SlopeDot); 

                if (SlopeDot >= MaxSlopeDot)
                {
                    // System::DrawDebugArrow(MainHit.ImpactPoint, MainHit.ImpactPoint + MainHit.ImpactNormal * 500.0, 10.0, FLinearColor::Green, 0.0, 5.0);

                    float CenterToNormalDot = MainHit.ImpactNormal.DotProduct((Owner.ActorLocation - MainHit.ImpactPoint).GetSafeNormal());
                    PrintToScreen("CenterToNormalDot: " + CenterToNormalDot); 

                    if (CenterToNormalDot < 0.99 && bApplyCornerSlide)
                    {
                        bShouldCornerApplySlide = true;
                        LastSlideImpactPoint = MainHit.ImpactPoint;
                        LastSlideImpactNormal = MainHit.ImpactNormal;
                        PrintToScreen("Apply Corner Slide - CenterToNormalDot: " + CenterToNormalDot); 
                    }
                }
                else
                {
                    // System::DrawDebugArrow(MainHit.ImpactPoint, MainHit.ImpactPoint + MainHit.ImpactNormal * 500.0, 10.0, FLinearColor::Red, 0.0, 5.0);
                }
            }
        }
        else
        {
            PrintToScreen("No Movement Being Made");
        }

        MoveThisFrame = Owner.ActorLocation - LastLoc;

        VelocityCollection.Empty();
        ImuplsesToRemove.Empty();

        bDeltaVelocityApplied = false;
        bImpulseApplied = false;
    }

    FVector GetDepenetrationOffset(FVector CurrentPredictedMove, FVector ImpactNormal, FVector ImpactPoint, float DeltaTime)
    {
        //Get size of difference between predicted location, and impact point
        float Size = (ImpactPoint - CurrentPredictedMove).ConstrainToDirection(ImpactNormal).Size();

        //Taking edges into account by getting updated radius constrained in that direction to the starting location, not predicted location
        float RadiusToConstrainedCenter = (ImpactPoint - Owner.ActorLocation).ConstrainToDirection(ImpactNormal).Size();

        // System::DrawDebugArrow(ImpactPoint, ImpactPoint + ImpactNormal * 500.0, 10.0, FLinearColor::Red, 0.0, 5.0);

        //If predicted move has gone behind the wall, convert size to negative so that the player still gets pushed out in the right direction, and not at a negative value
        //eg sphereradius (100) - size (120) = -20, negative result sends sphere in the wrong direction when multiplied against the impact normal.
        FVector Direction = (CurrentPredictedMove - ImpactPoint).GetSafeNormal();
        float NormalDot = ImpactNormal.DotProduct(Direction);
        if (NormalDot < 0.0)
        {
            Size = -Size;
        }
        
        //Intitialize depth
        float Depth = PlayerSphereComp.SphereRadius - Size;
        //If radius to original position constrained to hit normal is less than sphere radius, then use this instead to account for being along edges or ground from a non completely vertical angle
        float ImpactDotUpCheck = ImpactNormal.DotProduct(FVector::UpVector);
        if (RadiusToConstrainedCenter < PlayerSphereComp.SphereRadius && ImpactDotUpCheck > MaxSlopeDot)
            Depth = RadiusToConstrainedCenter - Size;

        FVector PenetrationOffset = ImpactNormal * Depth;

        if (Depth <= 0.0)
            PenetrationOffset = FVector(0.0);

        return PenetrationOffset;
    }

    bool GroundedCheck(FHitResult Hit)
    {
        if (Hit.bBlockingHit)
        {
            float Dot = Hit.ImpactNormal.DotProduct(FVector::UpVector);
            // PrintToScreen("Grounded Dot: " + Dot);
            // PrintToScreen("Hit.ImpactNormal: " + Hit.ImpactNormal);
            if (Dot >= MaxSlopeDot)
            {
               return true;
            }
        }

        // PrintToScreen("No impact");
        return false;
    }

    bool IsGrounded()
    {
        return bIsGrounded;
    }

    FVector GetPlaneCorrectedVelocity(FVector CurrentVelocity)
    {
        if (IsGrounded() && GetGroundPlane().Size() > 0.0)
        {
            FVector UpV = GetGroundPlane();
            FVector RightV = UpV.CrossProduct(CurrentVelocity);
            FVector ForwardV = RightV.CrossProduct(UpV);

            return ForwardV;
        }

        return CurrentVelocity;
    }

    //Traces for and returns ground plane normal - sphere trace however is weird. Change this later to line trace
    FVector GetGroundPlane()
    {
        FHitResult Hit;
        System::SphereTraceSingle(Owner.ActorLocation, Owner.ActorLocation + Owner.ActorForwardVector, PlayerSphereComp.SphereRadius, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, Hit, true, FLinearColor::Red);

        if (Hit.bBlockingHit)
        {
            return Hit.ImpactNormal;
        }    

        return FVector(0.0);  
    }
}