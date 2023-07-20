class UCameraControlModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(n"CameraControlModule");
    default Tags.Add(PlayerGenericTags::Camera);
    default Tags.Add(PlayerGenericTags::CameraControl);

    APlayerVessel Player;

    float PitchSpeed;
    float YawSpeed;
    // float MaxPitchSpeed = 90.f;
    // float MaxYawSpeed = 140.f;

    // float PitchAcceleration = 750.f;
    // float PitchDecceleration = 1250.f;

    float LastPitchInput; 
    float LastYawInput; 
    float PitchValue;
    float YawValue;

    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
    }

    bool ShouldActivate() override
    {
        return true;
    }

    bool ShouldDeactivate() override
    {
        return false;
    }

    void OnActivated() override
    {
        PitchValue = Player.GetPlayerCameraActor().SpringArm.RelativeRotation.Pitch;
        YawValue = Player.GetPlayerCameraActor().SpringArm.RelativeRotation.Yaw;
    }

    void OnDeactivated() override
    {
        
    }

    void Update(float DeltaTime) override
    {
        if (Player.GetStickVector(InputNames::RightStickRaw).X != 0.f)
        {
            LastPitchInput = Player.GetStickVector(InputNames::RightStickRaw).X;
            PitchSpeed = Math::FInterpConstantTo(PitchSpeed, Player.GetCameraControlSettings().PitchSpeed, DeltaTime, Player.GetCameraControlSettings().PitchAcceleration);
        }
        else
            PitchSpeed = Math::FInterpConstantTo(PitchSpeed, 0.f, DeltaTime, Player.GetCameraControlSettings().PitchDecceleration);

        if (Player.GetStickVector(InputNames::RightStickRaw).Y != 0.f)
        {
            LastYawInput = Player.GetStickVector(InputNames::RightStickRaw).Y;
            YawSpeed = Math::FInterpConstantTo(YawSpeed, Player.GetCameraControlSettings().YawSpeed, DeltaTime, Player.GetCameraControlSettings().YawAcceleration);
        }
        else
            YawSpeed = Math::FInterpConstantTo(YawSpeed, 0.f, DeltaTime, Player.GetCameraControlSettings().YawDecceleration);

        float PitchRot = LastPitchInput * PitchSpeed;
        float YawRot = LastYawInput * YawSpeed;

        PitchValue += PitchRot * DeltaTime;
        PitchValue = Math::Clamp(PitchValue, Player.GetCameraControlSettings().MaxPitchClamp, Player.GetCameraControlSettings().MinPitchClamp);
        YawValue += YawRot * DeltaTime;
       
        // FRotator FinalPitchRot = FRotator(FinalPitch, 0.f, 0.f);
        // FRotator FinalRot = FinalPitchRot + Player.GetPlayerCameraActor().SpringArm.RelativeRotation + FRotator(0.f, YawRot, 0.f) * DeltaTime;

        Player.GetPlayerCameraActor().SpringArm.RelativeRotation = FRotator(PitchValue, YawValue, 0.f);
    }
}