class UPlayerDashModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::CalculateMovement;

    default Tags.Add(n"Module");
    default Tags.Add(n"PlayerModule");
    default Tags.Add(MovementTags::Dash);
    default Tags.Add(PlayerGenericTags::Movement);

    APlayerVessel Player;
    UFrameMovementComponent MoveComp;

    float DashTime;
    float DashSpeed;
    float RecoveryTime;

    FVector DashVelocity;
    FVector DashDirectionTarget;
    FVector DashDirectionCurrent;
 
    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
        MoveComp = UFrameMovementComponent::Get(Player);
    }

    bool ShouldActivate() override
    {
        if (!Player.WasInputActioned(InputNames::FaceButtonLeft))
            return false;

        if (Gameplay::GetTimeSeconds() < RecoveryTime)
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (DashSpeed == 0.f)
            return true;
        
        return false;
    }

    void OnActivated() override
    {
        Player.BlockModule(PlayerGenericTags::CameraChase, this);
        DashSpeed = Player.MovementSettings.DashSpeed;

        DashTime = Player.MovementSettings.DashDuration;

        if (Player.GetStickVector(InputNames::LeftStickMovement).Size() != 0.f)
            DashDirectionTarget = Player.GetStickVector(InputNames::LeftStickMovement);
        else
            DashDirectionTarget = Player.CharacterRoot.WorldRotation.Vector();

        DashDirectionCurrent = DashDirectionTarget; 
        DashDirectionCurrent = MoveComp.GetPlaneCorrectedVelocity(DashDirectionCurrent);
    }

    void OnDeactivated() override
    {
        Player.UnblockModule(PlayerGenericTags::CameraChase, this);
        Player.SavedMovementDirection = DashDirectionCurrent;
        RecoveryTime = Gameplay::GetTimeSeconds() + Player.MovementSettings.DashRecoveryTime;
    }

    void Update(float DeltaTime) override
    {
        DashTime -= DeltaTime;

        if (Player.GetStickVector(InputNames::LeftStickMovement).Size() != 0.f)
            DashDirectionTarget = Player.GetStickVector(InputNames::LeftStickMovement);

        DashDirectionCurrent = Math::VInterpTo(DashDirectionCurrent, DashDirectionTarget, DeltaTime, 0.5f);
        DashDirectionCurrent = MoveComp.GetPlaneCorrectedVelocity(DashDirectionCurrent);

        DashVelocity = DashDirectionCurrent * DashSpeed * DeltaTime;
        MoveComp.AddDeltaVelocityToFrame(DashVelocity);

        if (DashTime <= 0.f)
        {
            DashSpeed -= Player.MovementSettings.DashDecceleration * DeltaTime;
            DashSpeed = Math::Clamp(DashSpeed, 0.f, Player.MovementSettings.DashSpeed);
        }
    }
}