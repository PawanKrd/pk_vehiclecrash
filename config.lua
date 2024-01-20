Config = {}

-- Configuration for displaying the timer
Config.DisplayTimer = true

-- Configuration for crushing times based on damage ranges
Config.VehicleDamageTimings = {
    {
        DamageRange = { Min = 15, Max = 20 },
        TimeRange = { Min = 5, Max = 10 }
    },
    {
        DamageRange = { Min = 21, Max = 30 },
        TimeRange = { Min = 4, Max = 8 }
    },
    {
        DamageRange = { Min = 31, Max = 40 },
        TimeRange = { Min = 8, Max = 12 }
    },
    {
        DamageRange = { Min = 41, Max = 50 },
        TimeRange = { Min = 12, Max = 16 }
    },
    {
        DamageRange = { Min = 51, Max = 60 },
        TimeRange = { Min = 16, Max = 20 }
    },
    {
        DamageRange = { Min = 61, Max = 70 },
        TimeRange = { Min = 20, Max = 24 }
    },
    {
        DamageRange = { Min = 71, Max = 80 },
        TimeRange = { Min = 24, Max = 28 }
    },
    {
        DamageRange = { Min = 81, Max = 90 },
        TimeRange = { Min = 28, Max = 32 }
    },
    {
        DamageRange = { Min = 91, Max = 100 },
        TimeRange = { Min = 32, Max = 36 }
    },
    {
        DamageRange = { Min = 101, Max = 110 },
        TimeRange = { Min = 36, Max = 40 }
    },
    {
        DamageRange = { Min = 111, Max = 2000 },
        TimeRange = { Min = 40, Max = 44 }
    }
}