event void FOnWeaponSlotFired();

class UWeaponSlotComponent : USceneComponent
{
    UPROPERTY()
    FOnWeaponSlotFired OnWeaponSlotFired;

    float CurrentOverheat;
    FWeaponSettings WeaponSettings;

    bool bHasWeapon;

    //Runs logic 
    //Sends back bool if module should deactivate
    bool RunWeaponActivationAndCheck()
    {
        return true;
    }
}