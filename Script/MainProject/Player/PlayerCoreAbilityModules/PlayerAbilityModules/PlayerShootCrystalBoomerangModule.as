class UPlayerShootCrystalBoomerangModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(n"PlayerShootCrystalBoomerangModule");

    APlayerVessel Player;
 
    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
    }

    bool ShouldActivate() override
    {
        // if (Player.PlayerCombatMode != EPlayerCombatMode::Boomerang)
        //     return false;
    
        if (!Player.WasInputActioned(InputNames::RightShoulder))
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        return true;
    }

    void OnActivated() override
    {
        ACrystalRanged Crystal = Player.GetAvailableCrystalForBoomerang();

        if (Crystal != nullptr)
            Crystal.ActivateBoomerangMovement(Player.GetInViewEnemies());
    }

    void OnDeactivated() override
    {
        
    }

    void Update(float DeltaTime) override
    {

    }
}