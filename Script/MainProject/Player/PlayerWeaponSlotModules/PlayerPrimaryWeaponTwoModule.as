class UPlayerPrimaryWeaponTwoModule : UPlayerBaseWeaponSlotModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(PlayerWeaponTags::PlayerPrimaryTwo);

    default InputTag = InputNames::LeftTrigger;

    void Setup() override
    {
        Super::Setup();
        WeaponSlot = Player.PlayerPrimaryWeaponTwo;
    }
}