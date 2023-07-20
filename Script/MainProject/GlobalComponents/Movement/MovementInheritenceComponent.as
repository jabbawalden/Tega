class UMovementInheritenceComponent : UActorComponent
{
    FVector LocationOffset;
    FRotator RotationOffset;

    FVector SavedLocation;
    FRotator SavedRotation;

    FVector SavedLocalPosition;
    FVector SavedWorldPosition;
    FVector SavedHitComponentLocation;

    UPrimitiveComponent HitComponent;

    void SetInheritenceData(FVector SavedPosition)
    {
        SavedWorldPosition = SavedPosition;
        SavedLocalPosition = Owner.ActorTransform.InverseTransformPosition(SavedWorldPosition);
        SavedHitComponentLocation = HitComponent.RelativeLocation;
    }

    FVector GetInheritedVelocity()
    {
        FVector HitCompOffset = HitComponent.RelativeLocation - SavedHitComponentLocation;
        FVector InheritedVelocity = HitCompOffset + Owner.ActorTransform.TransformPosition(SavedLocalPosition) - SavedWorldPosition;
        return InheritedVelocity;
    }
}