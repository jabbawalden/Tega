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
        WeaponSlotComp.OnWeaponSlotFired.AddUFunction(this, n"OnWeaponSlotFired");
        SetActorHiddenInGame(false);
    }

    void DisableWeapon()
    {
        SetActorHiddenInGame(true);
        if (WeaponSlotComp != nullptr)
            WeaponSlotComp.OnWeaponSlotFired.Clear();
    }

    UFUNCTION()
    private void OnWeaponSlotFired(FAimData AimData)
    {
        FireAttack(AimData);
    }

    protected void FireAttack(FAimData AimData)
    {
        //Spawn attack actor
    }
}