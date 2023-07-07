class AEnemyExtractor : AEnemyBase
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent EnemyCharacterRoot;

    UPROPERTY(DefaultComponent, Attach = EnemyCharacterRoot)
    UBoxComponent BoxComp;
    default BoxComp = SetEnemyBoxCollisionResponses(BoxComp);

    UPROPERTY(DefaultComponent, Attach = EnemyCharacterRoot)
    USceneComponent MeshRoot;

    ATegaGameMode TegaGameMode;

    AActor TargetActor;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        TegaGameMode = GetTegaGameMode();
        HealthComp.OnAIDeath.AddUFunction(this, n"OnDeath");
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {

    }

    UFUNCTION()
    void OnDeath()
    {
        MeshRoot.SetHiddenInGame(true, true);
        BoxComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
    }
}