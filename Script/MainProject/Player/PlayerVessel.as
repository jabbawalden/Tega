enum EPlayerMovementState
{
    Moving,
    Aiming
}

enum EPlayerSpecialAbilityMode
{
    Turret,
    Shield,
    Booster,
    Spinner
}

APlayerVessel GetPlayer()
{
    APlayerVessel EmptyPlayer = nullptr;
    return EmptyPlayer;
}

class APlayerVessel : APlayerModPawn
{
    EPlayerMovementState PlayerMovementState;
    EPlayerSpecialAbilityMode PlayerSpecialAbilityMode;
    int MaxAbilityModeIndex = 3;
    int AbilityModeIndex = 0;

    UPROPERTY(DefaultComponent, RootComponent)
    USphereComponent SphereComp;
    default SphereComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Block);
    default SphereComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Ignore);
    
    UPROPERTY(DefaultComponent, Attach = SphereComp)
    USceneComponent CharacterRoot;
    UPROPERTY(DefaultComponent, Attach = CharacterRoot)
    USceneComponent MeshRoot;
    // UPROPERTY(DefaultComponent, Attach = MeshRoot)
    // USceneComponent ProjectileOrigin;

    UPROPERTY(DefaultComponent, Attach = MeshRoot)
    USceneComponent WeaponsRoot;

    //*** SLOT WEAPONS ***//
    UPROPERTY(DefaultComponent, Attach = WeaponsRoot)
    UWeaponSlotComponent PlayerPrimaryWeaponOne;
    default PlayerPrimaryWeaponOne.SlotType = EWeaponSlotType::Primary;
    UPROPERTY(DefaultComponent, Attach = WeaponsRoot)
    UWeaponSlotComponent PlayerPrimaryWeaponTwo;
    default PlayerPrimaryWeaponTwo.SlotType = EWeaponSlotType::Primary;
    UPROPERTY(DefaultComponent, Attach = WeaponsRoot)
    UWeaponSlotComponent PlayerSecondaryWeaponOne;
    default PlayerSecondaryWeaponOne.SlotType = EWeaponSlotType::Secondary;
    UPROPERTY(DefaultComponent, Attach = WeaponsRoot)
    UWeaponSlotComponent PlayerSecondaryWeaponTwo;
    default PlayerSecondaryWeaponTwo.SlotType = EWeaponSlotType::Secondary;

    UPROPERTY(DefaultComponent)
    USlotWeaponDataComponent SlotWeaponDataComp; 

    //*** BASE COMPONENTS ***//
    UPROPERTY(DefaultComponent)
    UPlayerModInputComponent PlayerInputReaderComp;
    UPROPERTY(DefaultComponent)
    UFrameMovementComponent FrameMovementComp;
    UPROPERTY(DefaultComponent)
    UPlayerHealthComponent HealthComp;
    UPROPERTY(DefaultComponent)
    UAimComponent AimComp;

    UPROPERTY(Category = "Setup", EditDefaultsOnly)
    TSubclassOf<APlayerVesselCamera> PlayerCameraClass;
    APlayerVesselCamera PlayerCamera;

    UPROPERTY(Category = "Setup", EditDefaultsOnly)
    TSubclassOf<UUserWidget> AimWidgetClass;
    UPlayerAimWidget AimWidget;

    UPROPERTY(Category = "Secondary Abilities", EditDefaultsOnly)
    TSubclassOf<ACrystalRanged> CrystalRangedClass;
    TArray<ACrystalRanged> CrystalRangedArray;
    TArray<FVector> CrystalLocationArray;

    UPROPERTY(Category = "Modules", EditDefaultsOnly)
    UModuleSheet InputSheet;
    UPROPERTY(Category = "Modules", EditDefaultsOnly)
    UModuleSheet AbilitySheet;
    UPROPERTY(Category = "Modules", EditDefaultsOnly)
    UModuleSheet MovementSheet;
    UPROPERTY(Category = "Modules", EditDefaultsOnly)
    UModuleSheet CameraControlSet;

    UPROPERTY(Category = "Movement Settings", EditDefaultsOnly)
    UPlayerMovementSettingsDataAsset DefaultMovementSettings;
    
    UPROPERTY(Category = "Movement Settings", EditDefaultsOnly)
    UPlayerMovementSettingsDataAsset AimMovementSettings;

    UPROPERTY(Category = "Movement Settings", EditDefaultsOnly)
    UPlayerCameraSettingsDataAsset DefaultCameraSettings;
    
    UPROPERTY(Category = "Movement Settings", EditDefaultsOnly)
    UPlayerCameraSettingsDataAsset AimCameraSettings;

    //*** REFERENCES ***//
    ATegaGameMode TegaGameMode;
    APlayerController PlayerController;
    FPlayerMovementSettings MovementSettings;
    FPlayerCameraSettings CameraSettings;
    AEnemyManager EnemyManager;

    //*** SETTINGS ***//
    TArray<FPlayerMovementSettings> AppliedMovementSettingsArray;
    TArray<FPlayerCameraSettings> AppliedCameraSettingsArray;

    //*** AIMING ***//
    TArray<AActor> AimTraceIgnoreActors;

    //*** MOVEMENT ***//
    FVector SavedMovementDirection;
    FRotator CharacterFacingRotation;

    FTimeToTargetFloat MovementSpeed;

    bool bAllowMovement = true;

    int BoomerangCrystalIndex = 0;
    float BoomerangRange = 3500.f;

    //*** ABILITIES ***//

    //Boost
    float MaxBoost = 300.f;
    float CurrentBoost;
    float BoostDeductAmount = 40.f;
    float BoostRecoveryAmount = 15.f;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        EnemyManager = GetEnemyManager();

        PlayerCamera = Cast<APlayerVesselCamera>(SpawnActor(PlayerCameraClass, ActorLocation, ActorRotation));
        PlayerController = Cast<APlayerController>(Gameplay::GetPlayerController(0));
        PlayerController.SetViewTargetWithBlend(PlayerCamera, 0.f);

        FrameMovementComp.InitWithSphereComponent(SphereComp);

        ApplyMovementSettings(DefaultMovementSettings, this, EPlayerSettingsPriority::Low);
        ApplyCameraSettings(DefaultCameraSettings, this, EPlayerSettingsPriority::Low);

        AddModuleSheet(InputSheet);
        AddModuleSheet(MovementSheet);
        AddModuleSheet(AbilitySheet);
        AddModuleSheet(CameraControlSet);

        GetTegaGameMode().PlayerActor = this;

        AimWidget = Cast<UPlayerAimWidget>(WidgetBlueprint::CreateWidget(AimWidgetClass, PlayerController));
        AimWidget.OwningPlayerController = PlayerController;
        AimWidget.AddToViewport();
        
        AimTraceIgnoreActors.Add(this);

        CurrentBoost = MaxBoost;

        //FOR TESTING
        PlayerPrimaryWeaponOne.SetWeapon(ESlotWeaponClassType::Gattling);
        PlayerSecondaryWeaponTwo.SetWeapon(ESlotWeaponClassType::MissileLauncher);
    }

    void SwitchSpecialAbilityMode()
    {
        AbilityModeIndex++;

        if (AbilityModeIndex > MaxAbilityModeIndex)
            AbilityModeIndex = 0;

        PlayerSpecialAbilityMode = EPlayerSpecialAbilityMode(AbilityModeIndex);
    }

    FVector GetCrystalPosition(int Index)
    {
        FVector Position = CrystalLocationArray[Index];

        FVector ForwardOffset = GetViewRotation().ForwardVector * Position.X; 
        FVector RightOffset = GetViewRotation().RightVector * Position.Y; 
        FVector UpOffset = GetViewRotation().UpVector * Position.Z;

        return ActorLocation + ForwardOffset + RightOffset + UpOffset;
    }

    ACrystalRanged GetAvailableCrystalForBoomerang()
    {
        if (CrystalRangedArray[BoomerangCrystalIndex].CrystalState != ECrystalState::Default)
            return nullptr;

        if (CrystalRangedArray[BoomerangCrystalIndex].CrystalState == ECrystalState::Default)
        {
            int CurrentIndex = BoomerangCrystalIndex; 

            BoomerangCrystalIndex++;

            if (BoomerangCrystalIndex > CrystalRangedArray.Num() - 1)
                BoomerangCrystalIndex = 0;

            return CrystalRangedArray[CurrentIndex];
        }

        for (ACrystalRanged Crystal : CrystalRangedArray)
        {
            if (Crystal.CrystalState == ECrystalState::Default)
                return Crystal;
        }

        return nullptr;
    }

    void ApplyMovementSettings(UPlayerMovementSettingsDataAsset NewMovementSettings, UObject SettingsInstigator, EPlayerSettingsPriority Priority = EPlayerSettingsPriority::Medium)
    {
        FPlayerMovementSettings NewSettings = NewMovementSettings.MovementSettings;
        NewSettings.Instigator = SettingsInstigator;
        NewSettings.SettingsPriority = Priority;
        AppliedMovementSettingsArray.Add(NewSettings); 
        UpdateMovementSettings();
    }

    void ApplyCameraSettings(UPlayerCameraSettingsDataAsset NewCameraSettings, UObject SettingsInstigator, EPlayerSettingsPriority Priority = EPlayerSettingsPriority::Medium)
    {
        FPlayerCameraSettings NewSettings = NewCameraSettings.CameraSettings;
        NewSettings.Instigator = SettingsInstigator;
        NewSettings.SettingsPriority = Priority;

        AppliedCameraSettingsArray.Add(NewSettings);
        UpdateCameraSettings();
    }

    FPlayerCameraControlSettings GetCameraControlSettings()
    {
        return CameraSettings.ControlSettings;
    }

    FPlayerCameraChaseSettings GetCameraChaseSettings()
    {
        return CameraSettings.ChaseSettings;
    }

    FPlayerCameraCameraOffset GetCameraOffsetSettings()
    {
        return CameraSettings.CameraOffsetSettings;
    }

    FPlayerCameraFOVSettings GetCameraFOVSettings()
    {
        return CameraSettings.FOVSettings;
    }

    void RemoveMovementSettingsByInstigator(UObject RemoveInstigator)
    {
        //If multiple settings are applied by one actor, this could be an issue
        FPlayerMovementSettings SettingToRemove;

        for (FPlayerMovementSettings Setting : AppliedMovementSettingsArray)
        {
            if (Setting.Instigator == RemoveInstigator)
                SettingToRemove = Setting;
        }

        if (SettingToRemove.Instigator != nullptr)
            AppliedMovementSettingsArray.Remove(SettingToRemove);
        else
            PrintWarning("No setting with instigator: " + RemoveInstigator.Name + " has been applied");

        UpdateMovementSettings();
    }

    void RemoveCameraSettingsByInstigator(UObject RemoveInstigator)
    {
        //If multiple settings are applied by one actor, this could be an issue
        FPlayerCameraSettings SettingToRemove;

        for (FPlayerCameraSettings Setting : AppliedCameraSettingsArray)
        {
            if (Setting.Instigator == RemoveInstigator)
                SettingToRemove = Setting;
        }

        if (SettingToRemove.Instigator != nullptr)
            AppliedCameraSettingsArray.Remove(SettingToRemove);
        else
            PrintWarning("No setting with instigator: " + RemoveInstigator.Name + " has been applied");

        UpdateCameraSettings();
    }

    void UpdateMovementSettings()
    {
        FPlayerMovementSettings HighestSetting = MovementSettings;
        HighestSetting.SettingsPriority = EPlayerSettingsPriority::Low;

        for (FPlayerMovementSettings Setting : AppliedMovementSettingsArray)
        {
            if (HighestSetting.SettingsPriority <= Setting.SettingsPriority)
                HighestSetting = Setting;
        } 

        MovementSettings = HighestSetting;     
    }

    void UpdateCameraSettings()
    {
        FPlayerCameraSettings HighestSetting;
        HighestSetting.SettingsPriority = EPlayerSettingsPriority::Low;

        for (FPlayerCameraSettings Setting : AppliedCameraSettingsArray)
        {
            if (HighestSetting.SettingsPriority <= Setting.SettingsPriority)
                HighestSetting = Setting;
        } 

        CameraSettings = HighestSetting;        
    }

    //*** HELPER FUNCTIONS ***//
    bool WasInputActioned(FName Tag)
    {
        return PlayerInputReaderComp.WasInputActioned(Tag);
    }

    bool IsInputActioning(FName Tag)
    {
        return PlayerInputReaderComp.IsInputActioning(Tag);
    }

    FVector GetStickVector(FName Tag)
    {
        return PlayerInputReaderComp.GetStickVector(Tag);
    }

    FRotator GetViewRotation()
    {
        return PlayerCamera.CameraComp.WorldRotation;
    }

    FVector GetViewTrueLocation()
    {
        return PlayerCamera.CameraComp.WorldLocation;
    }

    FVector GetViewTargetLocation()
    {
        FVector RelativePosition = (PlayerCamera.CameraComp.WorldLocation + (PlayerCamera.RootOffset.RelativeLocation / 4)) - PlayerCamera.ActorLocation;
        return CharacterRoot.WorldLocation + RelativePosition;
    }

    FVector GetViewDirection()
    {
        return PlayerCamera.CameraComp.WorldRotation.Vector();
    }

    FVector GetConstrainedCameraForward()
    {
        FVector ConstrainedCamDir = PlayerCamera.CameraComp.WorldRotation.Vector().ConstrainToPlane(FVector::UpVector);
        ConstrainedCamDir.Normalize();
        return ConstrainedCamDir;
    }

    FVector GetReticleToWorldHitLocation()
    {
        FVector2D Size = WidgetLayout::GetViewportSize();
        float XWidth = Size.X / 2.f;
        float YHeight = Size.Y / 2.f;

        //Initially for calculating the offset of the aim reticle. Now used as arbritary value for deciding when to start shooting upwards
        YHeight -= 80.f; //Need to fix this for different viewport sizes - return a value somehow from the widget

        FVector2D ReticlePosition = FVector2D(XWidth, YHeight);

        FVector Start;
        FVector Direction;
        Gameplay::DeprojectScreenToWorld(PlayerController, ReticlePosition, Start, Direction);

        FHitResult Hit;
        FVector End = Start + Direction * 800000.f;
        FVector HitLoc = End;
        System::LineTraceSingle(Start, End, ETraceTypeQuery::WeaponTrace, false, AimTraceIgnoreActors, EDrawDebugTrace::None, Hit, true, FLinearColor::Red);    

        if (Hit.bBlockingHit)
        {
            HitLoc = Hit.ImpactPoint;
        }    

        return HitLoc;
    }

    FVector GetShootDirection(FVector Origin)
    {
        FVector ReticleDir = (GetReticleToWorldHitLocation() - Origin).GetSafeNormal();
        float Dot = ActorUpVector.DotProduct(ReticleDir);
    
        if (Dot > 0.f)
            return (GetReticleToWorldHitLocation() - Origin).GetSafeNormal();
        else
            return GetConstrainedCameraForward();

        // return GetConstrainedCameraForward();
    }

    APlayerVesselCamera GetPlayerCameraActor()
    {
        return PlayerCamera;
    }

    TArray<AEnemyBase> GetInViewEnemies()
    {
        TArray<AEnemyBase> NewArray;
        
        for (AEnemyBase Enemy : EnemyManager.GetActiveEnemies())
        {
            if (Enemy == nullptr)
                continue;

            FVector Direction = Enemy.ActorLocation - ActorLocation;

            if (Direction.Size() > BoomerangRange)
                continue;

            Direction.Normalize();
            FVector ViewDirection = GetViewRotation().Vector().ConstrainToPlane(FVector::UpVector);
            ViewDirection.Normalize();

            float Dot = ViewDirection.DotProduct(Direction);

            if (Dot >= 0.78f)
                NewArray.Add(Enemy);
        }
        
        return NewArray;
    }
}