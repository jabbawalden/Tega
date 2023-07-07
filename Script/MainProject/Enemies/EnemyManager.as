AEnemyManager GetEnemyManager()
{
    TArray<AEnemyManager> EnemyManagers;
    GetAllActorsOfClass(EnemyManagers);
    return EnemyManagers[0];
}

class AEnemyManager : AActor
{
    UPROPERTY()
    TArray<AEnemyBase> EnemiesArray;

    UFUNCTION(CallInEditor)
    void FillEnemyArray()
    {
        EnemiesArray.Empty();
        EnemiesArray = GetAllEnemies();
    }
    
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        for (AEnemyBase Enemy : EnemiesArray)
        {
            Enemy.HealthComp.OnEnemyManagerCallbackDeath.AddUFunction(this, n"OnDeath");
        }
    }

    TArray<AEnemyBase> GetActiveEnemies()
    {
        // TArray<AEnemyBase> EnemiesEmpty;
        return EnemiesArray;
    }

    UFUNCTION()
    void OnDeath(AActor KilledEnemy)
    {
        AEnemyBase EnemyBase = Cast<AEnemyBase>(KilledEnemy);

        if (EnemyBase != nullptr)
            EnemiesArray.Remove(EnemyBase);
    }
}