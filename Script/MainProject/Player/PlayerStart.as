class APlayerVesselStart : APlayerStart
{
    UCapsuleComponent CapsuleComp;

    UFUNCTION(BlueprintOverride)
    void ConstructionScript()
    {
        CapsuleComp = UCapsuleComponent::Get(this);
        CapsuleComp.CapsuleHalfHeight = 70.f;
        CapsuleComp.CapsuleRadius = 70.f;
    }
}