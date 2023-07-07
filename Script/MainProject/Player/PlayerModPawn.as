//Has all Mod Actor functionality with the exception of access to the Tega Game Mode
class APlayerModPawn : APawn
{
    TArray<UModule> ModuleArray;

    TArray<FAttributeObject> AttributeObjectArray;

    TArray<FModuleSheetData> ModuleSheetDataArray;

    private AModuleGameMode GameMode;

    ATegaGameMode GetTegaGameMode()
    {
        ATegaGameMode TegaMode = Cast<ATegaGameMode>(Gameplay::GameMode);
        return TegaMode;
    }

    void AddModule(TSubclassOf<UModule> InModule)
    {
        if (GameMode == nullptr)
            GameMode = Cast<AModuleGameMode>(Gameplay::GameMode);
        
        UModule NewModule = Cast<UModule>(NewObject(this, InModule));
        GameMode.SetAddModuleRequest(NewModule, this);
    }

    void AddModule(UModule InModule)
    {
        if (GameMode == nullptr)
            GameMode = Cast<AModuleGameMode>(Gameplay::GameMode);

        GameMode.SetAddModuleRequest(InModule, this);
    }

    void AddModuleSheet(UModuleSheet Sheet)
    {
        Sheet.SetModuleArray();
        
        if (GameMode == nullptr)
            GameMode = Cast<AModuleGameMode>(Gameplay::GameMode);
        
        FModuleSheetData ModuleStoredData;
        ModuleStoredData.DataAssetName = Sheet.Name;
        ModuleStoredData.ModuleArray = Sheet.ModuleArray;
        ModuleStoredData.Owner = this;
        ModuleSheetDataArray.Add(ModuleStoredData);

        for (UModule NewModule : Sheet.ModuleArray)
        {
            GameMode.SetAddModuleRequest(NewModule, this);
        }
    }

    void RemoveModule(TSubclassOf<UModule> InModule)
    {
        if (GameMode == nullptr)
            GameMode = Cast<AModuleGameMode>(Gameplay::GameMode);
        
        UModule NewModule = Cast<UModule>(NewObject(this, InModule));

        GameMode.SetRemoveModuleRequest(NewModule);
    }

    void RemoveModule(UModule InModule)
    {
        if (GameMode == nullptr)
            GameMode = Cast<AModuleGameMode>(Gameplay::GameMode);

        GameMode.SetRemoveModuleRequest(InModule);
    }

    void RemoveModuleSheet(UModuleSheet Sheet)
    {
        if (GameMode == nullptr)
            GameMode = Cast<AModuleGameMode>(Gameplay::GameMode);

        FModuleSheetData SheetDataCopy;

        for (FModuleSheetData Data : ModuleSheetDataArray)
        {
            if (Data.DataAssetName == Sheet.Name)
            {
                SheetDataCopy = Data;
                continue;
            }
        }

        for (UModule NewModule : SheetDataCopy.ModuleArray)
        {
            GameMode.SetRemoveModuleRequest(NewModule);
        }
    }

    void BlockModule(FName Tag, UObject Blocker)
    {
        if (GameMode == nullptr)
            GameMode = Cast<AModuleGameMode>(Gameplay::GameMode);
        
        GameMode.BlockModulesWithTag(Tag, Blocker);
    }

    void UnblockModule(FName Tag, UObject Blocker)
    {
        if (GameMode == nullptr)
            GameMode = Cast<AModuleGameMode>(Gameplay::GameMode);

        GameMode.UnblockModulesWithTag(Tag, Blocker);
    }

    void SetAttributeObject(FName ObjectName, UObject Object)
    {
        FAttributeObject NewAttribute;
        NewAttribute.Name = ObjectName;
        NewAttribute.Object = Object;

        AttributeObjectArray.Add(NewAttribute);
    }

    UObject GetAttributeObject(FName ObjectName)
    {
        for (FAttributeObject Attribute : AttributeObjectArray)
        {
            if (Attribute.Name == ObjectName)
                return Attribute.Object;
        }
    
        return nullptr;
    }
}