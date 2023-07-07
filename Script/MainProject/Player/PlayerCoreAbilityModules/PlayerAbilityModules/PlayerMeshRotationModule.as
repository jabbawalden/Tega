class UPlayerMeshRotationModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::CalculateMovement;

    default Tags.Add(n"Module");
    default Tags.Add(n"PlayerModule");
    default Tags.Add(n"PlayerMeshRotationModule");
    default Tags.Add(MovementTags::GroundMovement);
    default Tags.Add(PlayerGenericTags::Movement);

    APlayerVessel Player;
 
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
        // PrintToScreen("WHEEL MESH ROTATION");
        
        FVector MovementDir = Player.GetStickVector(InputNames::LeftStickRaw);

        //Pitch rotates in same direction regardless of forward or backward input
        //This is because the character root rotates based on world, but meshroot is relative along with input being raw
        //Ensure that it always rotates the correct way even when the meshroot turns around
        float Pitch;

        if (Player.PlayerMovementState == EPlayerMovementState::Aiming)
            Pitch = -MovementDir.X * 15.f;
        else
            Pitch = -Math::Abs(MovementDir.X) * 15.f;
        
        float Roll = MovementDir.Y * 15.f;

        FRotator TargetRotation = FRotator(Pitch, 0.f, Roll);
        Player.MeshRoot.RelativeRotation = Math::RInterpTo(Player.MeshRoot.RelativeRotation, TargetRotation, DeltaTime, 3.f);
    }
}