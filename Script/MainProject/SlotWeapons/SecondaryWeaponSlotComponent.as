class USecondaryWeaponSlotComponent : UWeaponSlotComponent
{
    ESecondaryWeaponSlotType WeaponType;

    void UpdateSecondaryWeaponType(ESecondaryWeaponSlotType NewWeaponType)
    {
        WeaponType = NewWeaponType;
        UPrimaryWeaponsDataComponent DataComp = UPrimaryWeaponsDataComponent::Get(Owner);

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