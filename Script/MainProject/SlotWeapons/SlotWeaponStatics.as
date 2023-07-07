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
}

namespace PrimaryWeapons
{
    FWeaponSettings GetBaseGattlingSettings()
    {
        FWeaponSettings NewSettings;
        NewSettings.Damage = 3.5;
        NewSettings.FireRate = 0.075;
        NewSettings.OverheatPerFire = 0.01;

        return NewSettings;
    }

    FWeaponSettings GetBasePlasmaSettings()
    {
        FWeaponSettings NewSettings;
        NewSettings.Damage = 10.0;
        NewSettings.FireRate = 0.2;
        NewSettings.OverheatPerFire = 0.02;

        return NewSettings;
    }

    FWeaponSettings GetBaseAutoCannonSettings()
    {
        FWeaponSettings NewSettings;
        NewSettings.Damage = 15.0;
        NewSettings.FireRate = 0.2;
        NewSettings.OverheatPerFire = 0.02;

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
        NewSettings.FireRate = 0.075;
        NewSettings.OverheatPerFire = 0.5;

        return NewSettings;
    }

    FWeaponSettings GetBaseMissileLauncherSettings()
    {
        FWeaponSettings NewSettings;
        NewSettings.Damage = 15.0;
        NewSettings.FireRate = 0.4;
        NewSettings.OverheatPerFire = 0.2;

        return NewSettings;
    }

    FWeaponSettings GetBasePulseBeamSettings()
    {
        FWeaponSettings NewSettings;
        NewSettings.WeaponInputType = EWeaponFireType::OneShot;
        NewSettings.Damage = 50.0;
        NewSettings.FireRate = 0.2;
        NewSettings.OverheatPerFire = 0.5;

        return NewSettings;
    }
}