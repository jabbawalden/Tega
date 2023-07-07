event void FOnWeaponSlotFired();

class UWeaponSlotComponent : USceneComponent
{
    UPROPERTY()
    FOnWeaponSlotFired OnWeaponSlotFired;

    float CurrentOverheat;
    FWeaponSettings WeaponSettings;

    bool bHasWeapon;
}