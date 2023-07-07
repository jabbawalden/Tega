namespace Game 
{
    APlayerVessel GetPlayer()
    {
        // ATegaGameMode GameMode = Cast<ATegaGameMode>(Gameplay::GameMode);
        APlayerVessel Player = Cast<APlayerVessel>(Gameplay::GetPlayerPawn(0));
        return Player;
    }
}