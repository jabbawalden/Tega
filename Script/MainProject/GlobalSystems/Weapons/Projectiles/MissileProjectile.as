class AMissileProjectile : AProjectileActor
{
    default DamageData.Damage = 1.0;
    default DamageData.DamageType = EDamageType::Kinetic;
    default ProjectileData.MoveSpeed = 4000.0;
    default ProjectileData.LifeTime = 3.5;

    float FollowCorrectionInterp = 2.0;

    FVector TargetDirection;

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime)
    {
        Super::Tick(DeltaTime);

        if (AimData.Target != nullptr)
        {
            auto LockOnComp = ULockOnComponent::Get(AimData.Target.Owner);

            System::DrawDebugLine(ActorLocation, ActorLocation + TargetDirection * 5000.0, FLinearColor::Red, 0, 2.0);

            if (LockOnComp != nullptr)
                TargetDirection = (AimData.Target.WorldLocation - ActorLocation).GetSafeNormal();
            else
                TargetDirection = (AimData.HitPoint - ActorLocation).GetSafeNormal();

            
            ProjectileData.MoveDirection = Math::VInterpTo(ProjectileData.MoveDirection, TargetDirection, DeltaTime, FollowCorrectionInterp).GetSafeNormal();
        }

        ActorLocation += ProjectileData.MoveDirection * ProjectileData.MoveSpeed * DeltaTime;
        ActorRotation = ProjectileData.MoveDirection.Rotation();
    }
}