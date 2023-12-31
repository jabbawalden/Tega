class UPlayerGravityModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::CalculateMovement;

    default Tags.Add(n"PlayerGravityModule");
    default Tags.Add(MovementTags::GroundMovement);
    default Tags.Add(MovementTags::Gravity);
    default Tags.Add(PlayerGenericTags::Movement);

    APlayerVessel Player;
    UFrameMovementComponent MoveComp;
    TArray<AActor> IgnoreActors;
 
    float Gravity;

    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
        MoveComp = UFrameMovementComponent::Get(Player);
        IgnoreActors.Add(Player);
    }

    //NOT CURRENTLY IN USE - LOGIC MOVED TO MOVEMENT COMPONENT
    bool ShouldActivate() override
    {
        return false;

        // if (MoveComp.IsGrounded())
        //     return false;

        // return true;
    }

    bool ShouldDeactivate() override
    {
        if (MoveComp.IsGrounded())
            return true;
        
        return false;
    }

    void OnActivated() override
    {
        Gravity = 50.0;
    }

    void OnDeactivated() override
    {
        
    }

    void Update(float DeltaTime) override
    {
        // //Constrain gravity max to the least slope we are colliding against
        // //Probably move logic over to movement component and have it apply internally before the main move

        // Gravity = Math::FInterpConstantTo(Gravity, Player.MovementSettings.Gravity, DeltaTime, Player.MovementSettings.GravityAcceleration);
        
        // FVector Velocity;

        // // FHitResult Hit;
        // // FVector Start = Player.CharacterRoot.WorldLocation;
        // // FVector End = Start + -FVector::UpVector * MoveComp.Velocity.Size();
        // // System::SphereTraceSingle(Start, End, Player.SphereComp.SphereRadius, ETraceTypeQuery::Visibility, false, IgnoreActors, EDrawDebugTrace::None, Hit, true, FLinearColor::Red);
        
        // Velocity = FVector(0.f, 0.f, -Gravity * DeltaTime);
        // MoveComp.AddVelocityToFrame(Velocity);
    }   
}