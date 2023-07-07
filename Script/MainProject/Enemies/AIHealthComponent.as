event void FOnAIDeath();
event void FOnAIManagerCallbackDeath(AActor KilledEnemy);

class UAIHealthComponent : UActorComponent
{
    FOnAIDeath OnAIDeath;
    FOnAIManagerCallbackDeath OnEnemyManagerCallbackDeath;

    UPROPERTY()
    float MaxHealth = 1.f;
    
    private float Health;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Health = MaxHealth;
    }

    void DealDamage(float Damage)
    {
        Health -= Damage;

        if (Health <= 0.f)
        {
            OnAIDeath.Broadcast();
            OnEnemyManagerCallbackDeath.Broadcast(Owner);
        }
    }

    bool IsAlive()
    {
        return Health > 0.f;
    }
}