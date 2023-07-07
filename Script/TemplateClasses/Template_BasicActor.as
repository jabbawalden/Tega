class ATemplate_BasicActor : AModActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent MeshRoot;

    UPROPERTY(Category = "Modules", EditDefaultsOnly)
    TSubclassOf<UModuleSheet> ModuleSheet;
}