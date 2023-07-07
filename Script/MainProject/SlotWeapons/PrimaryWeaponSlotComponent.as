class UPrimaryWeaponSlotComponent : UWeaponSlotComponent
{
    EPrimaryWeaponSlotType WeaponType;

    void UpdatePrimaryWeaponType(EPrimaryWeaponSlotType NewWeaponType)
    {
        WeaponType = NewWeaponType;
        UPrimaryWeaponsDataComponent DataComp = UPrimaryWeaponsDataComponent::Get(Owner);

        switch(WeaponType)
        {
            case EPrimaryWeaponSlotType::None:
                bHasWeapon = false;
                break;
            case EPrimaryWeaponSlotType::Gattling:
                WeaponSettings = PrimaryWeapons::GetBaseGattlingSettings();
                bHasWeapon = true;
                break;
            case EPrimaryWeaponSlotType::Plasma:
                WeaponSettings = PrimaryWeapons::GetBasePlasmaSettings();
                bHasWeapon = true;
                break;
            case EPrimaryWeaponSlotType::AutoCannon:
                WeaponSettings = PrimaryWeapons::GetBaseAutoCannonSettings();
                bHasWeapon = true;
                break;
        }
    }
}