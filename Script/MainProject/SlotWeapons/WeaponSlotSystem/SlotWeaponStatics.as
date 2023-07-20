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

struct FWeaponSettings  
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

namespace PrimaryWeapons
{
    FWeaponSettings GetBaseGattlingSettings() 
    {
        FWeaponSettings NewSettings;
        NewSettings.Damage = 3.5;
        NewSettings.FireRate = 0.075;
        NewSettings.OverheatPerFire = 0.015;

        return NewSettings;
    }

    FWeaponSettings GetBasePlasmaSettings()
    {
        FWeaponSettings NewSettings;
        NewSettings.Damage = 10.0;
        NewSettings.FireRate = 0.15;
        NewSettings.OverheatPerFire = 0.03;

        return NewSettings;
    }

    FWeaponSettings GetBaseAutoCannonSettings()
    {
        FWeaponSettings NewSettings;
        NewSettings.Damage = 15.0;
        NewSettings.FireRate = 0.2;
        NewSettings.OverheatPerFire = 0.05;

        return NewSettings;
    }
}

namespace SecondaryWeapons
{
    FWeaponSettings GetBaseBlasterSettings()
    {
        FWeaponSettings NewSettings;
        NewSettings.WeaponInputType = EWeaponFireType::OneShot;
        NewSettings.Damage = 100.0;
        NewSettings.FireRate = 0.0;
        NewSettings.OverheatPerFire = 0.25;
        NewSettings.MaxRounds = 1;
        NewSettings.Cooldown = 0.8;

        return NewSettings;
    }

    FWeaponSettings GetBaseMissileLauncherSettings()
    {
        FWeaponSettings NewSettings;
        NewSettings.WeaponInputType = EWeaponFireType::OneShot;
        NewSettings.Damage = 15.0;
        NewSettings.FireRate = 0.1;
        NewSettings.OverheatPerFire = 0.05;
        NewSettings.MaxRounds = 6;
        //Max amount of firerate + a buffer
        NewSettings.Cooldown = 0.2;

        return NewSettings;
    }

    FWeaponSettings GetBasePulseBeamSettings()
    {
        FWeaponSettings NewSettings;
        NewSettings.WeaponInputType = EWeaponFireType::OneShot;
        NewSettings.Damage = 50.0;
        NewSettings.FireRate = 0.0;
        NewSettings.MaxRounds = 1;
        NewSettings.OverheatPerFire = 0.5;
        NewSettings.Cooldown = 1.0;

        return NewSettings;
    }
}