class AModTestOne : AModActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent, Attach = Root)
    UStaticMeshComponent MeshComp;

    UPROPERTY()
    TSubclassOf<UModuleSheet> ModuleSheet;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // AddModuleSheet(ModuleSheet);

        // System::SetTimer(this, n"BlockATag", 1.f, false);
        // System::SetTimer(this, n"UnblockATag", 5.f, false);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime)
    {

    }

    // UFUNCTION()
    // void BlockATag()
    // {
    //     BlockModule(n"Move");
    // }

    // UFUNCTION()
    // void UnblockATag()
    // {
    //     UnblockModule(n"Move");
    // }
}