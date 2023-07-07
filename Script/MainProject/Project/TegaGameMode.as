class ATegaGameMode : AModuleGameMode
{
    AActor PlayerActor;

    UFUNCTION(BlueprintOverride)
    void BeginPlay() override
    {   
        Super::BeginPlay();
        // DefaultPawnClass
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime) override
    {
        Super::Tick(DeltaTime);
        // PrintToScreen("PlayerActor Location: " + PlayerActor.ActorLocation);
    }

    //Returns base class of the player pawn
    AActor GetPlayerActor()
    {
        return PlayerActor;
    }
}