class UPlayerBaseWeaponSlotModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(n"WeaponSlot");

    APlayerVessel Player;
    UWeaponSlotComponent WeaponSlot;

    FName InputTag;
 
    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
    }

    bool ShouldActivate() override
    {
        if (!WeaponSlot.bHasWeapon)
            return false;

        if (!Player.WasInputActioned(InputTag))
            return false;
        
        if (WeaponSlot.CurrentOverheat >= 1.0)
            return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (!WeaponSlot.bHasWeapon)
            return true;

        if (WeaponSlot.WeaponSettings.WeaponInputType == EWeaponFireType::AutoFire)
        {
            if(!Player.IsInputActioning(InputTag))
                return true;
        }
        else
        {
            return true;
        }

        if (WeaponSlot.CurrentOverheat >= 1.0)
            return true;

        return false;
    }

    void OnActivated() override
    {
        
    }

    void OnDeactivated() override
    {
        
    }

    void Update(float DeltaTime) override
    {

    }
}