
UFUNCTION()
UBoxComponent SetEnemyBoxCollisionResponses(UBoxComponent InBoxComp)
{
    UBoxComponent BoxComp = InBoxComp;
    BoxComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
    BoxComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);
    BoxComp.SetCollisionResponseToChannel(ECollisionChannel::PlayerCharacter, ECollisionResponse::ECR_Block);
    BoxComp.SetCollisionResponseToChannel(ECollisionChannel::EnemyCharacter, ECollisionResponse::ECR_Ignore);
    BoxComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Block);
    BoxComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Block);
    BoxComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_WorldDynamic, ECollisionResponse::ECR_Block);
    BoxComp.SetCollisionResponseToChannel(ECollisionChannel::WeaponTrace, ECollisionResponse::ECR_Block);

    return BoxComp;
}

UFUNCTION()
USphereComponent SetEnemySphereCollisionResponses(USphereComponent InSphereComp)
{
    USphereComponent SphereComp = InSphereComp;
    SphereComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
    SphereComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);
    SphereComp.SetCollisionResponseToChannel(ECollisionChannel::PlayerCharacter, ECollisionResponse::ECR_Block);
    SphereComp.SetCollisionResponseToChannel(ECollisionChannel::EnemyCharacter, ECollisionResponse::ECR_Ignore);
    SphereComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Block);
    SphereComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Block);
    SphereComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_WorldDynamic, ECollisionResponse::ECR_Block);
    SphereComp.SetCollisionResponseToChannel(ECollisionChannel::WeaponTrace, ECollisionResponse::ECR_Block);

    return SphereComp;
}