class UPlayerAirBoostRecoveryModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::CalculateMovement;

    default Tags.Add(n"Module");
    default Tags.Add(PlayerGenericTags::Movement);

    APlayerVessel Player;
    float RecoveryAmount = 0.f;
 
    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
    }

    bool ShouldActivate() override
    {
        if (Player.IsInputActioning(InputNames::FaceButtonBottom))
            return false;

        if (Player.CurrentBoost == Player.MaxBoost)
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (Player.IsInputActioning(InputNames::FaceButtonBottom))
            return true;

        if (Player.CurrentBoost == Player.MaxBoost)
            return true;

        return false;
    }

    void OnActivated() override
    {
        RecoveryAmount = 0.f;
    }

    void Update(float DeltaTime) override
    {
        RecoveryAmount = Math::FInterpConstantTo(RecoveryAmount, Player.BoostRecoveryAmount, DeltaTime, Player.BoostRecoveryAmount * 0.6f);
        Player.CurrentBoost += RecoveryAmount * DeltaTime;
        Player.CurrentBoost = Math::Clamp(Player.CurrentBoost, 0.f, Player.MaxBoost);
    }
}