class ASWGattling : ASlotWeapon
{
    default SlotType = EWeaponSlotType::Primary;

    UPROPERTY()
    TSubclassOf<AProjectileActor> ProjectileClass;

    void FireAttack(FAimData AimData) override
    {
        Super::FireAttack(AimData);
        FVector InitialDirection = (AimData.HitPoint - ShotOrigin.WorldLocation).GetSafeNormal();
        AProjectileActor Projectile = Cast<AProjectileActor>(SpawnActor(ProjectileClass, ShotOrigin.WorldLocation, InitialDirection.Rotation(), bDeferredSpawn = true));
        Projectile.InitiateProjectile(this, InitialDirection, AimData);
        FinishSpawningActor(Projectile);
    }
}