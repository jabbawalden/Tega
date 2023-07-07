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
 
    float GroundOffsetTarget = 80.f;
    float Gravity;

    bool bGrounded;

    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
        MoveComp = UFrameMovementComponent::Get(Player);
        IgnoreActors.Add(Player);
    }

    bool ShouldActivate() override
    {
        if (MoveComp.IsGrounded())
            return false;

        return true;
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
        Gravity = Math::FInterpConstantTo(Gravity, Player.MovementSettings.Gravity, DeltaTime, Player.MovementSettings.GravityAcceleration);
        
        FVector Velocity;

        FHitResult Hit;
        FVector Start = Player.CharacterRoot.WorldLocation;
        FVector End = Start + -FVector::UpVector * MoveComp.Velocity.Size();
        System::SphereTraceSingle(Start, End, Player.SphereComp.SphereRadius, ETraceTypeQuery::Visibility, false, IgnoreActors, EDrawDebugTrace::None, Hit, true, FLinearColor::Red);
        
        Velocity = FVector(0.f, 0.f, -Gravity * DeltaTime);
        MoveComp.AddDeltaVelocityToFrame(Velocity);
    }   
}