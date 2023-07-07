class UPlayerAimModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::CalculateMovement;

    default Tags.Add(n"Module");
    default Tags.Add(n"PlayerModule");
    default Tags.Add(n"PlayerAimModule");

    APlayerVessel Player;
 
    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
    }

    bool ShouldActivate() override
    {
        // if (!Player.WasInputActioned(InputNames::LeftTrigger))
        //     return false;
        
        return true;
    }

    bool ShouldDeactivate() override
    {
        // if (Player.IsInputActioning(InputNames::LeftTrigger))
        //     return false;
        
        // return true;
        return false;
    }

    void OnActivated() override
    {
        Player.BlockModule(PlayerGenericTags::CameraChase, this);
        // Player.BlockModule(MovementTags::Dash, this);
        // Player.ApplyMovementSettings(Player.AimMovementSettings, this, EPlayerSettingsPriority::High);
        // Player.ApplyCameraSettings(Player.AimCameraSettings, this, EPlayerSettingsPriority::High);
        Player.PlayerMovementState = EPlayerMovementState::Aiming;
    }

    void OnDeactivated() override
    {
        Player.UnblockModule(PlayerGenericTags::CameraChase, this);
        // Player.UnblockModule(MovementTags::Dash, this);
        // Player.RemoveMovementSettingsByInstigator(this);
        // Player.RemoveCameraSettingsByInstigator(this);
        Player.PlayerMovementState = EPlayerMovementState::Moving;
    }

    void Update(float DeltaTime) override
    {
        float Dot = Player.ViewRotation().Vector().DotProduct(FVector::UpVector);
        // PrintToScreen("DOT: " + Dot);
    }
} 