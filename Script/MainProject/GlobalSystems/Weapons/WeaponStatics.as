enum EDamageType
{
    Kinetic,
    Explosive,
    Plasma
}

struct FDamageData
{
    UPROPERTY()
    EDamageType DamageType;
    UPROPERTY()
    float Damage;
}