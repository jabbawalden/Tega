class USlotWeaponDataComponent : UActorComponent
{
    UPROPERTY()
    USlotWeaponData WeaponData;

    bool bWeaponDataSet = false;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        SetWeaponData();
    }

    void SetWeaponData()
    {
        if (bWeaponDataSet)
            return;

        if (WeaponData.Gattling == nullptr)
        {
            WeaponData.Gattling = Cast<ASWGattling>(SpawnActor(WeaponData.GattlingClass, FVector(0.0), FRotator(0.0)));
            WeaponData.Gattling.InitiateWeapon(SlotWeaponStats::GetBaseGattlingSettings());
        }

        if (WeaponData.MissileLauncher == nullptr)
        {
            WeaponData.MissileLauncher = Cast<ASWMissileLauncher>(SpawnActor(WeaponData.MissileLauncherClass, FVector(0.0), FRotator(0.0)));
            WeaponData.MissileLauncher.InitiateWeapon(SlotWeaponStats::GetBaseMissileLauncherSettings());
        }

        bWeaponDataSet = true;
    }

    ASlotWeapon GetWeaponData(ESlotWeaponClassType WeaponClass)
    {
        ASlotWeapon SlotWeapon = nullptr;

        switch(WeaponClass)
        {
            case ESlotWeaponClassType::None:
                break;           
            case ESlotWeaponClassType::Gattling:
                SlotWeapon = WeaponData.Gattling;
                break;     
            case ESlotWeaponClassType::MissileLauncher:
                SlotWeapon = WeaponData.MissileLauncher;
                break;     
        }

        return SlotWeapon;
    }
}

class USlotWeaponData : UDataAsset
{
    UPROPERTY()
    TSubclassOf<ASWGattling> GattlingClass;
    ASWGattling Gattling;

    UPROPERTY()
    TSubclassOf<ASWMissileLauncher> MissileLauncherClass;
    ASWMissileLauncher MissileLauncher;
}