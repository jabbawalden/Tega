class UPlayerCharacterRotationModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::RunMovement;

    default Tags.Add(n"Module");
    default Tags.Add(n"PlayerModule");
    default Tags.Add(n"PlayerCharacterRotationModule");
    default Tags.Add(PlayerGenericTags::Movement);

    APlayerVessel Player;
    UFrameMovementComponent MoveComp;

    // FVector SavedInput;
 
    void Setup() override
    {
        Player = Cast<APlayerVessel>(Owner);
        MoveComp = UFrameMovementComponent::Get(Player);
    }

    bool ShouldActivate() override
    {
        return true;
    }

    bool ShouldDeactivate() override
    {
        return false;
    }

    void Update(float DeltaTime) override
    {
        //If aiming face cam dir
        //Else if stick not equal 0, face twoards saved movement direction
        if (Player.PlayerMovementState == EPlayerMovementState::Aiming)
            Player.CharacterFacingRotation = Player.GetConstrainedCameraForward().Rotation();
        else if (Player.GetStickVector(InputNames::LeftStickMovement).Size() != 0.f)
            Player.CharacterFacingRotation = Player.SavedMovementDirection.Rotation();

        FRotator NewRot = Math::RInterpTo(Player.ActorRotation, Player.CharacterFacingRotation, DeltaTime, 8.f);
        MoveComp.SetRotationThisFrame(NewRot);
    }
}