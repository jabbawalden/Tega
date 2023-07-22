class ASlotWeapon : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent MeshRoot;

    UPROPERTY()
    EWeaponSlotType SlotType;
    
    private FWeaponData WeaponSettings;
    UWeaponSlotComponent WeaponSlotComp;

    void InitiateWeapon(FWeaponData NewWeaponData)
    {
        WeaponSettings = NewWeaponData;
        DisableWeapon();
    }

    FWeaponData GetWeaponData()
    {
        return WeaponSettings;
    }

    void EnableWeapon(UWeaponSlotComponent AllotedWeaponSlot)
    {
        WeaponSlotComp = AllotedWeaponSlot;
        SetActorHiddenInGame(false);
    }

    void DisableWeapon()
    {
        SetActorHiddenInGame(true);
        WeaponSlotComp = nullptr;
    }

    //Function to override
    void FireAttack(FAimData AimData)
    {
    }
}