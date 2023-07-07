//TODO Add another delay for when the player starts moving left and right
class UCameraChaseModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(PlayerGenericTags::Camera);
    default Tags.Add(PlayerGenericTags::CameraChase);

    APlayerVessel Player;

    float CurrentYawAdd;
    float FollowSpeed = 40.f;

    float CamDelayTime;
    float StartingCamDelayTime = 2.f;
    bool bIsCamDelaying;

    float MoveDelayTime;
    float StartingMoveDelayTime = 2.f;
    bool bIsMoveDelaying;

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

    }

    void OnDeactivated() override
    {
        
    }

    void Update(float DeltaTime) override
    {
        float YawAddTarget = 0.f;

        if (Player.GetStickVector(InputNames::LeftStickRaw).Y == 0.f)
        {
            ResetMoveDelay();
            YawAddTarget = Player.GetStickVector(InputNames::LeftStickRaw).Y * Player.GetCameraChaseSettings().ChaseSpeed;
        }
        else
        {
            if (bIsMoveDelaying)
                bIsMoveDelaying = false;
        }

        if (Player.GetStickVector(InputNames::RightStickRaw).Size() == 0.f)
        {
            ResetCameraMoveDelay();
            YawAddTarget = Player.GetStickVector(InputNames::LeftStickRaw).Y * Player.GetCameraChaseSettings().ChaseSpeed;
        }
        else
        {
            if (bIsCamDelaying)
                bIsCamDelaying = false;
        }

        if (Gameplay::GetTimeSeconds() > CamDelayTime && Gameplay::GetTimeSeconds() > MoveDelayTime)
        {
            CurrentYawAdd = Math::FInterpConstantTo(CurrentYawAdd, YawAddTarget, DeltaTime, 30.f);
            Player.GetPlayerCameraActor().SpringArm.RelativeRotation += FRotator(0.f, CurrentYawAdd, 0.f) * DeltaTime;
        }
        else
        {
            CurrentYawAdd = 0.f;
        }

        FVector LookPointOffset = Player.GetPlayerCameraActor().SpringArm.RightVector * Player.GetCameraChaseSettings().LookOffsetY * Player.GetStickVector(InputNames::LeftStickRaw).Y;
        LookPointOffset += Player.GetPlayerCameraActor().SpringArm.ForwardVector * Player.GetCameraChaseSettings().LookOffsetX * Player.GetStickVector(InputNames::LeftStickRaw).X;
        LookPointOffset += Player.GetPlayerCameraActor().SpringArm.UpVector * Player.GetCameraChaseSettings().LookOffsetZ;
        FVector LookPoint = Player.ActorLocation + LookPointOffset;
        FRotator LookRot = (LookPoint - Player.GetPlayerCameraActor().CameraComp.WorldLocation).Rotation();
        FRotator TargetRot = Math::RInterpTo(Player.GetPlayerCameraActor().CameraComp.WorldRotation, LookRot, DeltaTime, Player.GetCameraChaseSettings().LookInterp);
        TargetRot.Roll = 0.f;
        Player.GetPlayerCameraActor().CameraComp.WorldRotation = TargetRot;
    }

    void ResetCameraMoveDelay()
    {
        if (!bIsCamDelaying)
        {
            CamDelayTime = Gameplay::GetTimeSeconds() + StartingCamDelayTime;
            bIsCamDelaying = true;
        }
    }
    
    void ResetMoveDelay()
    {
        if (!bIsMoveDelaying)
        {
            MoveDelayTime = Gameplay::GetTimeSeconds() + StartingMoveDelayTime;
            bIsMoveDelaying = true;
        }
    }
}