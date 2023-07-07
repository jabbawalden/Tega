class UCrystalRangedShootModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"CrystalRangedShootModule");

    ACrystalRanged Crystal;
    APlayerVessel Player;

    float Time;
    float Rate = 0.15f;

    void Setup() override
    {
        Crystal = Cast<ACrystalRanged>(Owner);
        Player = Cast<APlayerVessel>(Crystal.GetAttributeObject(n"Player"));
    }

    bool ShouldActivate() override
    {
        if (!Player.IsInputActioning(InputNames::RightTrigger))
            return false;

        // if (Player.PlayerCombatMode != EPlayerCombatMode::Projectile)
        //     return false;

        if (Crystal.CrystalState != ECrystalState::Default)
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (Crystal.CrystalState != ECrystalState::Default)
            return true;

        // if (Player.PlayerCombatMode != EPlayerCombatMode::Projectile)
        //     return true;

        if (Player.IsInputActioning(InputNames::RightTrigger))
            return false;
        
        return true;
    }

    void OnActivated() override
    {
        Time = 0.f;
    }

    void OnDeactivated() override
    {
        
    }

    void Update(float DeltaTime) override
    {
        FVector Dir = Player.ActorLocation - Crystal.ActorLocation;
        float Distance = Dir.Size();
        Dir.Normalize();
        FVector OffsetOrigin = Crystal.ActorLocation + Dir * Distance / 2.f;
        // System::DrawDebugSphere(OffsetOrigin, 20.f, 12, FLinearColor::Red, 0.f, 1.f);

        Time -= DeltaTime;

        if (Time <= 0.f)
        {
            Crystal.SpawnProjectile(Player.GetShootDirection(OffsetOrigin));
            Time = Rate;
        }
    } 
}