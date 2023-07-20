enum EGetMovementCollisionType
{
    Wall,
    Ground,
    Step
}

namespace MovementCollisionSolveData
{
    const float MinWalkableDot = 0.85; 

    EGetMovementCollisionType GetCollisionType(FHitResult Hit)
    {
        //Traces to figure out if stepable
        float DotCheck = FVector::UpVector.DotProduct(Hit.ImpactNormal);
        if (DotCheck >= MovementCollisionSolveData::MinWalkableDot)
            return EGetMovementCollisionType::Ground;
        else
            return EGetMovementCollisionType::Wall;
    }
}

struct FMovementGravitySettings
{
    UPROPERTY()
    float InitAmount = 50.0;
    UPROPERTY()
    float Gravity = 4000.f;
    UPROPERTY()
    float GravityAcceleration = 2000.f;
}

struct FInheritenceMovementData
{
    UPROPERTY()
    FVector LocalOffset;

    UPROPERTY()
    AActor Actor;

    UPROPERTY()
    UMovementInheritenceComponent Comp;
}
