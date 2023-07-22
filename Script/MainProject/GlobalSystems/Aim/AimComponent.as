struct FAimData
{
    UPROPERTY()
    FVector AimStartPosition;
    UPROPERTY()
    FVector AimDirection;
    UPROPERTY()
    UPrimitiveComponent Target;
    UPROPERTY()
    FVector HitPoint;
}

class UAimComponent : UActorComponent
{
    APlayerVessel Player;

    private FAimData AimData; 

    TArray<AActor> IgnoreActors;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Player = Cast<APlayerVessel>(Owner);
        IgnoreActors.Add(Player);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        // System::DrawDebugLine(Player.ActorLocation, GetAimStartPosition(), FLinearColor::Teal, 0, 5.0);
        System::DrawDebugLine(GetAimStartPosition(), GetAimStartPosition() + GetAimDirection() * 5000.0, FLinearColor::Red, 0, 5.0);

        FHitResult AimHit;

        FVector Start = GetAimStartPosition();
        FVector End = Start + GetAimDirection() * 100000.0;
        System::LineTraceSingle(Start, End, ETraceTypeQuery::WeaponTrace, false, IgnoreActors, EDrawDebugTrace::None, AimHit, true);

        AimData.AimDirection = GetAimDirection();
        AimData.AimStartPosition = GetAimStartPosition();

        if (AimHit.bBlockingHit)
        {
            AimData.HitPoint = AimHit.ImpactPoint;
            AimData.Target = AimHit.Component;
        }
        else
        {
            AimData.HitPoint = End;
            AimData.Target = nullptr;
        }

        PrintToScreen(f"{AimData.Target=}");
        // System::DrawDebugLine(Player.GetViewLocation(), Player.GetViewLocation() + Player.GetViewDirection() * 1000.0, FLinearColor::Green, 0, 5.0);
        // System::DrawDebugSphere(GetAimStartPosition(), 25, 12, FLinearColor::Teal, 0, 5.0);
        System::DrawDebugSphere(AimData.HitPoint, 25, 12, FLinearColor::Red, 0, 5.0);
        // System::DrawDebugSphere(Player.GetViewLocation(), 25, 12, FLinearColor::Green, 0, 5.0);
        // System::DrawDebugSphere(Player.GetViewTargetLocation(), 25, 12, FLinearColor::Red, 0, 5.0);
    }

    FVector GetAimStartPosition()
    {
        //  If we want to ignore the interp
        // FVector ViewStart = Player.GetViewTargetLocation() - Player.ActorLocation;
        FVector ViewStart = Player.GetViewTrueLocation() - Player.ActorLocation;
        ViewStart = ViewStart.ConstrainToPlane(Player.GetViewDirection());
        return Player.ActorLocation + ViewStart;
    }

    FVector GetAimDirection()
    {
        return Player.GetViewDirection();
    }

    FAimData GetAimData()
    {
        return AimData;
    }
}