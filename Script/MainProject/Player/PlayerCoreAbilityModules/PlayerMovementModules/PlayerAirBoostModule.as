class UPlayerAirBoostModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::CalculateMovement;

    default Tags.Add(n"Module");
    default Tags.Add(PlayerGenericTags::Movement);

    APlayerVessel Player;
    UFrameMovementComponent MoveComp;

    float Impulse;
    float ImpulseTarget = 20.f;

    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
        MoveComp = UFrameMovementComponent::Get(Player);
    }

    bool ShouldActivate() override
    {
        // return false;
        
        if (!Player.WasInputActioned(InputNames::FaceButtonBottom))
            return false;

        if (Player.CurrentBoost == 0.f)
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (!Player.IsInputActioning(InputNames::FaceButtonBottom))
            return true;

        if (Player.CurrentBoost == 0.f)
            return true;

        return false;
    }

    void OnActivated() override
    {
        Super::OnActivated();
        Impulse = ImpulseTarget * 0.75f;
        MoveComp.DisableGravity();
        Player.BlockModule(MovementTags::Gravity, this);
    }

    void OnDeactivated() override
    {
        Super::OnDeactivated();
        MoveComp.EnableGravity();
        Player.UnblockModule(MovementTags::Gravity, this);
    }

    void Update(float DeltaTime) override
    {
        // Player.CurrentBoost -= Player.BoostDeductAmount * DeltaTime;
        Player.CurrentBoost = Math::Clamp(Player.CurrentBoost, 0.f, Player.MaxBoost);

        Impulse = Math::FInterpTo(Impulse, ImpulseTarget, DeltaTime, 0.3f);
        MoveComp.AddImpulse(FVector(0.f, 0.f, Impulse * DeltaTime));
    }
}