class UPlayerSecondaryWeaponTwoModule : UPlayerBaseWeaponSlotModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(PlayerWeaponTags::PlayerSecondaryTwo);

    default InputTag = InputNames::LeftShoulder;
 
    void Setup() override
    {
        Super::Setup();
        WeaponSlot = Player.PlayerSecondaryWeaponOne;
    }
}