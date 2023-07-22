enum EWeaponSlotType
{
    Primary,
    Secondary
}

class UWeaponSlotComponent : USceneComponent
{
    UPROPERTY()
    EWeaponSlotType SlotType;

    float CurrentOverheat;
    
    ASlotWeapon ActiveWeapon;
    protected FWeaponData WeaponData;

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

        if (!bWeaponInUse && WeaponData.GetCurrentOverheat() > 0.0)
        {
            if (!WeaponData.GetOverheatCompletely())
                WeaponData.SetCurrentOverheat(WeaponData.GetCurrentOverheat() - WeaponData.OverheatNormalRecoveryPerSecond * DeltaSeconds);
            else
                WeaponData.SetCurrentOverheat(WeaponData.GetCurrentOverheat() - WeaponData.OverheatReducedRecoveryPerSecond * DeltaSeconds);

            if (WeaponData.GetCurrentOverheat() <= 0.0)
                WeaponData.SetOverheatCompletely(false);
        }
    }

    void SetWeapon(ESlotWeaponClassType Type)
    {
        //run here also in case set weapon is called first
        WeaponDataComp.SetWeaponData();
        ReplaceCurrentWeapon(WeaponDataComp.GetWeaponData(Type));
    }

    FWeaponData GetCurrentWeaponData()
    {
        return WeaponData;
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
        WeaponData = ActiveWeapon.GetWeaponData();
        ActiveWeapon.EnableWeapon(this);
        ActiveWeapon.AttachToComponent(this, NAME_None, EAttachmentRule::SnapToTarget);
        bHasWeapon = true;
    }

    //Runs logic 
    //Sends back bool if module should deactivate
    bool RunWeaponAndCheckDeactivation()
    {
        if (WeaponData.MaxRounds > 0 && WeaponData.GetCurrentRounds() >= WeaponData.MaxRounds)
        {
            WeaponData.SetCooldown(System::GameTimeInSeconds + WeaponData.Cooldown);
            return true;
        }

        FireWeaponCheck();

        if (WeaponData.GetOverheatCompletely())
            return true;

        return false;
    }

    //return if we should deactivate after fire
    void FireWeaponCheck()
    {
        if (System::GameTimeInSeconds >= WeaponData.GetFireTime())
        {
            WeaponData.SetFireTime(System::GameTimeInSeconds + WeaponData.FireRate);
            WeaponData.SetCurrentOverheat(WeaponData.GetCurrentOverheat() + WeaponData.OverheatPerFire);

            if (WeaponData.MaxRounds > 0)
                WeaponData.SetCurrentRounds(WeaponData.GetCurrentRounds() + 1);

            if (WeaponData.GetCurrentOverheat() >= 1.0)
            {
                WeaponData.SetOverheatCompletely(true);
            }

            ActiveWeapon.FireAttack(AimComp.GetAimData());
        }
    }

    bool CooldownComplete()
    {
        PrintToScreen(f"{WeaponData.GetCurrentCooldown()=}");
        return System::GameTimeInSeconds > WeaponData.GetCurrentCooldown();
    }

    void SetWeaponOnDeactivated()
    {
        WeaponData.SetCurrentRounds(0);
        WeaponData.SetFireTime(0.0);
        bWeaponInUse = false;
    }

    void SetWeaponOnActivated()
    {
        bWeaponInUse = true;
    }
}
