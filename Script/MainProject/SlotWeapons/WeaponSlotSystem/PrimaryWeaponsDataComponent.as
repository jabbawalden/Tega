class UPrimaryWeaponsDataComponent : UActorComponent
{
    UPROPERTY()
    TSubclassOf<AWPGattling> GattlingClass;
    AWPGattling Gattling;
    
    UPROPERTY()
    TSubclassOf<AWPPlasmaCannon> PlasmaCannonClass;
    AWPPlasmaCannon PlasmaCannon;

    UPROPERTY()
    TSubclassOf<AWPAutoCannon> AutoCannonClass;
    AWPAutoCannon AutoCannon;

    AActor CurrentPrimaryWeapon;

    void SpawnWeaponSlot(EPrimaryWeaponSlotType WeaponType, USceneComponent AttachComp)
    {
        if (CurrentPrimaryWeapon != nullptr)
            CurrentPrimaryWeapon.SetActorHiddenInGame(true);

        switch(WeaponType)
        {
            case EPrimaryWeaponSlotType::None:
                break;

            case EPrimaryWeaponSlotType::Gattling:
                if (Gattling == nullptr)
                    Gattling = Cast<AWPGattling>(SpawnActor(GattlingClass, AttachComp.WorldLocation, AttachComp.WorldRotation));
                CurrentPrimaryWeapon = Gattling; 
                break;

            case EPrimaryWeaponSlotType::Plasma:
                if (PlasmaCannon == nullptr)
                    PlasmaCannon = Cast<AWPPlasmaCannon>(SpawnActor(PlasmaCannonClass, AttachComp.WorldLocation, AttachComp.WorldRotation));
                CurrentPrimaryWeapon = PlasmaCannon; 
                break;

            case EPrimaryWeaponSlotType::AutoCannon:
                if (AutoCannon == nullptr)
                    AutoCannon = Cast<AWPAutoCannon>(SpawnActor(AutoCannonClass, AttachComp.WorldLocation, AttachComp.WorldRotation));
                CurrentPrimaryWeapon = AutoCannon; 
                break;
        }

        if (CurrentPrimaryWeapon != nullptr)
        {
            CurrentPrimaryWeapon.AttachToComponent(AttachComp);
            CurrentPrimaryWeapon.SetActorHiddenInGame(false);
        }
    }

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