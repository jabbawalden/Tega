class UCrystalRangedBoomerangModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"CrystalRangedBoomerangModule");

    ACrystalRanged Crystal;
    APlayerVessel Player;

    FVector TargetLocation;
    FVector Velocity;
    
    TArray<AEnemyBase> TargetEnemyArray;

    float Speed = 4500.f;

    bool bReturnToPlayer;

    void Setup() override
    {
        Crystal = Cast<ACrystalRanged>(Owner);
        Player = Cast<APlayerVessel>(Crystal.GetAttributeObject(n"Player"));
    }

    bool ShouldActivate() override
    {
        if (Crystal.CrystalState != ECrystalState::BoomerangMoving)
            return false;

        // if (GetClosestEnemy() == nullptr)
        //     return false;

        return true;
    }

    bool ShouldDeactivate() override
    {
        if (WithinRange() && bReturnToPlayer)
            return true;
        
        return false;
    }

    void OnActivated() override
    {
        bReturnToPlayer = false;

        TargetEnemyArray = Crystal.EnemyArray;
        
        if (Crystal.EnemyArray.Num() > 0)
        {
            Crystal.BoomerangTargetEnemy = GetClosestEnemy();
            //Fly to each closest
        }
        else
        {
            //Fly forward, then back
        }

        Crystal.BP_EnableBoomerangMesh();
    }

    void OnDeactivated() override
    {
        Crystal.BP_DisableBoomerangMesh();
        Crystal.CrystalState = ECrystalState::Default;

        // if (Player.PlayerCombatMode == EPlayerCombatMode::Boomerang)
        //     Crystal.ActivateBoomerangReady();
        // else if (Player.PlayerCombatMode == EPlayerCombatMode::Projectile)
        //     Crystal.ActivateDefault();
    }

    void Update(float DeltaTime) override
    {
        Crystal.BoomerangRoot.AddLocalRotation(FRotator(0.f, 2850.f * DeltaTime, 0.f));
        
        if (Crystal.BoomerangTargetEnemy != nullptr)
        {
            TargetLocation = Crystal.BoomerangTargetEnemy.ActorLocation;
        }
        else
        {
            bReturnToPlayer = true;
            TargetLocation = Player.GetCrystalPosition(Crystal.FollowPosition);
        }

        FVector Direction = TargetLocation - Crystal.ActorLocation;
        Direction.Normalize();
        Velocity = Direction * Speed * DeltaTime;

        if (GetDistanceToTarget() <= Velocity.Size())
        {
            //If there is a target enemy
            if (Crystal.BoomerangTargetEnemy != nullptr)
            {
                HitEnemy();
                Crystal.BoomerangTargetEnemy = GetClosestEnemy();
                return;
            }
        } 

        Crystal.ActorLocation += Velocity;
    }

    AEnemyBase GetClosestEnemy()
    {
        float ClosestDistance = 6000000000.f;
        AEnemyBase ReturnEnemy = nullptr;

        for (AEnemyBase Enemy : TargetEnemyArray)
        {
            float Distance = (Enemy.ActorLocation - Crystal.ActorLocation).Size();

            if (Distance < ClosestDistance)
            {
                ReturnEnemy = Enemy;
                ClosestDistance = Distance;
            }
        }

        return ReturnEnemy;
    } 

    void HitEnemy()
    {
        Crystal.BoomerangTargetEnemy.BehaviourComp.SetStunned();
        TargetEnemyArray.Remove(Crystal.BoomerangTargetEnemy);
    }

    bool WithinRange()
    {
        if (GetDistanceToTarget() < Velocity.Size())
            return true;

        return false;
    }

    float GetDistanceToTarget()
    {
        return (TargetLocation - Crystal.ActorLocation).Size();
    }
}