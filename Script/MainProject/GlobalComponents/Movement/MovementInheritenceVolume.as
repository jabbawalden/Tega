class UMovementInheritenceVolume : UBoxComponent
{
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        OnComponentBeginOverlap.AddUFunction(this, n"BeginOverlap");
        OnComponentEndOverlap.AddUFunction(this, n"EndOverlap");
    }

    UFUNCTION()
    private void BeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor,
                                         UPrimitiveComponent OtherComp, int OtherBodyIndex,
                                         bool bFromSweep, FHitResult&in SweepResult)
    {
        UFrameMovementComponent MoveComp = UFrameMovementComponent::Get(OtherActor);

        if (MoveComp != nullptr)
        {
            //Send over owning actor as the reference
        }
    }

    UFUNCTION()
    private void EndOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor,
                            UPrimitiveComponent OtherComp, int OtherBodyIndex)
    {
        UFrameMovementComponent MoveComp = UFrameMovementComponent::Get(OtherActor);

        if (MoveComp != nullptr)
        {
            //Remove actor as the reference
        }
    }
}