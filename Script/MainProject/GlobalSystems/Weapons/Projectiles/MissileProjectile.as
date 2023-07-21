class AMissileProjectile : AProjectileActor
{
    default DamageData.Damage = 1.0;
    default DamageData.DamageType = EDamageType::Kinetic;
    default ProjectileData.MoveSpeed = 4000.0;
    default ProjectileData.LifeTime = 3.5;

    float FollowCorrectionInterp = 2.0;

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime)
    {
        Super::Tick(DeltaTime);

        if (AimData.Target != nullptr)
        {
            FVector TargetDirection = (AimData.Target.WorldLocation - ActorLocation).GetSafeNormal();
            System::DrawDebugLine(ActorLocation, ActorLocation + TargetDirection * 5000.0, FLinearColor::Red, 0, 2.0);
            ProjectileData.MoveDirection = Math::VInterpTo(ProjectileData.MoveDirection, TargetDirection, DeltaTime, FollowCorrectionInterp).GetSafeNormal();
        }

        ActorLocation += ProjectileData.MoveDirection * ProjectileData.MoveSpeed * DeltaTime;
    }
}