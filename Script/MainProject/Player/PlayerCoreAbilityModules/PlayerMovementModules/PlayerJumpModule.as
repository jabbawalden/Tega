class UPlayerJumpModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::CalculateMovement;

    default Tags.Add(n"Module");
    default Tags.Add(PlayerGenericTags::Movement);

    APlayerVessel Player;
    UFrameMovementComponent MoveComp;

    float Impulse = 800.0;

    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
        MoveComp = UFrameMovementComponent::Get(Player);
    }

    bool ShouldActivate() override
    {
        if (!Player.WasInputActioned(InputNames::FaceButtonBottom))
            return false;

        if (!MoveComp.IsGrounded())
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
            return true;
    }

    void OnActivated() override
    {
        Super::OnActivated();
    }

    void OnDeactivated() override
    {
        Super::OnDeactivated();
    }

    void Update(float DeltaTime) override
    {
        MoveComp.AddImpulse(FVector(0.f, 0.f, Impulse));
    }
}