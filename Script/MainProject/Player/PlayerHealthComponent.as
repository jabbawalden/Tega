event void FOnPlayerDeath();

class UPlayerHealthComponent : UActorComponent
{
    FOnPlayerDeath OnPlayerDeath;

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
            OnPlayerDeath.Broadcast();
        }
    }
}