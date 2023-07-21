class ASWMissileLauncher : ASlotWeapon
{
    default SlotType = EWeaponSlotType::Secondary;

    UPROPERTY()
    TSubclassOf<AProjectileActor> ProjectileClass;

    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent ShotOrigin1;
    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent ShotOrigin2;
    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent ShotOrigin3;
    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent ShotOrigin4;
    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent ShotOrigin5;
    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent ShotOrigin6;

    void FireAttack(FAimData AimData) override
    {
        Super::FireAttack(AimData);

        USceneComponent Origin = ShotOrigin1; 

        Print(f"{WeaponSlotComp.GetCurrentWeaponData().GetCurrentRounds()=}");

        switch (WeaponSlotComp.GetCurrentWeaponData().GetCurrentRounds())
        {
            case 1:
                Origin = ShotOrigin1;
                break;
            case 2:
                Origin = ShotOrigin2;
                break;
            case 3:
                Origin = ShotOrigin3;
                break;
            case 4:
                Origin = ShotOrigin4;
                break;
            case 5:
                Origin = ShotOrigin5;
                break;
            case 6:
                Origin = ShotOrigin6;
                break;
        }

        AProjectileActor Projectile = Cast<AProjectileActor>(SpawnActor(ProjectileClass, Origin.WorldLocation, Origin.WorldRotation, bDeferredSpawn = true));
        Projectile.InitiateProjectile(this, Origin.ForwardVector, AimData);
        FinishSpawningActor(Projectile);
    }
}