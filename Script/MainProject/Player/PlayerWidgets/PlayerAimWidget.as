class UPlayerAimWidget : UUserWidget
{
    UPROPERTY()
    APlayerController OwningPlayerController;

    UPROPERTY()
    FVector PlayerVesselLocation;

    UFUNCTION()
    FVector GetWorldLocationFromAim(FVector Loc)
    {
        throw("does a throw");
        return Loc;
    }
}