class UFrameMovementComponent : UActorComponent
{
    UFrameCalculateMoveModule MakeMovementModule;

    UPROPERTY()
    bool bApplyCornerSlide = true;
    private bool bShouldCornerApplySlide;

    UPROPERTY(meta = (EditCondition="bApplySlide", EditConditionHides))
    private float CornerSlideTargetForce = 400.0;

    UPROPERTY(meta = (EditCondition="bApplySlide", EditConditionHides))
    private float CornerSlideInterp = 500.0;

    private float CornerSlideForce;
    private FVector LastSavedSlideDirection;
    private FVector LastSlideImpactPoint;
    private FVector LastSlideImpactNormal;

    //GRAVITY
    UPROPERTY()
    bool bApplyGravity = true;

    UPROPERTY(meta = (EditCondition="bApplyGravity", EditConditionHides))
    FMovementGravitySettings GravitySettings;
    float Gravity = GravitySettings.InitAmount;

    // FVector LastGroundHit;
    // bool bStepUpGroundCheckQueryAvailable;
    // bool bStepUpGroundCheckApplicable;

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

    private TArray<FHitResult> FrameHits;
    private FVector MoveThisFrame;
    private FVector PredictedMove;
    private FVector InternalGroundPlane;

    bool bTEMPHaveDrawn;

    private bool bIsGrounded;
    private bool bPreviouslyGrounded;
    private FVector TotalVelocityPreCalc;

    private int MaxMovementIteration = 5;

    bool bDeltaVelocityApplied;
    bool bImpulseApplied;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        //Adds calculation module that ticks after CalculateMovement
        AModActor ModActor = Cast<AModActor>(Owner);
        APlayerModPawn ModPawn = Cast<APlayerModPawn>(Owner);
        
        MakeMovementModule = Cast<UFrameCalculateMoveModule>(NewObject(this, UFrameCalculateMoveModule::StaticClass())); 

        if (ModActor != nullptr)
            ModActor.AddModule(MakeMovementModule);

        if (ModPawn != nullptr)
            ModPawn.AddModule(MakeMovementModule);

        FrameMoveIgnoreActors.Add(Owner);
    }

    void InitWithSphereComponent(USphereComponent Sphere)
    {
        PlayerSphereComp = Sphere;
    }

    //Potentially handle capsules later on
    void InitWithCapsuleComponent(UCapsuleComponent Capsule)
    {

    }

    //Add velocity to frame - assumes this is a delta velocity
    void AddVelocityToFrame(FVector NewVelocity)
    {
        VelocityCollection.Add(NewVelocity);
        bDeltaVelocityApplied = true;
    }

    //Runs internally
    private void ApplyGravity(float DeltaTime)
    {
        if (!bIsGrounded)
        {
            // PrintToScreen(f"{Gravity=}");
           
            if (bPreviouslyGrounded)
                Gravity = GravitySettings.InitAmount;
            else
                Gravity = Math::FInterpConstantTo(Gravity, GravitySettings.Gravity, DeltaTime, GravitySettings.GravityAcceleration);
            
            FVector GravityVelocity = FVector(0.f, 0.f, -Gravity) * DeltaTime;
            AddVelocityToFrame(GravityVelocity);           
        }

        bPreviouslyGrounded = bIsGrounded;
    }

    //Disable gravity
    void DisableGravity()
    {
        bApplyGravity = false;
    }

    //Enable gravity and reset minimum gravity value
    void EnableGravity()
    {
        bApplyGravity = true;
        Gravity = GravitySettings.InitAmount;
    }

    void AddImpulse(FVector Impulse)
    {
        ImuplseCollection.Add(Impulse);
        bImpulseApplied = true;
    }

    // Runs in RunMovement group
    // If not using module system, run manually once you have calculated your moves
    void Update(float DeltaTime)
    {
        if (bApplyGravity)
            ApplyGravity(DeltaTime);

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
            PredictedMove += GetCornerSlideOffset(DeltaTime);
        }

        bShouldCornerApplySlide = false;

        // if (Owner.ActorLocation != PredictedMove)
        // {
        bIsGrounded = false;


        // //SECOND METHOD - taken from Emil... Maybe more ideal for character movement??
        // //Issue is that player cannot slide against wall when up against an angled down wall
        // FVector DeltaToMove = Velocity;

        // FHitResult Hit;

        // for (int i = 0; i < MaxIterations; i++)
        // {
        //     Owner.AddActorWorldOffset(DeltaToMove, true, Hit, false);
        //     DeltaToMove -= DeltaToMove * Hit.Time;

        //     if (!bIsGrounded)
        //     {
        //         bIsGrounded = GroundedCheck(Hit);
        //     }

        //     if (Hit.bBlockingHit)
        //     {
        //         FVector DepentrationDelta = Hit.Normal * Hit.Normal.DotProduct(Velocity);
        //         Velocity -= DepentrationDelta;
        //     }

        //     if (DeltaToMove.IsNearlyZero())
        //         break;

        //     DeltaToMove -= Hit.Normal * DeltaToMove.DotProduct(Hit.Normal);
        // }

        // Owner.ActorLocation += Velocity * DeltaTime;
        
        
        //MORE PHYSICSY-ISH METHOD
        //Kind of a half way solution so not pure physics, but has some elements of it, and is less rigid with how it solves different impacts
        int Iterations = 0;

        FHitResult Hit;
        System::SphereTraceSingle(PlayerSphereComp.WorldLocation, PredictedMove, PlayerSphereComp.SphereRadius, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::ForOneFrame, Hit, true, FLinearColor::Red);
        FVector TraceDirection = Velocity.GetSafeNormal();

        while (Iterations < MaxMovementIteration && Hit.bBlockingHit)
        {
            Iterations++;

            if (!bIsGrounded)
            {
                bIsGrounded = GroundedCheck(Hit);
            }
            
            // FVector CorrectedNormal = MainHit.ImpactNormal;
            FVector DepenetrationOffset;

            // Maybe solve collisions differently - probably more relevant for character specific movement (step ups etc.)
            // switch(MovementCollisionSolveData::GetCollisionType(MainHit))
            // {
            //     case EGetMovementCollisionType::Ground:
            //         DepenetrationOffset = GetDepenetrationOffset(PredictedMove, CorrectedNormal, MainHit.ImpactPoint, DeltaTime);
            //         break;
            //     case EGetMovementCollisionType::Wall:
            //         CorrectedNormal = CorrectedNormal.ConstrainToPlane(FVector::UpVector);
            //         break;
            // }

            DepenetrationOffset = GetDepenetrationOffset(PredictedMove, Hit.ImpactNormal, Hit.ImpactPoint, DeltaTime);

            TraceDirection = Hit.ImpactNormal;  
            PredictedMove += DepenetrationOffset;

            for (FVector& CurrentVelocity : ImuplseCollection)
            {
                FVector RemoveImpulse = CurrentVelocity.ConstrainToDirection(-DepenetrationOffset.GetSafeNormal());
                CurrentVelocity -= RemoveImpulse;
            }

            // System::DrawDebugArrow(MainHit.ImpactPoint, MainHit.ImpactPoint + MainHit.ImpactNormal * 500.0, 10.0, FLinearColor::Red, 0.0, 5.0);
            
            //Must trace slightly smaller than the current radius so as not to get the same wall hit we just corrected against
            //Janky solution tbh, but seems to be stable with current setup
            System::SphereTraceSingle(PredictedMove, PredictedMove + TraceDirection, PlayerSphereComp.SphereRadius - 1, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::ForOneFrame, Hit, true, FLinearColor::Red);
        }

        Owner.ActorLocation = PredictedMove;

        // PrintToScreen(f"{Iterations=}");
        
        // Old Step Up logic for character movement
        // if (!bIsGrounded)
        // {
        //     bStepUpGroundCheckApplicable = false;
        //     bStepUpGroundCheckQueryAvailable = false;
        // }

        // if (bStepUpGroundCheckQueryAvailable)
        //     LastGroundHit = SaveNextGroundHit;

        // PrintToScreen(f"{bStepUpGroundCheckQueryAvailable=}");
        // PrintToScreen(f"{bStepUpGroundCheckApplicable=}");

        //Sliding off edges
        // if (!bStepUpApplied)

        if (bApplyCornerSlide)
            RunCornerSlideCheck();
        // }

        MoveThisFrame = Owner.ActorLocation - LastLoc;

        VelocityCollection.Empty();
        ImuplsesToRemove.Empty();

        bDeltaVelocityApplied = false;
        bImpulseApplied = false;
    }

    FVector GetDepenetrationOffset(FVector CurrentPredictedMove, FVector ImpactNormal, FVector ImpactPoint, float DeltaTime)
    {
        //Total distance between impact point and predicted move location
        float Size = (ImpactPoint - CurrentPredictedMove).Size();

        //Check if center point of predicted move has passed the collision point - if so, reverse size so that we get the correct depth calculation
        FVector HitToOrigin = (Owner.ActorLocation - ImpactPoint).GetSafeNormal();
        FVector HitToPredicted = (CurrentPredictedMove - ImpactPoint).GetSafeNormal();
        float NormalDot = HitToOrigin.DotProduct(HitToPredicted);
        if (NormalDot < 0.0)
        {
            Size = -Size;
        }
        
        //Depth is radius minus size
        float Depth = PlayerSphereComp.SphereRadius - Size;

        //Offset amount to remove from predicted move delta
        FVector PenetrationOffset = ImpactNormal * Depth;

        //Safety check - if depth is negative for some reason, return 0 for offset
        //This may not be needed anymore? Can't remember use case
        if (Depth <= 0.0)
            PenetrationOffset = FVector(0.0);

        System::DrawDebugArrow(ImpactPoint, ImpactPoint + ImpactNormal * 300.0, 25.0, FLinearColor::Red, 0.0, 5.0);

        return PenetrationOffset;
    }

    //Adds corner slide offset to sphere
    FVector GetCornerSlideOffset(float DeltaTime)
    {
        //Deals with going over slanted corners
        if (bShouldCornerApplySlide)
        {
            // System::DrawDebugArrow(Owner.ActorLocation, Owner.ActorLocation + (PredictedMove - LastSlideImpactPoint).GetSafeNormal() * 500.0, 2.0, FLinearColor::Yellow, 10, 5.0);

            FVector HitToPredicted = (PredictedMove - LastSlideImpactPoint).GetSafeNormal();
            FVector VRight = HitToPredicted.ConstrainToPlane(LastSlideImpactNormal).CrossProduct(HitToPredicted);
            FVector OffEdge = FVector::UpVector.CrossProduct(VRight); 
            
            //This one is for allowing for going in downward directions
            // LastSavedSlideDirection = HitToPredicted.CrossProduct(VRight).GetSafeNormal();
            
            LastSavedSlideDirection = OffEdge.GetSafeNormal();

            CornerSlideForce = Math::FInterpConstantTo(CornerSlideForce, CornerSlideTargetForce, DeltaTime, CornerSlideInterp);
            // System::DrawDebugArrow(Owner.ActorLocation, Owner.ActorLocation + OffEdge * 500.0, 10.0, FLinearColor::Teal, 0.1, 5.0);
        }
        else
        {
            CornerSlideForce = Math::FInterpConstantTo(CornerSlideForce, 0.0, DeltaTime, CornerSlideInterp);
        }

        return LastSavedSlideDirection * CornerSlideForce * DeltaTime;
    }

    //Set slide off corner movement
    void RunCornerSlideCheck()
    {
        FHitResult Hit;

        System::SphereTraceSingle(PredictedMove, PredictedMove - FVector::UpVector * 10, PlayerSphereComp.SphereRadius - 1, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, Hit, true, FLinearColor::Red);

        if (Hit.bBlockingHit)
        {
            float SlopeDot = Hit.ImpactNormal.DotProduct(FVector::UpVector);

            if (SlopeDot >= MovementCollisionSolveData::MinWalkableDot)
            {
                float CenterToNormalDot = Hit.ImpactNormal.DotProduct((Owner.ActorLocation - Hit.ImpactPoint).GetSafeNormal());

                if (CenterToNormalDot < 0.99 && bApplyCornerSlide)
                {
                    bShouldCornerApplySlide = true;
                    LastSlideImpactPoint = Hit.ImpactPoint;
                    LastSlideImpactNormal = Hit.ImpactNormal;
                }
            }
        }
    }

    //Set internal variable during movement iterations
    private bool GroundedCheck(FHitResult Hit)
    {
        if (Hit.bBlockingHit)
        {
            float Dot = Hit.ImpactNormal.DotProduct(FVector::UpVector);
            // PrintToScreen("Grounded Dot: " + Dot);
            // PrintToScreen("Hit.ImpactNormal: " + Hit.ImpactNormal);
            if (Dot >= MovementCollisionSolveData::MinWalkableDot)
            {
               return true;
            }
        }

        // PrintToScreen("No impact");
        return false;
    }

    //Grounded check
    bool IsGrounded()
    {
        return bIsGrounded;
    }

    //For dashes, ground movement etc. if we want actor to move along plane with input
    FVector GetPlaneCorrectedVelocity(FVector CurrentVelocity)
    {
        if (IsGrounded() && GetGroundPlane(CurrentVelocity.GetSafeNormal()).Size() > 0.0)
        {
            FVector UpV = GetGroundPlane(CurrentVelocity.GetSafeNormal());
            FVector RightV = UpV.CrossProduct(CurrentVelocity);
            FVector ForwardV = RightV.CrossProduct(UpV);

            return ForwardV;
        }

        return CurrentVelocity;
    }

    //Traces for and returns ground plane normal - sphere trace however is weird. Change this later to line trace
    FVector GetGroundPlane(FVector MovementDirection)
    {
        FHitResult Hit;
        System::SphereTraceSingle(Owner.ActorLocation, Owner.ActorLocation - Owner.ActorUpVector, PlayerSphereComp.SphereRadius, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, Hit, true, FLinearColor::Red);

        if (Hit.bBlockingHit)
        {
            //If we hit a corner, send last valid ground plane instead, or world up (assumed ground plane) if current internal ground plane is not yet set
            if (ImpactedCorner(MovementDirection, Hit))
            {
                if (InternalGroundPlane.Size() == 0.0)
                    return FVector::UpVector;

                return InternalGroundPlane;
            }
            
            InternalGroundPlane = Hit.ImpactNormal;
            return InternalGroundPlane;
            // System::DrawDebugArrow(Hit.ImpactPoint, Hit.ImpactPoint + (Hit.ImpactNormal * 250.0), 25.0, FLinearColor::Red, 10.0, 5.0);
            // return Hit.ImpactNormal;
        }    

        return FVector(0.0);  
    }

    bool ImpactedCorner(FVector MovementDirection, FHitResult Hit)
    {
        float ImpactDot = Hit.ImpactNormal.DotProduct(FVector::UpVector);

        if (ImpactDot < 0.995 && ImpactDot > 0.0)
        {
            //CHECK IF CORNER

            //Trace from top
            FVector TraceDownStart = Hit.ImpactPoint + (MovementDirection * 1) + (FVector::UpVector * 2);
            FHitResult CornerDownCheck;
            System::LineTraceSingle(TraceDownStart, TraceDownStart - FVector::UpVector * 2.1, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, CornerDownCheck, true);

            //Trace to see if ground gets in the way before reaching forward check - if not, then corner check is not applicable as we are likely on slope
            FVector ForwardApplicableStart = TraceDownStart - (MovementDirection * 3);
            FHitResult ForwardApplicableCheck;
            System::LineTraceSingle(ForwardApplicableStart, ForwardApplicableStart - FVector::UpVector * 3, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, ForwardApplicableCheck, true);

            //Trace from forward
            FVector TraceForwardStart = Hit.ImpactPoint - (MovementDirection * 2) - (FVector::UpVector * 1);
            FHitResult CornerForwardCheck;
            System::LineTraceSingle(TraceForwardStart, TraceForwardStart + MovementDirection * 2.1, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, CornerForwardCheck, true);

            if (CornerDownCheck.bBlockingHit && CornerForwardCheck.bBlockingHit && !ForwardApplicableCheck.bBlockingHit)
            {
                float CornerDotCheck = CornerDownCheck.ImpactNormal.DotProduct(CornerForwardCheck.ImpactNormal);

                if (CornerDotCheck <= 0.5)
                {
                    System::DrawDebugArrow(TraceDownStart, CornerDownCheck.ImpactPoint, 0.5, FLinearColor::Blue, 10.0, 0.5);
                    System::DrawDebugArrow(TraceForwardStart, CornerForwardCheck.ImpactPoint, 0.5, FLinearColor::Red, 10.0, 0.5);
                    System::DrawDebugArrow(Hit.ImpactPoint, Hit.ImpactPoint + Hit.ImpactNormal * 200.0, 1.0, FLinearColor::Green, 10.0, 1.0);
                    return true;
                }
            }
        }

        return false;
    }
}