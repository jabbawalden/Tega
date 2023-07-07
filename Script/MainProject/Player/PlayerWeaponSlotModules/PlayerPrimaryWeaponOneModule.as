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
}