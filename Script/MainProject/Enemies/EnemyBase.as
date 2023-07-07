//TODO Replace this with volumes to represent areas that add to the players list bit by bit
TArray<AEnemyBase> GetAllEnemies()
{
    TArray<AEnemyBase> EnemiesArray;
    GetAllActorsOfClass(EnemiesArray);
    return EnemiesArray;
}

class AEnemyBase : AModActor
{
    UPROPERTY(DefaultComponent)
    UAIBehaviourComponent BehaviourComp;

    UPROPERTY(DefaultComponent)
    UAIHealthComponent HealthComp;
}