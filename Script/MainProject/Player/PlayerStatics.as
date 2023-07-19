namespace InputNames
{
    const FName FaceButtonTop(n"FaceButtonTop");
    const FName FaceButtonBottom(n"FaceButtonBottom");
    const FName FaceButtonLeft(n"FaceButtonLeft");
    const FName FaceButtonRight(n"FaceButtonRight");

    const FName LeftTrigger(n"LeftTrigger");
    const FName RightTrigger(n"RightTrigger");

    const FName LeftShoulder(n"LeftShoulder");
    const FName RightShoulder(n"RightShoulder");

    const FName RightStickRaw(n"RightStickRaw");
    const FName LeftStickRaw(n"LeftStickRaw");
    const FName RightStickMovement(n"RightStickMovement");
    const FName LeftStickMovement(n"LeftStickMovement");

    const FName CameraInput(n"CameraInput");
}

namespace MovementTags
{
    const FName GroundMovement(n"GroundMovement");
    const FName Gravity(n"Gravity");
    const FName Dash(n"Dash");
}

namespace PlayerGenericTags
{
    const FName Camera(n"Camera");
    const FName CameraControl(n"CameraControl");
    const FName CameraChase(n"CameraChase");
    const FName Movement(n"Movement");
}

struct FPlayerMovementSettings
{
    UPROPERTY()
    float MoveSpeed = 1400.f;
    UPROPERTY()
    float DashSpeed = 3800.f;
    UPROPERTY()
    float DashDuration = 0.15f;
    UPROPERTY()
    float DashDecceleration = 15000.f;
    UPROPERTY()
    float DashRecoveryTime = 0.4f;
    UPROPERTY()
    float Gravity = 2200.f;
    UPROPERTY()
    float GravityAcceleration = 2000.f;

    EPlayerSettingsPriority SettingsPriority;

    UObject Instigator = nullptr;
}

struct FPlayerCameraSettings
{
    UPROPERTY()
    FPlayerCameraCameraOffset CameraOffsetSettings;

    UPROPERTY()
    FPlayerCameraControlSettings ControlSettings;

    UPROPERTY()
    FPlayerCameraChaseSettings ChaseSettings;

    UPROPERTY()
    FPlayerCameraFOVSettings FOVSettings;

    EPlayerSettingsPriority SettingsPriority;

    UObject Instigator = nullptr;
}

struct FPlayerCameraCameraOffset
{
    UPROPERTY()
    float TargetArmLength = 1200.f;
    UPROPERTY()
    float SpringArmOffsetX = 0.f;
    UPROPERTY()
    float SpringArmOffsetY = 0.f;
    UPROPERTY()
    float SpringArmOffsetZ = 0.f;
    UPROPERTY()
    float CameraOffsetX = 0.f;
    UPROPERTY()
    float CameraOffsetY = 0.f;
    UPROPERTY()
    float CameraOffsetZ = 0.f;
}

struct FPlayerCameraControlSettings
{
    UPROPERTY()
    float PitchSpeed = 90.f;
    UPROPERTY()
    float YawSpeed = 135.f;
    UPROPERTY()
    float PitchAcceleration = 750.f;
    UPROPERTY()
    float YawAcceleration = 900.f;
    UPROPERTY()
    float PitchDecceleration = 1250.f;
    UPROPERTY()
    float YawDecceleration = 1400.f;
    UPROPERTY()
    float MinPitchClamp = 35.f;
    UPROPERTY()
    float MaxPitchClamp = -50.f;
}

struct FPlayerCameraChaseSettings
{
    UPROPERTY()
    float ChaseSpeed = 30.f;
    UPROPERTY()
    float LookOffsetX = 60.f;
    UPROPERTY()
    float LookOffsetY = 70.f;
    UPROPERTY()
    float LookOffsetZ = 120.f;
    UPROPERTY()
    float LookInterp = 0.6f;
    UPROPERTY()
    float CameraLocationFollowInterp = 14.f;
}

struct FPlayerCameraFOVSettings
{
    UPROPERTY()
    float FOV = 75.f;
}

struct FPlayerAbilitySettings
{
    //ATTACK DAMAGES
    float AttackRate;
    float MainCrystalDamage;
    float CrystalProjectileDamage;
    float CrystalBoomerangDamage;

    int BoomerangCount;
}

enum EPlayerSettingsPriority
{
    Low,
    Medium,
    High,
    Maximum
}

class UPlayerMovementSettingsDataAsset : UDataAsset
{
    UPROPERTY()
    FPlayerMovementSettings MovementSettings;
}

class UPlayerCameraSettingsDataAsset : UDataAsset
{
    UPROPERTY()
    FPlayerCameraSettings CameraSettings;
}