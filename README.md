# Vehicle Crash Engine Script

## Brief Overview
This GitHub repository contains the Vehicle Crash Engine Script for FiveM. The script enhances the realism of vehicle crashes in-game by disabling the vehicle's engine upon significant damage. It actively monitors the health of vehicles and applies engine damage effects, creating a more immersive gameplay experience.

## Configuration File Documentation
The script is customizable through its configuration file `config.lua`. Key configuration options include:

- `DisplayTimer`: Boolean value to toggle the display of a countdown timer when the engine is damaged.
- `VehicleDamageTimings`: An array of objects, each defining a damage range and corresponding engine off time. Each object has two properties:
  - `DamageRange`: Object specifying the minimum (`Min`) and maximum (`Max`) damage values.
  - `TimeRange`: Object indicating the minimum (`Min`) and maximum (`Max`) time in seconds for which the engine will remain off.

The script uses these settings to dynamically calculate the engine off time based on the extent of vehicle damage.
