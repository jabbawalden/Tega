class ACustomCameraTest : ACameraActor
{
    void ActivateCamera(APlayerController PlayerController)
    {
        PlayerController.SetViewTargetWithBlend(this, 0.5f);
    }
}