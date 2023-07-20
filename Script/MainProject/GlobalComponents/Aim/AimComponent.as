class UAimComponent : UActorComponent
{
    APlayerVessel Player;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Player = Cast<APlayerVessel>(Owner);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        // System::DrawDebugLine(Player.ActorLocation, GetAimStartPosition(), FLinearColor::Teal, 0, 5.0);
        System::DrawDebugLine(GetAimStartPosition(), GetAimStartPosition() + GetAimDirection() * 5000.0, FLinearColor::Red, 0, 5.0);
        // System::DrawDebugLine(Player.GetViewLocation(), Player.GetViewLocation() + Player.GetViewDirection() * 1000.0, FLinearColor::Green, 0, 5.0);
        // System::DrawDebugSphere(GetAimStartPosition(), 25, 12, FLinearColor::Teal, 0, 5.0);
        // System::DrawDebugSphere(Player.GetViewLocation(), 25, 12, FLinearColor::Green, 0, 5.0);
        // System::DrawDebugSphere(Player.GetViewTargetLocation(), 25, 12, FLinearColor::Red, 0, 5.0);
    }

    FVector GetAimStartPosition()
    {
        //  If we want to ignore the interp
        // FVector ViewStart = Player.GetViewTargetLocation() - Player.ActorLocation;
        FVector ViewStart = Player.GetViewTrueLocation() - Player.ActorLocation;
        ViewStart = ViewStart.ConstrainToPlane(Player.GetViewDirection());
        FVector DirectionToInitialPos = ((Player.ActorLocation + ViewStart) - Player.ActorLocation).GetSafeNormal();
        return Player.ActorLocation + ViewStart;
    }

    FVector GetAimDirection()
    {
        return Player.GetViewDirection();
    }
}