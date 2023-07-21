enum ESlotWeaponClassType
{
    None,
    Gattling,
    Plasma,
    AutoCannon,
    Blaster,
    MissileLauncher,
    PulseBeam
}

enum EPrimaryWeaponSlotType
{
    None,
    Gattling,
    Plasma,
    AutoCannon
}

enum ESecondaryWeaponSlotType
{
    None,
    Blaster,
    MissileLauncher,
    PulseBeam
}

enum EWeaponFireType
{
    AutoFire,
    OneShot
}

struct FWeaponData  
{
    EWeaponFireType WeaponInputType;
    float FireRate = 0.5;
    float Damage = 1.0;
    float OverheatPerFire = 0.15;
    float OverheatNormalRecoveryPerSecond = 0.25;
    float OverheatReducedRecoveryPerSecond = 0.1;
    int MaxRounds = 0;
    float Cooldown = 0.0;

    private int CurrentRounds;
    private float CurrentFireTime;
    private float CurrentCooldownTime;    
    private float CurrentOverheat;
    private bool bOverheatedCompletely;

    void SetCurrentRounds(int Rounds)
    {
        CurrentRounds = Rounds;
    }

    int GetCurrentRounds()
    {
        return CurrentRounds;
    }

    void SetFireTime(float NewFireTime)
    {
        CurrentFireTime = NewFireTime;
    }

    float GetFireTime()
    {
        return CurrentFireTime;
    }

    void SetCooldown(float NewCooldown)
    {
        CurrentCooldownTime = NewCooldown;
    }

    float GetCurrentCooldown()
    {
        return CurrentCooldownTime;
    }

    void SetCurrentOverheat(float NewOverheat)
    {
        CurrentOverheat = NewOverheat;
        CurrentOverheat = Math::Clamp(CurrentOverheat, 0, 1);
    }

    float GetCurrentOverheat()
    {
        return CurrentOverheat;
    }

    void SetOverheatCompletely(bool bOverheated)
    {
        bOverheatedCompletely = bOverheated;
    }

    bool GetOverheatCompletely()
    {
        return bOverheatedCompletely;
    }
}

namespace SlotWeaponStats
{
    FWeaponData GetBaseGattlingSettings() 
    {
        FWeaponData NewData;
        NewData.WeaponInputType = EWeaponFireType::AutoFire;
        NewData.Damage = 3.5;
        NewData.FireRate = 0.05;
        NewData.OverheatPerFire = 0.015;

        return NewData;
    }

    FWeaponData GetBasePlasmaSettings()
    {
        FWeaponData NewData;
        NewData.Damage = 10.0;
        NewData.FireRate = 0.15;
        NewData.OverheatPerFire = 0.03;

        return NewData;
    }

    FWeaponData GetBaseAutoCannonSettings()
    {
        FWeaponData NewData;
        NewData.Damage = 15.0;
        NewData.FireRate = 0.2;
        NewData.OverheatPerFire = 0.05;

        return NewData;
    }

    FWeaponData GetBaseBlasterSettings()
    {
        FWeaponData NewData;
        NewData.WeaponInputType = EWeaponFireType::OneShot;
        NewData.Damage = 100.0;
        NewData.FireRate = 0.0;
        NewData.OverheatPerFire = 0.25;
        NewData.MaxRounds = 1;
        NewData.Cooldown = 0.8;

        return NewData;
    }

    FWeaponData GetBaseMissileLauncherSettings()
    {
        FWeaponData NewData;
        NewData.WeaponInputType = EWeaponFireType::OneShot;
        NewData.Damage = 15.0;
        NewData.FireRate = 0.1;
        NewData.OverheatPerFire = 0.05;
        NewData.MaxRounds = 6;
        //Max amount of firerate + a buffer
        NewData.Cooldown = 0.2;

        return NewData;
    }

    FWeaponData GetBasePulseBeamSettings()
    {
        FWeaponData NewData;
        NewData.WeaponInputType = EWeaponFireType::OneShot;
        NewData.Damage = 50.0;
        NewData.FireRate = 0.0;
        NewData.MaxRounds = 1;
        NewData.OverheatPerFire = 0.5;
        NewData.Cooldown = 1.0;

        return NewData;
    }
}

namespace SecondaryWeapons
{

}