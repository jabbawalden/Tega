class ATurretProjectile : AModActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent, Attach = Root)
    USphereComponent SphereComp;

    UPROPERTY(DefaultComponent, Attach = Root)
    UStaticMeshComponent MeshComp;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        
    }
}