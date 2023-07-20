class USlotWeaponDataComponent : UActorComponent
{
    UPROPERTY()
    USlotWeaponData WeaponData;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        SetWeaponData();
    }

    void SetWeaponData()
    {
        if (WeaponData.Gattling == nullptr)
            WeaponData.Gattling = Cast<ASWGattling>(SpawnActor(WeaponData.GattlingClass, FVector(0.0), FRotator(0.0)));
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
        }

        return SlotWeapon;
    }
}

class USlotWeaponData : UDataAsset
{
    UPROPERTY()
    TSubclassOf<ASWGattling> GattlingClass;
    ASWGattling Gattling;
}