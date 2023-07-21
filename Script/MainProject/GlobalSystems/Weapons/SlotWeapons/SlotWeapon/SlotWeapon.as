class ASlotWeapon : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent MeshRoot;

    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent ShotOrigin;

    UPROPERTY()
    EWeaponSlotType SlotType;
    
    private FWeaponSettings WeaponSettings;
    UWeaponSlotComponent WeaponSlot;

    void InitiateWeapon(FWeaponSettings NewWeaponSettings)
    {
        WeaponSettings = NewWeaponSettings;
        DisableWeapon();
    }

    FWeaponSettings GetWeaponSettings()
    {
        return WeaponSettings;
    }

    void EnableWeapon(UWeaponSlotComponent AllotedWeaponSlot)
    {
        WeaponSlot = AllotedWeaponSlot;
        WeaponSlot.OnWeaponSlotFired.AddUFunction(this, n"OnWeaponSlotFired");
        SetActorHiddenInGame(false);
    }

    void DisableWeapon()
    {
        SetActorHiddenInGame(true);
        if (WeaponSlot != nullptr)
            WeaponSlot.OnWeaponSlotFired.Clear();
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