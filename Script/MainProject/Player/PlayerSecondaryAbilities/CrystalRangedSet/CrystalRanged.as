enum ECrystalState
{
    Default,
    BoomerangMoving,
    Turret,
    Shield,
    Booster,
    Spinner
}

class ACrystalRanged : AModActor
{
    ECrystalState CrystalState;

    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent MeshRoot;

    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent BoomerangRoot;

    UPROPERTY(DefaultComponent, Attach = Root)
    UNiagaraComponent Trail;
    default Trail.SetAutoActivate(false);

    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent ShootOrigin;

    UPROPERTY(Category = "Setup", EditDefaultsOnly)
    TSubclassOf<APlayerProjectile> ProjectileClass;

    UPROPERTY(Category = "Setup", EditDefaultsOnly)
    UModuleSheet ModuleSheet;

    AEnemyBase BoomerangTargetEnemy;

    TArray<AEnemyBase> EnemyArray;

    int FollowPosition;

    float InterpSpeed;

    void Initiate(int InFollowPosition, float InInterpSpeed)
    {
        AddModuleSheet(ModuleSheet);
        FollowPosition = InFollowPosition;
        InterpSpeed = InInterpSpeed;
        BP_DisableBoomerangMesh();
    }

    UFUNCTION(BlueprintEvent)
    void BP_EnableBoomerangMesh() {}

    UFUNCTION(BlueprintEvent)
    void BP_DisableBoomerangMesh() {}

    void SpawnProjectile(FVector Direction)
    {
        SpawnActor(ProjectileClass, ShootOrigin.WorldLocation, Direction.Rotation());
    }

    void ActivateBoomerangMovement(TArray<AEnemyBase> InEnemyArray)
    {
        if (InEnemyArray.Num() == 0)
            return;
        
        EnemyArray = InEnemyArray;
        CrystalState = ECrystalState::BoomerangMoving;
    }

    void ActivateBoomerangReady()
    {
        CrystalState = ECrystalState::Default;
    }

    void ActivateDefault()
    {
        CrystalState = ECrystalState::Default;
    }
}