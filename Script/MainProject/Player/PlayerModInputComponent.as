class UPlayerModInputComponent : UInputComponent
{
    bool bLeftTriggerActioned;
    bool bLeftTriggerHeld;

    bool bRightTriggerActioned;
    bool bRightTriggerHeld;

    bool bLeftShoulderActioned;
    bool bLeftShoulderHeld;

    bool bRightShoulderActioned;
    bool bRightShoulderHeld;

    bool bFaceButtonTopActioned;
    bool bFaceButtonTopHeld;

    bool bFaceButtonBottomActioned;
    bool bFaceButtonBottomHeld;

    bool bFaceButtonLeftActioned;
    bool bFaceButtonLeftHeld;

    bool bFaceButtonRightActioned;
    bool bFaceButtonRightHeld;

    FVector LeftAxis;
    FVector RightAxis;
    FVector LastSavedAxis;

    FVector CameraConstrainedForward;
    FVector CameraConstrainedRight;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        BindAction(n"LeftTrigger", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"LeftTriggerAction"));
        BindAction(n"LeftTrigger", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"LeftTriggerReleased"));
        BindAction(n"RightTrigger", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"RightTriggerAction"));
        BindAction(n"RightTrigger", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"RightTriggerReleased"));
        BindAction(n"LeftShoulder", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"LeftShoulderAction"));
        BindAction(n"LeftShoulder", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"LeftShoulderReleased"));
        BindAction(n"RightShoulder", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"RightShoulderAction"));
        BindAction(n"RightShoulder", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"RightShoulderReleased"));

        BindAction(n"FaceButtonTop", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"ButtonTopAction"));
        BindAction(n"FaceButtonTop", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"ButtonTopReleased"));
        BindAction(n"FaceButtonBottom", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"ButtonBottomAction"));
        BindAction(n"FaceButtonBottom", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"ButtonBottomReleased"));
        BindAction(n"FaceButtonLeft", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"ButtonLeftAction"));
        BindAction(n"FaceButtonLeft", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"ButtonLeftReleased"));
        BindAction(n"FaceButtonRight", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"ButtonRightAction"));
        BindAction(n"FaceButtonRight", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"ButtonRightReleased"));      
        
        BindAxis(n"LeftMoveX", FInputAxisHandlerDynamicSignature(this, n"LeftMoveX"));    
        BindAxis(n"LeftMoveY", FInputAxisHandlerDynamicSignature(this, n"LeftMoveY"));    
        BindAxis(n"RightMoveX", FInputAxisHandlerDynamicSignature(this, n"RightMoveX"));    
        BindAxis(n"RightMoveY", FInputAxisHandlerDynamicSignature(this, n"RightMoveY"));    
    }

    UFUNCTION()
    void LeftTriggerAction(FKey Key) 
    {
        bLeftTriggerActioned = true;
        bLeftTriggerHeld = true;
    }

    UFUNCTION()
    void LeftTriggerReleased(FKey Key) 
    {
        bLeftTriggerHeld = false;
    }

    UFUNCTION()
    void RightTriggerAction(FKey Key) 
    {
        bRightTriggerActioned = true;
        bRightTriggerHeld = true;
    }

    UFUNCTION()
    void RightTriggerReleased(FKey Key) 
    {
        bRightTriggerHeld = false;
    }

    UFUNCTION()
    void LeftShoulderAction(FKey Key) 
    {
        bLeftShoulderActioned = true;
        bLeftShoulderHeld = true;
    }

    UFUNCTION()
    void LeftShoulderReleased(FKey Key) 
    {
        bLeftShoulderHeld = false;
    }

    UFUNCTION()
    void RightShoulderAction(FKey Key) 
    {
        bRightShoulderActioned = true;
        bRightShoulderHeld = true;
    }

    UFUNCTION()
    void RightShoulderReleased(FKey Key) 
    {
        bRightShoulderHeld = false;
    }

    UFUNCTION()
    void ButtonTopAction(FKey Key) 
    {
        bFaceButtonTopActioned = true;
        bFaceButtonTopHeld = true;
    }

    UFUNCTION()
    void ButtonTopReleased(FKey Key) 
    {
        bFaceButtonTopHeld = false;
    }

    UFUNCTION()
    void ButtonBottomAction(FKey Key) 
    {
        bFaceButtonBottomActioned = true;
        bFaceButtonBottomHeld = true;
    }

    UFUNCTION()
    void ButtonBottomReleased(FKey Key) 
    {
        bFaceButtonBottomHeld = false;
    }

    UFUNCTION()
    void ButtonLeftAction(FKey Key) 
    {
        bFaceButtonLeftActioned = true;
        bFaceButtonLeftHeld = true;
    }

    UFUNCTION()
    void ButtonLeftReleased(FKey Key) 
    {
        bFaceButtonLeftHeld = false;
    }

    UFUNCTION()
    void ButtonRightAction(FKey Key) 
    {
        bFaceButtonRightActioned = true;
        bFaceButtonRightHeld = true;
    }

    UFUNCTION()
    void ButtonRightReleased(FKey Key) 
    {
        bFaceButtonRightHeld = false;
    }

    bool WasInputActioned(FName Tag) const
    {
        if (Tag == InputNames::FaceButtonTop)
            return bFaceButtonTopActioned;

        if (Tag == InputNames::FaceButtonBottom)
            return bFaceButtonBottomActioned;

        if (Tag == InputNames::FaceButtonLeft)
            return bFaceButtonLeftActioned;

        if (Tag == InputNames::FaceButtonRight)
            return bFaceButtonRightActioned;

        if (Tag == InputNames::LeftTrigger)
            return bLeftTriggerActioned;

        if (Tag == InputNames::RightTrigger)
            return bRightTriggerActioned;

        if (Tag == InputNames::LeftShoulder)
            return bLeftShoulderActioned;

        if (Tag == InputNames::RightShoulder)
            return bRightShoulderActioned;

        return false;
    }

    bool IsInputActioning(FName Tag) const
    {
        if (Tag == InputNames::FaceButtonTop)
            return bFaceButtonTopHeld;

        if (Tag == InputNames::FaceButtonBottom)
            return bFaceButtonBottomHeld;

        if (Tag == InputNames::FaceButtonLeft)
            return bFaceButtonLeftHeld;

        if (Tag == InputNames::FaceButtonRight)
            return bFaceButtonRightHeld;

        if (Tag == InputNames::LeftTrigger)
            return bLeftTriggerHeld;

        if (Tag == InputNames::RightTrigger)
            return bRightTriggerHeld;

        if (Tag == InputNames::LeftShoulder)
            return bLeftShoulderHeld;

        if (Tag == InputNames::RightShoulder)
            return bRightShoulderHeld;

        return false;
    }

    UFUNCTION()
    void LeftMoveX(float32 Axis)
    {
        LeftAxis.X = Axis;
    }

    UFUNCTION()
    void LeftMoveY(float32 Axis)
    {
        LeftAxis.Y = Axis;
    }

    UFUNCTION()
    void RightMoveX(float32 Axis)
    {
        RightAxis.X = Axis;
    }

    UFUNCTION()
    void RightMoveY(float32 Axis)
    {
        RightAxis.Y = Axis;
    }

    FVector GetStickVector(FName Tag) const
    {   
        if (Tag == InputNames::LeftStickRaw)
            return FVector(LeftAxis.Y, LeftAxis.X, 0.f).GetSafeNormal();

        if (Tag == InputNames::RightStickRaw)
            return FVector(RightAxis.Y, RightAxis.X, 0.f).GetSafeNormal();

        if (Tag == InputNames::LeftStickMovement)
            return ((CameraConstrainedForward * LeftAxis.Y) + (CameraConstrainedRight * LeftAxis.X)).GetSafeNormal();

        if (Tag == InputNames::RightStickMovement)
            return ((CameraConstrainedForward * RightAxis.Y) + (CameraConstrainedRight * RightAxis.X)).GetSafeNormal();

        return FVector(0.f);
    }

    void SetConstrainedCameraData(FVector CamForward, FVector CamRight)
    {
        CameraConstrainedForward = CamForward.ConstrainToPlane(FVector::UpVector);
        CameraConstrainedForward.Normalize();
        CameraConstrainedRight = CamRight.ConstrainToPlane(FVector::UpVector);
        CameraConstrainedRight.Normalize();
    }
}