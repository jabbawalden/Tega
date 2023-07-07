UCLASS(Abstract)
class UAIAttackBaseComponent : UArrowComponent
{
    UPROPERTY(Category = "Attack Settings", EditDefaultsOnly)
    float RandomizedDirectionPitch = 0.f;

    UPROPERTY(Category = "Attack Settings", EditDefaultsOnly)
    float RandomizedDirectionYaw = 0.f;

    UPROPERTY(Category = "Attack Settings", EditDefaultsOnly)
    float AttackInterval = 1.f;

    UPROPERTY(Category = "Attack Settings", EditDefaultsOnly)
    TSubclassOf<AAIAttackBaseActor> AttackClass;

    UAIBehaviourComponent BehaviourComp;

    AActor AttackTarget;

    float AttackTime;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        BehaviourComp = UAIBehaviourComponent::Get(Owner);
        SetComponentTickEnabled(false);
    }

    void RunAttack(AActor Target)
    {
        SetComponentTickEnabled(true);
        AttackTarget = Target;
    }

    void FinishAttack()
    {
        SetComponentTickEnabled(false);
    }

    FRotator GetDesiredRotation()
    {
        float Pitch = 0.f;
        float Yaw = 0.f;

        if (RandomizedDirectionPitch > 0.f)
        {   
            Pitch = Math::RandRange(-RandomizedDirectionPitch, RandomizedDirectionPitch);
        }
        
        if (RandomizedDirectionYaw > 0.f)
        {
            Yaw = Math::RandRange(-RandomizedDirectionPitch, RandomizedDirectionPitch);
        }
        
        return WorldRotation + FRotator(Pitch, Yaw, 0.f);
    }

    void ActivateAttack()
    {
        AttackTime = System::GameTimeInSeconds + AttackInterval;
        AAIAttackBaseActor AttackActor = Cast<AAIAttackBaseActor>(SpawnActor(AttackClass, WorldLocation, GetDesiredRotation(), bDeferredSpawn = true));
        AttackActor.AttackTarget = AttackTarget;
        AttackActor.AttackInstigator = Owner;
        FinishSpawningActor(AttackActor);
    }
}