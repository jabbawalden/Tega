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
                WeaponSettings = SlotWeaponStats::GetBaseGattlingSettings();
                DataComp.SpawnWeaponSlot(EPrimaryWeaponSlotType::Gattling, this);
                bHasWeapon = true;
                break;
            case EPrimaryWeaponSlotType::Plasma:
                WeaponSettings = SlotWeaponStats::GetBasePlasmaSettings();
                bHasWeapon = true;
                break;
            case EPrimaryWeaponSlotType::AutoCannon:
                WeaponSettings = SlotWeaponStats::GetBaseAutoCannonSettings();
                bHasWeapon = true;
                break;
        }
    }
}