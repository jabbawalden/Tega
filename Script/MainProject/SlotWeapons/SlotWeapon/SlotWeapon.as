class ASlotWeapon : AActor
{
    UPROPERTY()
    EWeaponSlotType SlotType;

    UPROPERTY()
    FWeaponSettings WeaponSettings;

    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent MeshRoot;

    void InitiateWeapon(FWeaponSettings NewWeaponSettings)
    {
        WeaponSettings = NewWeaponSettings;
        DisableWeapon();
    }

    void EnableWeapon()
    {
        SetActorHiddenInGame(false);
    }

    void DisableWeapon()
    {
        SetActorHiddenInGame(true);
    }

    void FireAttack()
    {
        //Spawn attack actor
    }
}