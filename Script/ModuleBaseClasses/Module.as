struct FModuleBlockData
{
    bool bIsBlocked;
    FName Tag("NoTag");
    UObject Instigator = nullptr;
}

struct FAttributeObject
{
    FName Name;
    UObject Object;
}

//Contains the types of update groups that run in order in the module game mode class
enum EModuleUpdateGroup
{
    Initiation,
    InputVectors,
    InputActions,
    CalculateMovement,
    RunMovement,
    Gameplay,
    AfterGameplay,
    Last
}

//This is the module base class
//It acts similarly to components, except communication is reversed. The module knows all about the actor, but the actor knows nothing about the module
//This allows for the creation of separate behaviours that are not directly dependant on each other, and that can be added, activate, deactivated and removed dynamically during gameplay 
//The result is that code is more compartmentalized

//The recommended setup is that mod actors hold all the functionality and components, and modules run all the behaviours and moment to moment gameplay
//Think of this as a kind of state machine, except any state can run at any time depending on the requirements that are set in the should activate and deactivate functions

class UModule : UObject
{
    //The update group that the module will run in each frame
    EModuleUpdateGroup ModuleUpdateGroup;

    //An object reference to the owning actor for the module
    //You can cast with the actors class to this owner to get a direct reference
    AActor Owner;

    // FName ModuleName;

    TArray<FName> Tags;

    bool bIsActive = false;
    bool bIsBlocked = false;
    bool bDebugOn = false;

    //Runs immediately when the module is added. Place all reference and other important setups here
    void Setup()
    {

    }

    //Decides whether this module should be active
    //Typically read from variables like states and bools, or other conditions from the owning actor
    bool ShouldActivate()
    {
        return false;
    }

    //Decides whether this module should be inactive
    //Typically read from variables like states and bools, or other conditions from the owning actor
    bool ShouldDeactivate()
    {
        return false;
    }

    // //module game mode runs this to check for activations 
    bool CheckShouldActivate() 
    {
        if (bIsBlocked)
            return false;

        if (ShouldActivate())
        {
            if (!bIsActive)
            {
                bIsActive = true;
                return true;
            }
        }

        return false;
    }

    // //module game mode runs this to check for deactivations 
    bool CheckShouldDeactivate()
    {
        if (bIsBlocked && bIsActive)
        {
            bIsActive = false;
            return true;
        }

        if (ShouldDeactivate())
        {
            //Deactivate if blocked

            if (bIsActive)
            {
                bIsActive = false;
                return true;
            }
        }

        return false;
    }

    //module game mode runs this to check whether to update 
    bool CanRunUpdate()
    {
        return bIsActive;
    }

    //When activated, this will run
    void OnActivated()
    {

    }

    //When deactivated, this will run
    void OnDeactivated()
    {

    }

    //When active, update runs per frame
    void Update(float DeltaTime)
    {

    }

    //Runs when the module is Blocked via tag
    void OnBlocked()
    {

    }

    //Runs when the module is Unblocked via tag
    void OnUnblocked()
    {

    }

    //Runs when the module is removed from an actor
    void OnRemoved()
    {
        
    }
}

