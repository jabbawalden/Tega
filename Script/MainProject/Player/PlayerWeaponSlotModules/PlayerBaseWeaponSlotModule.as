class UPlayerBaseWeaponSlotModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(n"WeaponSlot");

    APlayerVessel Player;
    UWeaponSlotComponent WeaponSlot;

    FName InputTag;

    bool bShouldDeactivate;
 
    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
    }

    bool ShouldActivate() override
    {
        if (!WeaponSlot.bHasWeapon)
            return false;

        if (!WeaponSlot.CooldownComplete())
        {
            return false;
        }

        if (WeaponSlot.GetCurrentWeaponData().GetOverheatCompletely())
            return false;

        if (!Player.WasInputActioned(InputTag))
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (!WeaponSlot.bHasWeapon)
            return true;

        if (WeaponSlot.GetCurrentWeaponData().WeaponInputType == EWeaponFireType::AutoFire)
        {
            if(!Player.IsInputActioning(InputTag))
                return true;
        }

        if (bShouldDeactivate)
            return true;

        if (WeaponSlot.GetCurrentWeaponData().GetOverheatCompletely())
            return true;

        return false;
    }

    void OnActivated() override
    {
        WeaponSlot.SetWeaponOnActivated();
        bShouldDeactivate = false;
    }

    void OnDeactivated() override
    {
        WeaponSlot.SetWeaponOnDeactivated();
    }

    void Update(float DeltaTime) override
    {
        bShouldDeactivate = WeaponSlot.RunWeaponAndCheckDeactivation();
    }
}