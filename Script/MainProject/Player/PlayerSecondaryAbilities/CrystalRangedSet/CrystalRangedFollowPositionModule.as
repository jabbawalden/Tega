class UCrystalRangedFollowPositionModule : UModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"CrystalRangedFollowPositionModule");

    ACrystalRanged Crystal;
    APlayerVessel Player;

    FVector LocationTarget;
    FRotator RotationTarget;
 
    void Setup() override
    {
        Crystal = Cast<ACrystalRanged>(Owner);
        Player = Cast<APlayerVessel>(Crystal.GetAttributeObject(n"Player"));
    }

    bool ShouldActivate() override
    {
        if (Crystal.CrystalState == ECrystalState::BoomerangMoving)
            return false;
        
        return true;
    }

    bool ShouldDeactivate() override
    {
        if (Crystal.CrystalState == ECrystalState::BoomerangMoving)
            return true;

        return false;
    }

    void OnActivated() override
    {
        // LocationTarget = Player.GetCrystalPosition(Crystal.FollowPosition);
        // RotationTarget = Player.GetConstrainedCameraForward().Rotation();
        // Crystal.ActorLocation = Player.GetCrystalPosition(Crystal.FollowPosition);
        // Crystal.ActorRotation = Player.GetConstrainedCameraForward().Rotation();
    }

    void OnDeactivated() override
    {
        
    }

    void Update(float DeltaTime) override
    {
        LocationTarget = Player.GetCrystalPosition(Crystal.FollowPosition);
        RotationTarget = Player.GetConstrainedCameraForward().Rotation();
        Crystal.ActorLocation = Math::VInterpTo(Crystal.ActorLocation, LocationTarget, DeltaTime, Crystal.InterpSpeed);
        Crystal.ActorRotation = Math::RInterpTo(Crystal.ActorRotation, RotationTarget, DeltaTime, Crystal.InterpSpeed);
    }    
}