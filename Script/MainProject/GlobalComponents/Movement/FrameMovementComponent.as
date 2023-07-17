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

    FVector LastGroundHit;
    bool bStepUpGroundCheckQueryAvailable;
    bool bStepUpGroundCheckApplicable;

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
    private bool bPreviouslyGrounded;
    private FVector TotalVelocityPreCalc;

    bool bDeltaVelocityApplied;
    bool bImpulseApplied;

    bool TEMPDebugDrew;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        AModActor ModActor = Cast<AModActor>(Owner);
        APlayerModPawn PlayerPawn = Cast<APlayerModPawn>(Owner);
        
        MakeMovementModule = Cast<UFrameCalculateMoveModule>(NewObject(this, UFrameCalculateMoveModule::StaticClass())); 

        if (ModActor != nullptr)
            ModActor.AddModule(MakeMovementModule);

        if (PlayerPawn != nullptr)
            PlayerPawn.AddModule(MakeMovementModule);

        FrameMoveIgnoreActors.Add(Owner);
    }

    void InitWithSphereComponent(USphereComponent Sphere)
    {
        PlayerSphereComp = Sphere;
    }

    void InitWithCapsuleComponent(UCapsuleComponent Capsule)
    {

    }

    void AddVelocityToFrame(FVector NewVelocity)
    {
        VelocityCollection.Add(NewVelocity);
        bDeltaVelocityApplied = true;
    }

    //Runs internally?
    //May need solution if gravity too hard to make smooth
    void ApplyGravity(float DeltaTime)
    {
        if (!bIsGrounded)
        {
            PrintToScreen(f"{Gravity=}");
           
            if (bPreviouslyGrounded)
                Gravity = GravitySettings.InitAmount;
            else
                Gravity = Math::FInterpConstantTo(Gravity, GravitySettings.Gravity, DeltaTime, GravitySettings.GravityAcceleration);
            
            FVector GravityVelocity = FVector(0.f, 0.f, -Gravity) * DeltaTime;
            AddVelocityToFrame(GravityVelocity);           
        }

        bPreviouslyGrounded = bIsGrounded;
    }

    void DisableGravity()
    {
        bApplyGravity = false;
    }

    void EnableGravity()
    {
        bApplyGravity = true;
    }

    void AddImpulse(FVector Impulse)
    {
        ImuplseCollection.Add(Impulse);
        bImpulseApplied = true;
    }

    // Runs in RunMovement group
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

        if (Owner.ActorLocation != PredictedMove)
        {
            bIsGrounded = false;

            int Iterations = 0;
            int MaxIterations = 15;

            FVector DeltaToMove = Velocity;

            FHitResult Hit;

            for (int i = 0; i < MaxIterations; i++)
            {
                Owner.AddActorWorldOffset(DeltaToMove, true, Hit, false);
                DeltaToMove -= DeltaToMove * Hit.Time;

                if (!bIsGrounded)
                {
                    bIsGrounded = GroundedCheck(Hit);
                }

                if (Hit.bBlockingHit)
                {
                    FVector DepentrationDelta = Hit.Normal * Hit.Normal.DotProduct(Velocity);
                    Velocity -= DepentrationDelta;
                }

                if (DeltaToMove.IsNearlyZero())
                    break;

                DeltaToMove -= Hit.Normal * DeltaToMove.DotProduct(Hit.Normal);
            }
            

            // FHitResult MainHit;
            // System::SphereTraceSingle(PlayerSphereComp.WorldLocation, PredictedMove, PlayerSphereComp.SphereRadius, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, MainHit, true, FLinearColor::Red);
            // FVector TraceDirection = Velocity.GetSafeNormal();

            // //Still vulnerable to dashing through messy collision when at 15 frames
            // //But best version of the system so far.
            // while (Iterations < MaxIterations && MainHit.bBlockingHit)
            // {
            //     Iterations++;

            //     if (!bIsGrounded)
            //     {
            //         bIsGrounded = GroundedCheck(MainHit);
            //     }
                
            //     FVector CorrectedNormal = MainHit.ImpactNormal;
            //     FVector DepenetrationOffset;

            //     DepenetrationOffset = GetDepenetrationOffset(PredictedMove, CorrectedNormal, MainHit.ImpactPoint, DeltaTime);

            //     // switch(MovementCollisionSolveData::GetCollisionType(MainHit))
            //     // {
            //     //     case EGetMovementCollisionType::Ground:
            //     //         DepenetrationOffset = GetDepenetrationOffset(PredictedMove, CorrectedNormal, MainHit.ImpactPoint, DeltaTime);
            //     //         break;
            //     //     case EGetMovementCollisionType::Wall:
            //     //         CorrectedNormal = CorrectedNormal.ConstrainToPlane(FVector::UpVector);
            //     //         DepenetrationOffset = GetWallDepenetrationOffset(PredictedMove, CorrectedNormal, MainHit.ImpactPoint, DeltaTime);
            //     //         break;
            //     // }

            //     // FVector DepenetrationOffset = GetDepenetrationOffset(PredictedMove, CorrectedNormal, MainHit.ImpactPoint, DeltaTime);
            //     // PrintToScreen("DepenetrationOffset: " + DepenetrationOffset);

            //     TraceDirection = CorrectedNormal;  
            //     PredictedMove += DepenetrationOffset;

            //     for (FVector& CurrentVelocity : ImuplseCollection)
            //     {
            //         FVector RemoveImpulse = CurrentVelocity.ConstrainToDirection(-DepenetrationOffset.GetSafeNormal());
            //         CurrentVelocity -= RemoveImpulse;
            //     }

            //     // System::DrawDebugArrow(MainHit.ImpactPoint, MainHit.ImpactPoint + MainHit.ImpactNormal * 500.0, 10.0, FLinearColor::Red, 0.0, 5.0);
                
            //     //Must trace slightly smaller than the current radiius so as not to get the same wall hit
            //     System::SphereTraceSingle(PredictedMove, PredictedMove + TraceDirection, PlayerSphereComp.SphereRadius - 1, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, MainHit, true, FLinearColor::Red);
            // }
            // Owner.ActorLocation = PredictedMove;

            // Owner.ActorLocation += Velocity;

            PrintToScreen(f"{Iterations=}");
            
            if (!bIsGrounded)
            {
                bStepUpGroundCheckApplicable = false;
                bStepUpGroundCheckQueryAvailable = false;
            }

            // if (bStepUpGroundCheckQueryAvailable)
            //     LastGroundHit = SaveNextGroundHit;

            // PrintToScreen(f"{bStepUpGroundCheckQueryAvailable=}");
            // PrintToScreen(f"{bStepUpGroundCheckApplicable=}");

            //Sliding off edges
            // if (!bStepUpApplied)
            if (bApplyCornerSlide)
                RunCornerSlideCheck();
        }

        MoveThisFrame = Owner.ActorLocation - LastLoc;

        VelocityCollection.Empty();
        ImuplsesToRemove.Empty();

        bDeltaVelocityApplied = false;
        bImpulseApplied = false;
    }

    FVector GetDepenetrationOffset(FVector CurrentPredictedMove, FVector ImpactNormal, FVector ImpactPoint, float DeltaTime)
    {
        float Size = (ImpactPoint - CurrentPredictedMove).Size();
        float SizeBeforeDotCheck = Size;

        // FVector Direction = (CurrentPredictedMove - ImpactPoint).GetSafeNormal();
        // float NormalDot = ImpactNormal.DotProduct(Direction);
        // if (NormalDot < 0.0)
        // {
        //     Size = -Size;
        // }
        
        //Intitialize depth
        float Depth = PlayerSphereComp.SphereRadius - Size;
        // float Depth = Hit.Distance;

        if (Depth > 50.0 && !TEMPDebugDrew)
        {
            Print(f"{Depth=}");
            // Print(f"{NormalDot=}");
            Print(f"{SizeBeforeDotCheck=}");
            Print(f"{Size=}");
            System::DrawDebugArrow(ImpactPoint, ImpactPoint + ImpactNormal * 500.0, 10.0, FLinearColor::Red, 500.0, 2.5);
            System::DrawDebugSphere(Owner.ActorLocation, PlayerSphereComp.SphereRadius, 12, FLinearColor::Red, 500, 2);
            System::DrawDebugArrow(Owner.ActorLocation, CurrentPredictedMove, 10.0, FLinearColor::Green, 500.0, 2.5);
            System::DrawDebugSphere(CurrentPredictedMove, PlayerSphereComp.SphereRadius, 12, FLinearColor::Green, 500, 1);
            TEMPDebugDrew = true;
        }
        //If radius to original position constrained to hit normal is less than sphere radius, then use this instead to account for being along edges or ground from a non completely vertical angle
        // float ImpactDotUpCheck = ImpactNormal.DotProduct(FVector::UpVector);
        // if (RadiusToConstrainedCenter < PlayerCollisionComp.SphereRadius && ImpactDotUpCheck > MovementCollisionSolveData::MinWalkableDot)
        //     Depth = RadiusToConstrainedCenter - Size;

        FVector PenetrationOffset = ImpactNormal * Depth;

        if (Depth <= 0.0)
            PenetrationOffset = FVector(0.0);

        return PenetrationOffset;
    }

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

        return LastSavedSlideDirection * CornerSlideForce * DeltaTime;;
    }

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

    bool GroundedCheck(FHitResult Hit)
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
        System::SphereTraceSingle(Owner.ActorLocation, Owner.ActorLocation - Owner.ActorUpVector, PlayerSphereComp.SphereRadius, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, Hit, true, FLinearColor::Red);

        if (Hit.bBlockingHit)
        {
            return Hit.ImpactNormal;
        }    

        return FVector(0.0);  
    }
}