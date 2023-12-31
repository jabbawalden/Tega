class UFrameMovementComponent : UActorComponent
{
    //INITIATE
    UFrameCalculateMoveModule MakeMovementModule;
    //Player sphere component
    USphereComponent PlayerSphereComp;

    //Corner Slide
    UPROPERTY()
    bool bApplyCornerSlide = true;
    private bool bShouldCornerApplySlide;

    UPROPERTY(meta = (EditCondition="bApplySlide", EditConditionHides))
    private float CornerSlideTargetForce = 400.0;

    UPROPERTY(meta = (EditCondition="bApplySlide", EditConditionHides))
    private float CornerSlideInterp = 400.0;

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

    //VELOCITIES
    //Velocity collection this frame
    TArray<FVector> VelocityCollection;
    FVector Velocity;
    //Impulse collections this frame 
    FVector ImuplseForce;
    //Drag for impulses
    float ImpulseDrag = 0.992f;
    TArray<AActor> FrameMoveIgnoreActors;

    //ROTATIONS
    FRotator AddRotations;
    FRotator SetRotation;

    //MOVEMENT INTERNAL DATA
    private FVector MoveThisFrame;
    private FVector PredictedMove;
    private FVector InternalGroundPlane;
    private int MaxMovementIteration = 5;
    
    //GROUNDED
    private bool bIsGrounded;
    private bool bPreviouslyGrounded;

    //INHERIT MOVEMENT
    // private TArray<AActor> InheritMovementActors;
    private FInheritenceMovementData InheritenceData;
    private FVector InheritedVelocity;
    private float InheritedDrag = 0.996;

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
        Velocity += NewVelocity;
    }
    
    //Add rotation to this frame - overridden when set rotation is called
    void AddRotationToFrame(FRotator Rotation)
    {
        AddRotations += Rotation;
    }

    //Sets rotation this frame - overrides any added rotations
    void SetRotationThisFrame(FRotator Rotation)
    {
        SetRotation = Rotation;
    }

    //Runs internally
    private void ApplyGravity(float DeltaTime)
    {
        if (!bIsGrounded)
        {
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
        ImuplseForce += Impulse;
    }

    // Runs in RunMovement group
    // If not using module system, will need to be run manually (in module setup, we calcualte moves first in the frame, then update after)
    void Update(float DeltaTime)
    {
        if (bApplyGravity)
            ApplyGravity(DeltaTime);

        // FVector Impulses; 
        FVector LastLoc = Owner.ActorLocation;

        for (FVector CurrentVelocity : VelocityCollection)
        {
            Velocity += CurrentVelocity;
        }

        ImuplseForce -= (ImuplseForce * ImpulseDrag * DeltaTime);
        Velocity += ImuplseForce * DeltaTime;

        if (bApplyCornerSlide)
        {
            Velocity += GetCornerSlideOffset(DeltaTime);
        }

        if (InheritenceData.Comp != nullptr)
        {
            InheritedVelocity = InheritenceData.Comp.GetInheritedVelocity();
            InheritenceData.Comp = nullptr;
        }

        if (!InheritedVelocity.IsNearlyZero())
        {
            Velocity += InheritedVelocity;
            InheritedVelocity -= (InheritedVelocity * InheritedDrag * DeltaTime);
        }

        PredictedMove = Owner.ActorLocation + Velocity;

        bShouldCornerApplySlide = false;
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
        
        
        //CURRENT METHOD
        int Iterations = 0;

        bool bInheritenceHitMade = false;

        if (Owner.ActorLocation == PredictedMove)
            PredictedMove = Owner.ActorLocation - FVector(0,0,1);

        FHitResult Hit;
        System::SphereTraceSingle(PlayerSphereComp.WorldLocation, PredictedMove, PlayerSphereComp.SphereRadius, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, Hit, true, FLinearColor::Red);
        FVector TraceDirection = Velocity.GetSafeNormal();

        FVector InheritenceGroundImpact;

        while (Iterations < MaxMovementIteration && Hit.bBlockingHit)
        {
            Iterations++;
            bool bWasGroundHit = false;

            if (!bIsGrounded)
            {
                bIsGrounded = GroundedCheck(Hit);
                bWasGroundHit = true;
            }

            if (!bInheritenceHitMade && bWasGroundHit)
            {
                bInheritenceHitMade = UpdateTargetInheritMovementActor(Hit.Actor, Hit.Component);
            }

            //Set inheritence ground impact this frame   
            if (MovementCollisionSolveData::GetCollisionType(Hit) == EGetMovementCollisionType::Ground)
                InheritenceGroundImpact = Hit.ImpactPoint;

            // FVector CorrectedNormal = Hit.ImpactNormal;
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

            DepenetrationOffset = GetDepenetrationOffset(PredictedMove, Hit.ImpactNormal, Hit.ImpactPoint);

            TraceDirection = Hit.ImpactNormal;  
            PredictedMove += DepenetrationOffset;

            ImuplseForce -= ImuplseForce.ConstrainToDirection(-DepenetrationOffset.GetSafeNormal());

            //Must trace slightly smaller than the current radius so as not to get the same wall hit we just corrected against
            //Janky solution tbh, but seems to be stable with current setup
            System::SphereTraceSingle(PredictedMove, PredictedMove + TraceDirection, PlayerSphereComp.SphereRadius - 1, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, Hit, true, FLinearColor::Red);
        }

        Owner.ActorLocation = PredictedMove;
        
        if (SetRotation.IsNearlyZero())
            Owner.ActorRotation += AddRotations;
        else
            Owner.ActorRotation = SetRotation;

        if (bIsGrounded && InheritenceData.Comp == nullptr)
        {
            InheritedVelocity = FVector(0);
        }

        if (InheritenceData.Comp != nullptr)
        {
            InheritenceData.Comp.SetInheritenceData(Owner.ActorLocation);
        }

        if (bApplyCornerSlide)
            RunCornerSlideCheck();

        MoveThisFrame = Owner.ActorLocation - LastLoc;

        Velocity = FVector(0.0); 
        AddRotations = FRotator(0.0);
        SetRotation = FRotator(0.0);
    }

    //Returns depenetration vector offset for velocity based on impact point, predicted move and impact normal
    private FVector GetDepenetrationOffset(FVector CurrentPredictedMove, FVector ImpactNormal, FVector ImpactPoint)
    {
        //Total distance between impact point and predicted move location
        float Size = (ImpactPoint - CurrentPredictedMove).Size();

        //Check if predicted move location has passed the collision point - if so, reverse size so that we get the correct depth calculation
        //Passing collision point should add size amount, rather than minus from it.
        FVector HitToOrigin = (Owner.ActorLocation - ImpactPoint).GetSafeNormal();
        FVector HitToPredicted = (CurrentPredictedMove - ImpactPoint).GetSafeNormal();
        float NormalDot = HitToOrigin.DotProduct(HitToPredicted);
        if (NormalDot < 0.0)
        {
            Size = -Size;
        }
        
        //Depth is radius minus size
        float Depth = PlayerSphereComp.SphereRadius - Size;

        //Offset amount to remove from predicted move
        FVector PenetrationOffset = ImpactNormal * Depth;

        //Safety check - if depth is negative for some reason, return 0 for offset
        //This may not be needed anymore? Can't remember use case
        if (Depth <= 0.0)
            PenetrationOffset = FVector(0.0);

        // System::DrawDebugArrow(ImpactPoint, ImpactPoint + ImpactNormal * 300.0, 25.0, FLinearColor::Red, 0.0, 5.0);

        return PenetrationOffset;
    }

    //Adds corner slide offset to sphere
    private FVector GetCornerSlideOffset(float DeltaTime)
    {
        //Deals with going over slanted corners
        if (bShouldCornerApplySlide)
        {
            // System::DrawDebugArrow(Owner.ActorLocation, Owner.ActorLocation + (PredictedMove - LastSlideImpactPoint).GetSafeNormal() * 500.0, 2.0, FLinearColor::Yellow, 10, 5.0);

            FVector HitToPredicted = (PredictedMove - LastSlideImpactPoint).GetSafeNormal();
            FVector VRight = HitToPredicted.ConstrainToPlane(LastSlideImpactNormal).CrossProduct(HitToPredicted);
            FVector OffEdge = FVector::UpVector.CrossProduct(VRight); 
            
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
    private void RunCornerSlideCheck()
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
            if (Dot >= MovementCollisionSolveData::MinWalkableDot)
            {
               return true;
            }
        }

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
        if (IsGrounded() && GetGroundPlaneCalculation(CurrentVelocity.GetSafeNormal()).Size() > 0.0)
        {
            FVector UpV = GetGroundPlaneCalculation(CurrentVelocity.GetSafeNormal());
            FVector RightV = UpV.CrossProduct(CurrentVelocity);
            FVector ForwardV = RightV.CrossProduct(UpV);

            return ForwardV;
        }

        return CurrentVelocity;
    }

    //Traces for and returns ground plane normal - sphere trace however is weird. Change this later to line trace
    private FVector GetGroundPlaneCalculation(FVector MovementDirection)
    {
        FHitResult Hit;
        System::SphereTraceSingle(Owner.ActorLocation, Owner.ActorLocation - Owner.ActorUpVector, PlayerSphereComp.SphereRadius, ETraceTypeQuery::Visibility, false, FrameMoveIgnoreActors, EDrawDebugTrace::None, Hit, true, FLinearColor::Red);

        if (Hit.bBlockingHit)
        {
            //If we hit a corner, send last valid ground plane instead, or world up (assumed ground plane) if current internal ground plane is not yet set
            if (ImpactedCorner(MovementDirection, Hit))
            {
                if (InternalGroundPlane.Size() == 0.0)
                    InternalGroundPlane = FVector::UpVector;

                return InternalGroundPlane;
            }
            
            InternalGroundPlane = Hit.ImpactNormal;
            return InternalGroundPlane;
            // System::DrawDebugArrow(Hit.ImpactPoint, Hit.ImpactPoint + (Hit.ImpactNormal * 250.0), 25.0, FLinearColor::Red, 10.0, 5.0);
        }    

        return FVector(0.0);  
    }

    FVector GetGroundPlane()
    {
        return InternalGroundPlane;
    }

    //Check if we impacted a corner
    private bool ImpactedCorner(FVector MovementDirection, FHitResult Hit)
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
                    // System::DrawDebugArrow(TraceDownStart, CornerDownCheck.ImpactPoint, 0.5, FLinearColor::Blue, 10.0, 0.5);
                    // System::DrawDebugArrow(TraceForwardStart, CornerForwardCheck.ImpactPoint, 0.5, FLinearColor::Red, 10.0, 0.5);
                    // System::DrawDebugArrow(Hit.ImpactPoint, Hit.ImpactPoint + Hit.ImpactNormal * 200.0, 1.0, FLinearColor::Green, 10.0, 1.0);
                    return true;
                }
            }
        }

        return false;
    }

    //Gets valid hit (always defaults to first valid hit made)... just to make explicit what it picks up any given frame
    //Return true if we were updated
    bool UpdateTargetInheritMovementActor(AActor HitActor, UPrimitiveComponent HitComponent)
    {
        // auto Vol = UMovementInheritenceVolume::Get(HitActor);
        auto Comp = UMovementInheritenceComponent::Get(HitActor);

        if (Comp != nullptr) 
        {
            if (InheritenceData.Comp != Comp)
            {
                InheritenceData.Actor = HitActor;
                InheritenceData.Comp = Comp;
                InheritenceData.Comp.HitComponent = HitComponent;
                return true;
            }

            return false;
        }
        
        InheritenceData.Actor = nullptr;
        InheritenceData.Comp = nullptr;
        return false;
    }   
}
