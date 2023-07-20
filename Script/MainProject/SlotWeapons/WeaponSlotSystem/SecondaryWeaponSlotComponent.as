class USecondaryWeaponSlotComponent : UWeaponSlotComponent
{
    ESecondaryWeaponSlotType WeaponType;
    USecondaryWeaponsDataComponent DataComp;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        DataComp = USecondaryWeaponsDataComponent::Get(Owner);
    }

    void UpdateSecondaryWeaponType(ESecondaryWeaponSlotType NewWeaponType)
    {
        WeaponType = NewWeaponType;

        switch(WeaponType)
        {
            case ESecondaryWeaponSlotType::None:
                bHasWeapon = false;
                break;
            case ESecondaryWeaponSlotType::Blaster:
                WeaponSettings = SecondaryWeapons::GetBaseBlasterSettings();
                bHasWeapon = true;
                break;
            case ESecondaryWeaponSlotType::MissileLauncher:
                WeaponSettings = SecondaryWeapons::GetBaseMissileLauncherSettings();
                bHasWeapon = true;
                break;
            case ESecondaryWeaponSlotType::PulseBeam:
                WeaponSettings = SecondaryWeapons::GetBasePulseBeamSettings();
                bHasWeapon = true;
                break;
        }
    }
}