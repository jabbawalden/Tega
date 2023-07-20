class UPlayerShootProjectileModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(n"PlayerShootProjectileModule");

    APlayerVessel Player;
    float Time;
    float Rate = 0.1f;
 
    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
    }

    bool ShouldActivate() override
    {
        if (Player.PlayerMovementState != EPlayerMovementState::Aiming)
            return false;

        if (!Player.IsInputActioning(InputNames::RightTrigger))
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (Player.PlayerMovementState != EPlayerMovementState::Aiming)
            return true;
        
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
        // FVector TEMPShootDir = Player.GetShootDirection(Player.ProjectileOrigin.WorldLocation);

        // if (System::GameTimeInSeconds > Time)
        // {
        //     Time = System::GameTimeInSeconds + Rate;

        //     // Player.SpawnProjectile(Player.ProjectileOrigin.WorldLocation, Player.GetConstrainedCameraForward());
        //     // Player.SpawnProjectile(Player.ProjectileOrigin.WorldLocation, Player.GetShootDirection());
        //     Player.SpawnProjectile(Player.ProjectileOrigin.WorldLocation, TEMPShootDir);
        // }
    }
}