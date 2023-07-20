event void FOnWeaponSlotFired(FWeaponAimData AimData);

enum EWeaponSlotType
{
    Primary,
    Secondary
}

class UWeaponSlotComponent : USceneComponent
{
    UPROPERTY()
    FOnWeaponSlotFired OnWeaponSlotFired;

    UPROPERTY()
    EWeaponSlotType SlotType;

    float CurrentOverheat;
    
    ASlotWeapon ActiveWeapon;
    FWeaponSettings WeaponSettings;

    //Have weapon in this slot
    bool bHasWeapon;

    //Weapon is currently being used
    bool bWeaponInUse;

    UAimComponent AimComp;
    USlotWeaponDataComponent WeaponDataComp;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        AimComp = UAimComponent::Get(Owner);
        WeaponDataComp = USlotWeaponDataComponent::Get(Owner);

    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        // PrintToScreen(f"{WeaponSettings.GetCurrentRounds()=}");
        // PrintToScreen(f"{WeaponSettings.GetCurrentOverheat()=}");

        if (!bWeaponInUse && WeaponSettings.GetCurrentOverheat() > 0.0)
        {
            if (!WeaponSettings.GetOverheatCompletely())
                WeaponSettings.SetCurrentOverheat(WeaponSettings.GetCurrentOverheat() - WeaponSettings.OverheatNormalRecoveryPerSecond * DeltaSeconds);
            else
                WeaponSettings.SetCurrentOverheat(WeaponSettings.GetCurrentOverheat() - WeaponSettings.OverheatReducedRecoveryPerSecond * DeltaSeconds);

            if (WeaponSettings.GetCurrentOverheat() <= 0.0)
            {
                WeaponSettings.SetOverheatCompletely(false);
            }

        }
    }

    void SetWeapon(ESlotWeaponClassType Type)
    {
        //run here also in case set weapon is called first
        WeaponDataComp.SetWeaponData();
        ReplaceCurrentWeapon(WeaponDataComp.GetWeaponData(Type));
    }

    private void ReplaceCurrentWeapon(ASlotWeapon Weapon)
    {
        if (SlotType == Weapon.SlotType)
        {
            RemoveCurrentWeapon();
            SetActiveWeapon(Weapon);
        }
    }

    private void RemoveCurrentWeapon()
    {
        if (ActiveWeapon != nullptr)
            ActiveWeapon.DisableWeapon();
        
        ActiveWeapon = nullptr;
        bHasWeapon = false;
    }

    private void SetActiveWeapon(ASlotWeapon Weapon)
    {
        ActiveWeapon = Weapon;
        ActiveWeapon.EnableWeapon();
        ActiveWeapon.AttachToComponent(this, NAME_None, EAttachmentRule::SnapToTarget);
        bHasWeapon = true;
    }

    //Runs logic 
    //Sends back bool if module should deactivate
    bool RunWeaponAndCheckDeactivation()
    {
        if (WeaponSettings.MaxRounds > 0 && WeaponSettings.GetCurrentRounds() >= WeaponSettings.MaxRounds)
        {
            WeaponSettings.SetCooldown(System::GameTimeInSeconds + WeaponSettings.Cooldown);
            return true;
        }

        FireWeaponCheck();

        if (WeaponSettings.GetOverheatCompletely())
            return true;

        return false;
    }

    //return if we should deactivate after fire
    void FireWeaponCheck()
    {
        if (System::GameTimeInSeconds >= WeaponSettings.GetFireTime())
        {
            WeaponSettings.SetFireTime(System::GameTimeInSeconds + WeaponSettings.FireRate);
            WeaponSettings.SetCurrentOverheat(WeaponSettings.GetCurrentOverheat() + WeaponSettings.OverheatPerFire);

            if (WeaponSettings.MaxRounds > 0)
                WeaponSettings.SetCurrentRounds(WeaponSettings.GetCurrentRounds() + 1);

            if (WeaponSettings.GetCurrentOverheat() >= 1.0)
            {
                WeaponSettings.SetOverheatCompletely(true);
            }

            FWeaponAimData AimData;
            AimData.AimDirection = AimComp.GetAimDirection();
            AimData.AimStartPosition = AimComp.GetAimStartPosition();

            OnWeaponSlotFired.Broadcast(AimData); 
        }
    }

    bool CooldownComplete()
    {
        PrintToScreen(f"{WeaponSettings.GetCurrentCooldown()=}");
        return System::GameTimeInSeconds > WeaponSettings.GetCurrentCooldown();
    }

    void SetWeaponOnDeactivated()
    {
        WeaponSettings.SetCurrentRounds(0);
        WeaponSettings.SetFireTime(0.0);
        bWeaponInUse = false;
    }

    void SetWeaponOnActivated()
    {
        bWeaponInUse = true;
    }
}
