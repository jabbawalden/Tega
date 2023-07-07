struct FModuleSheetData
{
    FName DataAssetName;
    TArray<UModule> ModuleArray;
    UObject Owner;
}

class UModuleSheet : UDataAsset
{
    UPROPERTY()
    TArray<TSubclassOf<UModule>> ModuleClassArray;

    TArray<UModule> ModuleArray;

    void SetModuleArray()
    {
        ModuleArray.Empty();

        for (int i = 0; i < ModuleClassArray.Num(); i++)
        {
            UModule NewModule = Cast<UModule>(NewObject(this, ModuleClassArray[i]));
            ModuleArray.Add(NewModule);
        }
    }
}