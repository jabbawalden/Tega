class UMovementInheritenceComponent : UActorComponent
{
    FVector LocationOffset;
    FRotator RotationOffset;

    FVector SavedLocation;
    FRotator SavedRotation;

    FVector SavedLocalPosition;
    FVector SavedWorldPosition;

    void SetInheritenceData(FVector SavedPosition)
    {
        SavedWorldPosition = SavedPosition;
        SavedLocalPosition = Owner.ActorTransform.InverseTransformPosition(SavedWorldPosition);
    }

    FVector GetInheritedVelocity()
    {
        FVector InheritedVelocity = Owner.ActorTransform.TransformPosition(SavedLocalPosition) - SavedWorldPosition;
        return InheritedVelocity;
    }
}