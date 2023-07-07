namespace MathStatic
{

}

struct FTimeToTargetFloat
{
    private float Target;
    private float StartingDistance;
    private float Value;

    //Calculates towards target
    //If new target for this struct, then resets the values and calculates over time again
    //Saves value for this struct
    void CalculateToTarget(float InTarget, float DeltaTime, float TargetTime)
    {
        if (Target != InTarget)
        {
            Target = InTarget;
            StartingDistance = Target - Value;
        }
        
        float Distance = Math::Abs(Value - Target);

        if (Distance < Math::Abs(StartingDistance * DeltaTime / TargetTime)) 
            Value = Target;
        else
            Value += StartingDistance * DeltaTime / TargetTime;
    }

    //Get current value for this struct
    float GetValue()
    {
        return Value;
    }

    void SnapTo(float InValue)
    {
        Value = InValue;
    }
}

struct FInterpAxisTo
{
    float Target;
    float StartingDistance;

    //Converts angle to a value betwen -360 and 360
    float ConvertAngle(float Angle)
    {
        float RotCheck = Math::Abs(Angle) / 360.f;
        int CycleCount = 0.f;

        if (RotCheck > 1.f)
            CycleCount = Math::RoundToInt(RotCheck);
        
        float MultipliedAbsolute = 360 * CycleCount;
        float ConvertedTarget = Angle - MultipliedAbsolute;

        return ConvertedTarget;
    }

    //Converts negative angle to positive angle
    float AbsAxis(float Angle)
    {
        if (Angle < 0.f)
            return Angle + 360.f;

        return Angle;    
    }

    void CalculateToTarget(float& Current, float InTarget, float DeltaTime, float InterpSpeed, float Threshold)
    {
        float ConvertedTarget = ConvertAngle(InTarget);
        ConvertedTarget = AbsAxis(ConvertedTarget);

        if (Target != ConvertedTarget)
        {
            //Set initial current conversion
            Current = ConvertAngle(Current);

            //Check distance to travel to target after conversion
            float TravelDistance = Math::Abs(ConvertedTarget - Current);

            //If distance between the values is greater 180
            if (TravelDistance > 180.f)
            {
                //if current is greater than 180 and converted is less than 180, reduce current by 360 to get degrees closest to target
                //else if current is less than 180 and target is greater than 180, add 360 degrees to current to get closest converted value to target
                if (Current > 180.f && ConvertedTarget < 180.f)
                    Current -= 360.f;
                else if (Current < 180.f && ConvertedTarget > 180.f)
                    Current += 360.f;
            }

            Target = ConvertedTarget;
            StartingDistance = Target - Current;
        }

        if (Math::Abs(Current - Target) <= Threshold)
            Current = Target;
        else
            Current = Math::FInterpTo(Current, Target, DeltaTime, InterpSpeed);
    }
}

struct FOverTimeAxisTo
{
    float Target;
    float StartingDistance;

    //Converts angle to a value betwen -360 and 360
    float ConvertAngle(float Angle)
    {
        float RotCheck = Math::Abs(Angle) / 360.f;
        int CycleCount = 0.f;

        if (RotCheck > 1.f)
            CycleCount = Math::RoundToInt(RotCheck);
        
        float MultipliedAbsolute = 360 * CycleCount;
        float ConvertedTarget = Angle - MultipliedAbsolute;

        return ConvertedTarget;
    }

    //Converts negative angle to positive angle
    float AbsAxis(float Angle)
    {
        if (Angle < 0.f)
            return Angle + 360.f;

        return Angle;    
    }

    void CalculateToTarget(float& Current, float InTarget, float DeltaTime, float TargetTime)
    {
        float ConvertedTarget = ConvertAngle(InTarget);
        ConvertedTarget = AbsAxis(ConvertedTarget);

        if (Target != ConvertedTarget)
        {
            //Set initial current conversion
            Current = ConvertAngle(Current);

            //Check distance to travel to target after conversion
            float TravelDistance = Math::Abs(ConvertedTarget - Current);

            //If distance between the values is greater 180
            if (TravelDistance > 180.f)
            {
                //if current is greater than 180 and converted is less than 180, reduce current by 360 to get degrees closest to target
                //else if current is less than 180 and target is greater than 180, add 360 degrees to current to get closest converted value to target
                if (Current > 180.f && ConvertedTarget < 180.f)
                    Current -= 360.f;
                else if (Current < 180.f && ConvertedTarget > 180.f)
                    Current += 360.f;
            }

            Target = ConvertedTarget;
            StartingDistance = Target - Current;
        }

        float Distance = Math::Abs(Current - Target);

        if (Distance < Math::Abs(StartingDistance * DeltaTime / TargetTime)) 
            Current = Target;
        else
            Current += StartingDistance * DeltaTime / TargetTime;
    }
}

enum EAxisToIgnore
{
    Pitch,
    Yaw,
    Roll
}

//Needs a rewrite or possible different solution
struct FInterpExcludeAxisRotateTo
{
    FInterpAxisTo PitchAxis;
    FInterpAxisTo YawAxis;
    FInterpAxisTo RollAxis;

    void CalculateToTarget(EAxisToIgnore IgnoreAxis, FRotator& Current, FRotator InTarget, float DeltaTime, float InterpSpeed, float Threshold)
    {
        float Pitch = Current.Pitch;
        float Yaw = Current.Yaw;
        float Roll = Current.Roll;

        if (IgnoreAxis != EAxisToIgnore::Pitch)
            PitchAxis.CalculateToTarget(Pitch, InTarget.Pitch, DeltaTime, InterpSpeed, Threshold);
        if (IgnoreAxis != EAxisToIgnore::Yaw)
            PitchAxis.CalculateToTarget(Yaw, InTarget.Yaw, DeltaTime, InterpSpeed, Threshold);
        if (IgnoreAxis != EAxisToIgnore::Roll)
            PitchAxis.CalculateToTarget(Roll, InTarget.Roll, DeltaTime, InterpSpeed, Threshold);

        Current = FRotator(Pitch, Yaw, Roll);
    }
}

struct FOverTimeExcludeAxisRotateTo
{

}

