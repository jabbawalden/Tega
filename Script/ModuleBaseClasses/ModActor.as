//Base class for module actors.
//Allows for adding and removing dynamic behaviors knowns as modules
//Contains functionality for adding, remove, and blocking modules via their associated tags
//These are all sent and handled by the module game mode base class

UCLASS(Abstract)
class AModActor : AActor
{
    TArray<UModule> ModuleArray;

    TArray<FAttributeObject> AttributeObjectArray;

    //Stores all data for sheets added to this specific actor. 
    //Necessary beacuse the module sheet data assets are not instances, and reference the exact same sheet. 
    //Therefore the data inside is changed every time that sheet is added to a new actror
    //So we need to store and keep track of which modules we should actually remove from this specific actor
    //Otherwise if read from the sheet asset itself, it will only attempt to remove one set of modules (which will be from the last add module sheet call)
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
                break;
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