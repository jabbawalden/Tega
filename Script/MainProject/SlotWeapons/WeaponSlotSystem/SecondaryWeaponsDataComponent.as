class USecondaryWeaponsDataComponent : UActorComponent
{
    UPROPERTY()
    TSubclassOf<AWSBlasterCannon> BlasterCannonClass;
    AWSBlasterCannon BlasterCannon;
    
    UPROPERTY()
    TSubclassOf<AWSMissileLauncher> MissileLauncherClass;
    AWSMissileLauncher MissileLauncher;

    UPROPERTY()
    TSubclassOf<AWSPulseBeam> PulseBeamClass;
    AWSPulseBeam PulseBeam;

    // void SetWeaponState(ESecondaryWeaponSlotType WeaponType, UWeaponSlotComponent WeaponSlotComp)
    // {
    //     auto Comp = USecondaryWeaponSlotComponent::GetOrCreate(Owner);

    //     switch(WeaponType)
    //     {
    //         case ESecondaryWeaponSlotType::None:
    //             break;
    //         case ESecondaryWeaponSlotType::Blaster:
    //             break;
    //         case ESecondaryWeaponSlotType::MissileLauncher:
    //             break;
    //         case ESecondaryWeaponSlotType::PulseBeam:
    //             break;
    //     }

    //     Comp.UpdateSecondaryWeaponType(WeaponType);
    // }
}