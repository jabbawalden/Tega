struct FModuleTickGroup
{
    UPROPERTY()
    FName TickGroup;

    TArray<UModule> ModuleArray;
}

//The module game mode runs all module behaviors in the game
//To make your own game mode, make sure to inherit from this one can call Super::Tick in Tick to ensure everything runs
class AModuleGameMode : AGameMode
{
    //Alternate Method, will require a rebuild of how things work
    UPROPERTY()
    TArray<FModuleTickGroup> ModuleTickGroups;

    TArray<FModuleTickGroup> ModuleRequestShouldAdd;
    TArray<FModuleTickGroup> ModuleRequestShouldRemove;
    TArray<FModuleTickGroup> ModuleCheckShouldActivateGroups;
    TArray<FModuleTickGroup> ModuleIsActiveGroups;
    TArray<FModuleTickGroup> ModuleBlockedGroups;
    //TODO looking into implementomg swapping behaviours between groups 
    /* 
    //
    Starts in Should Activates,
    If true, move to Is Active group
    Use Is Active group to check if should deactivate
    Any blocks get sent to blocked groups and deactivate
    Unblocks get removed from blocked groups, then sent to should activate groups 
    This could be cheaper rather than running through lot's of lists where duplicate behaviours exist
    */

    //Tags that have been blocked
    TArray<FName> BlockedTags;

    //All blocked modules
    TArray<FModuleBlockData> BlockedModuleArray;

    //Modules to be added
    TArray<UModule> RequestAddModuleArray;

    //Modules that should be removed at the end of a cycle
    TArray<UModule> RequestRemoveModulesArray;

    //All modules
    TArray<UModule> ModuleArray;

    TArray<UModule> CheckInitiation;
    TArray<UModule> CheckInputVectors;
    TArray<UModule> CheckInputActions;
    TArray<UModule> CheckPreMovement;
    TArray<UModule> CheckMovement;
    TArray<UModule> CheckGameplay;
    TArray<UModule> CheckAfterGameplay;
    TArray<UModule> CheckLast;

    //Update groups
    TArray<UModule> UpdateInitiation;
    TArray<UModule> UpdateInputVectors;
    TArray<UModule> UpdateInputActions;
    TArray<UModule> UpdateCalculateMovement;
    TArray<UModule> UpdateRunMovement;
    TArray<UModule> UpdateGameplay;
    TArray<UModule> UpdateAfterGameplay;
    TArray<UModule> UpdateLast;

    //Nothing here (yet?)
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        
    }

    //Tick which runs all module behaviours
    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime)
    {
        // PrintToScreen("GAME MODE TICK GROUP: " + TickGroup);
        // TickGroup = ETickingGroup::TG_DuringPhysics;

        //DEBUG TICK to see list of all modules and their owning actor
        // for (UModule Mod : UpdateGameplay)
        // {
        //     PrintToScreen("Mod: " + Mod.Name + " Active UpdateGameplay: " + Mod.Owner.Name);
        // }
        // for (UModule Mod : ModuleArray)
        // {
        //     if (Mod.bDebugOn)
        //         PrintToScreen("Mod: " + Mod.Name + " Behaviour Module: " + Mod.Owner.Name);
        // }

        //Checks through add module requests to see what modules should be added
        RunAddRequestsCheck();

        //Runs all deactivate checks (and deactivation functions) in known all modules
        //Better to run exit logic first before running enter logic for modules to avoid awkard situations 
        //For example: a state is set to a specific value on activation in one module, but then changed to something else in deactivation in another module
        RunShouldDeactivateChecks();

        //Runs all activate checks (and activation functions) in known all modules once deactivations are complete
        RunShouldActivateChecks();

        //Runs updates for modules that are active
        RunModuleUpdates(DeltaTime);

        //Checks if any modules have been requested for removal
        //Runs last to ensure that module arrays aren't altered during their loop
        RunRemoveModuleRequests();
    }

    //For modules that are eligible and exist in the request add array, add to check groups
    void RunAddRequestsCheck()
    {
        if (RequestAddModuleArray.Num() == 0)
                return;

        for (UModule Module : RequestAddModuleArray)
        {
            if (Module.bDebugOn)
            {
                Print("" + Module.Name + " Add Request: " + Module.Owner.Name);
            }

            ModuleArray.Add(Module);
            Module.Setup();
            SetModuleGroup(Module); 
        }

        RequestAddModuleArray.Empty();
    }

    //If not blocked and we should deactivate, remove from update arrays
    void RunShouldDeactivateChecks()
    {
        TArray<UModule> TempUpdatePreGame = UpdateInitiation;
        TArray<UModule> TempUpdateInputVectors = UpdateInputVectors;
        TArray<UModule> TempUpdateInputActions = UpdateInputActions;
        TArray<UModule> TempUpdateCalculateMovement = UpdateCalculateMovement;
        TArray<UModule> TempUpdateMakeMovement = UpdateRunMovement;
        TArray<UModule> TempUpdateGameplay = UpdateGameplay;
        TArray<UModule> TempUpdateAfterGameplay = UpdateAfterGameplay;
        TArray<UModule> TempUpdateLast = UpdateLast;

        for (UModule Module : TempUpdatePreGame)
        {
            if (Module.CheckShouldDeactivate())
            {
                Module.OnDeactivated();
                UpdateInitiation.Remove(Module);
            }
        }

        for (UModule Module : TempUpdateInputVectors)
        {
            if (Module.CheckShouldDeactivate())
            {
                Module.OnDeactivated();
                UpdateInputVectors.Remove(Module);
            }
        }
        
        for (UModule Module : TempUpdateInputActions)
        {
            if (Module.CheckShouldDeactivate())
            {
                Module.OnDeactivated();
                UpdateInputActions.Remove(Module);
            }
        }

        for (UModule Module : TempUpdateCalculateMovement)
        {
            if (Module.CheckShouldDeactivate())
            {
                Module.OnDeactivated();
                UpdateCalculateMovement.Remove(Module);
            }
        }


        for (UModule Module : TempUpdateMakeMovement)
        {
            if (Module.CheckShouldDeactivate())
            {
                Module.OnDeactivated();
                UpdateRunMovement.Remove(Module);
            }
        }


        for (UModule Module : TempUpdateGameplay)
        {
            if (Module.CheckShouldDeactivate())
            {
                Module.OnDeactivated();
                UpdateGameplay.Remove(Module);
            }
        }


        for (UModule Module : TempUpdateAfterGameplay)
        {
            if (Module.CheckShouldDeactivate())
            {
                Module.OnDeactivated();
                UpdateAfterGameplay.Remove(Module);
            }
        }


        for (UModule Module : TempUpdateLast)
        {
            if (Module.CheckShouldDeactivate())
            {
                Module.OnDeactivated();
                UpdateLast.Remove(Module);
            }
        }         
    }

    void RunShouldActivateChecks()
    {
        for (UModule Module : CheckInitiation)
        {
            if (Module.CheckShouldActivate())
            {
                Module.OnActivated();
                UpdateInitiation.Add(Module);
            }
        }

        for (UModule Module : CheckInputVectors)
        {
            if (Module.CheckShouldActivate())
            {
                Module.OnActivated();
                UpdateInputVectors.Add(Module);
            }
        }

        for (UModule Module : CheckInputActions)
        {
            if (Module.CheckShouldActivate())
            {
                Module.OnActivated();
                UpdateInputActions.Add(Module);
            }
        }

        for (UModule Module : CheckPreMovement)
        {
            if (Module.CheckShouldActivate())
            {
                Module.OnActivated();
                UpdateCalculateMovement.Add(Module);
            }
        }

        for (UModule Module : CheckMovement)
        {
            if (Module.CheckShouldActivate())
            {
                Module.OnActivated();
                UpdateRunMovement.Add(Module);
            }
        }

        for (UModule Module : CheckGameplay)
        {
            if (Module.CheckShouldActivate())
            {
                Module.OnActivated();
                UpdateGameplay.Add(Module);
            }
        }

        for (UModule Module : CheckAfterGameplay)
        {
            if (Module.CheckShouldActivate())
            {
                Module.OnActivated();
                UpdateAfterGameplay.Add(Module);
            }
        }

        for (UModule Module : CheckLast)
        {
            if (Module.CheckShouldActivate())
            {
                Module.OnActivated();
                UpdateLast.Add(Module);
            }
        }     
    }

    void RunModuleUpdates(float DeltaTime)
    {
        for (UModule Module : UpdateInitiation)
        {
            Module.Update(DeltaTime);
        }

        for (UModule Module : UpdateInputVectors)
        {
            Module.Update(DeltaTime);
        }

        for (UModule Module : UpdateInputActions)
        {
            Module.Update(DeltaTime);
        }

        for (UModule Module : UpdateCalculateMovement)
        {
            Module.Update(DeltaTime);
        }

        for (UModule Module : UpdateRunMovement)
        {
            Module.Update(DeltaTime);
        }

        for (UModule Module : UpdateGameplay)
        {
            Module.Update(DeltaTime);
        }

        for (UModule Module : UpdateAfterGameplay)
        {
            Module.Update(DeltaTime);
        }

        for (UModule Module : UpdateLast)
        {
            Module.Update(DeltaTime);
        }
    }

    //Removes module from modules to remove request array
    //Runs onremoved function
    //Removes from module array
    //If blocked, removes from blocked list without running onunblocked function
    //Removes from update and check lists
    void RunRemoveModuleRequests()
    {
        // TArray<UModule> CurrentArray = ModuleArray;

        if (RequestRemoveModulesArray.Num() == 0)
            return;

        for (UModule RemoveModule : RequestRemoveModulesArray)
        {
            RemoveModule.OnRemoved();
            RemoveModule.bIsBlocked = false;
            ModuleArray.Remove(RemoveModule);

                switch(RemoveModule.ModuleUpdateGroup)
                {
                    case EModuleUpdateGroup::Initiation:
                        if (UpdateInitiation.Contains(RemoveModule))
                            UpdateInitiation.Remove(RemoveModule);
                        CheckInitiation.Remove(RemoveModule);
                        break;

                    case EModuleUpdateGroup::InputVectors: 
                        if (UpdateInputVectors.Contains(RemoveModule))
                            UpdateInputVectors.Remove(RemoveModule);
                        CheckInputVectors.Remove(RemoveModule);
                        break;

                    case EModuleUpdateGroup::InputActions: 
                        if (UpdateInputActions.Contains(RemoveModule))
                            UpdateInputActions.Remove(RemoveModule);
                        CheckInputActions.Remove(RemoveModule);
                        break;

                    case EModuleUpdateGroup::CalculateMovement: 
                        if (UpdateCalculateMovement.Contains(RemoveModule))
                            UpdateCalculateMovement.Remove(RemoveModule);
                        CheckPreMovement.Remove(RemoveModule);
                        break;

                    case EModuleUpdateGroup::RunMovement: 
                        if (UpdateRunMovement.Contains(RemoveModule))
                            UpdateRunMovement.Remove(RemoveModule);
                        CheckMovement.Remove(RemoveModule);
                        break;

                    case EModuleUpdateGroup::Gameplay: 
                        if (UpdateGameplay.Contains(RemoveModule))
                            UpdateGameplay.Remove(RemoveModule);
                        CheckGameplay.Remove(RemoveModule);
                        break;

                    case EModuleUpdateGroup::AfterGameplay: 
                        if (UpdateAfterGameplay.Contains(RemoveModule))
                            UpdateAfterGameplay.Remove(RemoveModule);
                        CheckAfterGameplay.Remove(RemoveModule);
                        break;

                    case EModuleUpdateGroup::Last: 
                        if (UpdateLast.Contains(RemoveModule))
                            UpdateLast.Remove(RemoveModule);
                        UpdateLast.Remove(RemoveModule);
                        break;
                }
        }

        RequestRemoveModulesArray.Empty();
    }

    void BlockModulesWithTag(FName Tag, UObject Blocker)
    {
        FModuleBlockData BlockData;
        BlockData.Tag = Tag;
        BlockData.Instigator = Blocker;

        bool bFoundSameInstigator = false;

        for (FModuleBlockData Data : BlockedModuleArray)
        {
            if (Data.Instigator == Blocker && Data.Tag == Tag)
            {
                bFoundSameInstigator = true;
                PrintError("BLOCKING " + Tag + " WITH SAME INSTIGATOR: " + Blocker.Name, 10.f);
            }
        }

        if (!bFoundSameInstigator)
            BlockedModuleArray.Add(BlockData);

        for (UModule Mod : ModuleArray)
        {
            for (FName CurrentTag : Mod.Tags)
            {
                if (CurrentTag == Tag)
                    Mod.bIsBlocked = true;
            }
        }
    }

    void UnblockModulesWithTag(FName Tag, UObject Blocker)
    {
        FModuleBlockData DataToRemove;

        int NumberOfBlocksForTag = 0;

        for (FModuleBlockData Data : BlockedModuleArray)
        {
            if (Data.Instigator == Blocker && Data.Tag == Tag)
                DataToRemove = Data;

            if (Data.Tag == Tag)
                NumberOfBlocksForTag++;
        }

        if (DataToRemove.Tag == Tag)
            BlockedModuleArray.Remove(DataToRemove);
        else 
            PrintError("NO BLOCKS FOUND FOR " + Tag, 10.f);

        //Only found 1 block left for this tag, therefore we can tell it not to be blocked anymore
        if (NumberOfBlocksForTag == 1)
        {
            for (UModule Mod : ModuleArray)
            {
                for (FName CurrentTag : Mod.Tags)
                {
                    if (CurrentTag == Tag)
                        Mod.bIsBlocked = false;
                }
            }     
        }
    }

    private void SetModuleGroup(UModule NewModule)
    {
        switch(NewModule.ModuleUpdateGroup)
        {
            case EModuleUpdateGroup::Initiation: 
                CheckInitiation.Add(NewModule);
                break;
            case EModuleUpdateGroup::InputVectors: 
                CheckInputVectors.Add(NewModule);
                break;
            case EModuleUpdateGroup::InputActions: 
                CheckInputActions.Add(NewModule);
                break;
            case EModuleUpdateGroup::CalculateMovement: 
                CheckPreMovement.Add(NewModule);
                break;
            case EModuleUpdateGroup::RunMovement: 
                CheckMovement.Add(NewModule);
                break;
            case EModuleUpdateGroup::Gameplay: 
                CheckGameplay.Add(NewModule);
                break;
            case EModuleUpdateGroup::AfterGameplay: 
                CheckAfterGameplay.Add(NewModule);
                break;
            case EModuleUpdateGroup::Last: 
                CheckLast.Add(NewModule);
                break;
        }
    }

    //Checks if module is not already added. If not, then add to request to add array
    void SetAddModuleRequest(UModule NewModule, AActor AddInstigator)
    {
        if (!ModuleArray.Contains(NewModule))
        {
            NewModule.Owner = AddInstigator;
            RequestAddModuleArray.Add(NewModule);
        }
    }

    //Checks if module is added. if so, add to request to remove array
    void SetRemoveModuleRequest(UModule RemoveModule)
    {
        if (ModuleArray.Contains(RemoveModule))
        {
            RequestRemoveModulesArray.Add(RemoveModule);
        }
    }
}