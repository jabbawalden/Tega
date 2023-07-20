class UPrimaryWeaponsDataComponent : UActorComponent
{
    UPROPERTY()
    TSubclassOf<AWPGattling> GattlingClass;
    AWPGattling Gattling;
    
    UPROPERTY()
    TSubclassOf<AWPPlasmaCannon> PlasmaCannonClass;
    AWPPlasmaCannon PulseCannon;

    UPROPERTY()
    TSubclassOf<AWPAutoCannon> AutoCannonClass;
    AWPAutoCannon AutoCannon;

    // void SetWeaponState(EPrimaryWeaponSlotType WeaponType, UWeaponSlotComponent WeaponSlotComp)
    // {
    //     auto Comp = UPrimaryWeaponSlotComponent::GetOrCreate(Owner);

    //     switch(WeaponType)
    //     {
    //         case EPrimaryWeaponSlotType::None:
    //             break;
    //         case EPrimaryWeaponSlotType::Gattling:
    //             break;
    //         case EPrimaryWeaponSlotType::Plasma:
    //             break;
    //         case EPrimaryWeaponSlotType::AutoCannon:
    //             break;
    //     }

    //     Comp.UpdatePrimaryWeaponType(WeaponType);
    // }
}