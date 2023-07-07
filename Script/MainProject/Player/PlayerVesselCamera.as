class APlayerVesselCamera : AModActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent, Attach = Root)
    USceneComponent RootOffset;

    UPROPERTY(DefaultComponent, Attach = RootOffset)
    USpringArmComponent SpringArm;

    UPROPERTY(DefaultComponent, Attach = SpringArm)
    UCameraComponent CameraComp;
}