class UPlayerSecondaryWeaponOneModule : UPlayerBaseWeaponSlotModule
{
    default ModuleUpdateGroup = EModuleUpdateGroup::Gameplay;

    default Tags.Add(n"Module");
    default Tags.Add(PlayerWeaponTags::PlayerSecondaryOne);

    default InputTag = InputNames::RightShoulder;
 
    void Setup() override
    {
        Super::Setup();
        WeaponSlot = Player.PlayerSecondaryWeaponOne;
    }
}