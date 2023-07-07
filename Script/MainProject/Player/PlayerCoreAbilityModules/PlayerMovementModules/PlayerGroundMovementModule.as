class UPlayerGroundMovementModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::CalculateMovement;

    default Tags.Add(n"Module");
    default Tags.Add(n"PlayerModule");
    default Tags.Add(n"PlayerGroundMovementModule");
    default Tags.Add(MovementTags::GroundMovement);
    default Tags.Add(PlayerGenericTags::Movement);

    APlayerVessel Player;
    UFrameMovementComponent MoveComp;

    FVector Velocity;

    // float MaxMoveSpeed = 1400.f;

    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
        MoveComp = UFrameMovementComponent::Get(Player);
    }

    bool ShouldActivate() override
    {
        return true;
    }

    bool ShouldDeactivate() override
    {
        return false;
    }

    void OnActivated() override
    {
        Velocity = Player.SavedMovementDirection * Player.MovementSpeed.GetValue();
    }

    void OnDeactivated() override
    {

    }

    void OnBlocked() override
    {

    }

    void OnUnblocked() override
    {
        
    }

    void Update(float DeltaTime) override
    {
        FVector TargetVelocity = Player.SavedMovementDirection * Player.MovementSpeed.GetValue();
        SetSavedInputAndSpeed(DeltaTime);

        Velocity = Math::VInterpTo(Velocity, TargetVelocity, DeltaTime, 8.f);
        Velocity = MoveComp.GetPlaneCorrectedVelocity(Velocity);

        PrintToScreen(f"{Velocity.Size()=}");

        FVector DeltaMoveOffset = Velocity * DeltaTime;
        MoveComp.AddDeltaVelocityToFrame(DeltaMoveOffset);
    }

    void SetSavedInputAndSpeed(float DeltaTime)
    {
        if (Player.GetStickVector(InputNames::LeftStickMovement).Size() > 0.f)
        {
            Player.SavedMovementDirection = Player.GetStickVector(InputNames::LeftStickMovement);
            Player.MovementSpeed.CalculateToTarget(Player.MovementSettings.MoveSpeed, DeltaTime, 0.4f);
        }
        else
        {
            Player.MovementSpeed.CalculateToTarget(0.f, DeltaTime, 0.1f);
        }
    }
}