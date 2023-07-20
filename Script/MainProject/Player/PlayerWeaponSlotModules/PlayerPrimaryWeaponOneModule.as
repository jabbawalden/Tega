class UPlayerPrimaryWeaponOneModule : UPlayerBaseWeaponSlotModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(PlayerWeaponTags::PlayerPrimaryOne);

    default InputTag = InputNames::RightTrigger;

    void Setup() override
    {
        Super::Setup();
        WeaponSlot = Player.PlayerPrimaryWeaponOne;
    }

    void OnActivated() override
    {
        Super::OnActivated();
        
    }

    void OnDeactivated() override
    {
        Super::OnDeactivated();
        
    }

    void Update(float DeltaTime) override
    {
        Super::Update(DeltaTime);
        
    }
}