class AGattlingProjectile : AProjectileActor
{
    default DamageData.Damage = 1.0;
    default DamageData.DamageType = EDamageType::Kinetic;
    default ProjectileData.MoveSpeed = 10000.0;
    default ProjectileData.LifeTime = 1.5;

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime)
    {
        Super::Tick(DeltaTime);
        ActorLocation += ProjectileData.MoveDirection * ProjectileData.MoveSpeed * DeltaTime;
    }
}