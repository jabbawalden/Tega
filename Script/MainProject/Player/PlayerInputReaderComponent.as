class UPlayerInputReaderComponent : UActorComponent
{
    UInputComponent InputComp;

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
        InputComp = UInputComponent::Get(Owner);

        InputComp.BindAction(n"LeftTrigger", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"LeftTriggerAction"));
        InputComp.BindAction(n"LeftTrigger", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"LeftTriggerReleased"));
        InputComp.BindAction(n"RightTrigger", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"RightTriggerAction"));
        InputComp.BindAction(n"RightTrigger", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"RightTriggerReleased"));
        InputComp.BindAction(n"LeftShoulder", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"LeftShoulderAction"));
        InputComp.BindAction(n"LeftShoulder", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"LeftShoulderReleased"));
        InputComp.BindAction(n"RightShoulder", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"RightShoulderAction"));
        InputComp.BindAction(n"RightShoulder", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"RightShoulderReleased"));

        InputComp.BindAction(n"FaceButtonTop", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"ButtonTopAction"));
        InputComp.BindAction(n"FaceButtonTop", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"ButtonTopReleased"));
        InputComp.BindAction(n"FaceButtonBottom", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"ButtonBottomAction"));
        InputComp.BindAction(n"FaceButtonBottom", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"ButtonBottomReleased"));
        InputComp.BindAction(n"FaceButtonLeft", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"ButtonLeftAction"));
        InputComp.BindAction(n"FaceButtonLeft", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"ButtonLeftReleased"));
        InputComp.BindAction(n"FaceButtonRight", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"ButtonRightAction"));
        InputComp.BindAction(n"FaceButtonRight", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"ButtonRightReleased"));      
        
        InputComp.BindAxis(n"LeftMoveX", FInputAxisHandlerDynamicSignature(this, n"LeftMoveX"));    
        InputComp.BindAxis(n"LeftMoveY", FInputAxisHandlerDynamicSignature(this, n"LeftMoveY"));    
        InputComp.BindAxis(n"RightMoveX", FInputAxisHandlerDynamicSignature(this, n"RightMoveX"));    
        InputComp.BindAxis(n"RightMoveY", FInputAxisHandlerDynamicSignature(this, n"RightMoveY"));    
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

    bool WasInputActioned(FName Tag)
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

    bool IsInputActioning(FName Tag)
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

    FVector GetStickVector(FName Tag)
    {   
        if (Tag == InputNames::LeftStickRaw)
            return FVector(LeftAxis.Y, LeftAxis.X, 0.f).GetSafeNormal();

        if (Tag == InputNames::RightStickRaw)
            return FVector(RightAxis.Y, RightAxis.X, 0.f).GetSafeNormal();

        if (Tag == InputNames::LeftStickMovement)
            return ((CameraConstrainedForward * LeftAxis.Y) + (CameraConstrainedRight * LeftAxis.X)).GetSafeNormal();

        if (Tag == InputNames::RightStickMovement)
            return ((CameraConstrainedForward * RightAxis.Y) + (CameraConstrainedRight * RightAxis.X)).GetSafeNormal();
            
        // if (Tag == InputNames::LeftStickRaw)
        // {
        //     if (FVector(LeftAxis.Y, LeftAxis.X, 0.f).Size() > 0.99f)
        //         return FVector(LeftAxis.Y, LeftAxis.X, 0.f);
        // }

        // if (Tag == InputNames::RightStickRaw)
        // {
        //     if (FVector(RightAxis.Y, RightAxis.X, 0.f).Size() > 0.99f)
        //         return FVector(RightAxis.Y, RightAxis.X, 0.f);
        // }

        // if (Tag == InputNames::LeftStickMovement)
        // {
        //     if (FVector((CameraConstrainedForward * LeftAxis.Y) + (CameraConstrainedRight * LeftAxis.X)).Size() > 0.99f)
        //         return (CameraConstrainedForward * LeftAxis.Y) + (CameraConstrainedRight * LeftAxis.X);
        // }

        // if (Tag == InputNames::RightStickMovement)
        // {
        //     if (FVector((CameraConstrainedForward * RightAxis.Y) + (CameraConstrainedRight * RightAxis.X)).Size() > 0.99f)
        //         return (CameraConstrainedForward * RightAxis.Y) + (CameraConstrainedRight * RightAxis.X);
        // }

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