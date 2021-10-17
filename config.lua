-- Config File --

-- FWMS Version --

FWMSVersion = " v0.26 "

-- Firetruck Models --

fireModels = {"firetruk"}

-- Hydrant Models --

hydrants = {"prop_fire_hydrant_1", "prop_fire_hydrant_2_l1", "prop_fire_hydrant_4", "prop_fire_hydrant_2"}

-- Water Removal Speed --

-- Speed Tables --
-- 5 = ~20 Seconds to reduce tank to 0%
-- 3.3 = ~30 Seconds to reduce tank to 0%
-- 1.6 = ~1 Minute to reduce tank to 0%
-- 0.83 = ~2 Minutes to reduce tank to 0%
-- 0.55 = ~3 Minutes to reduce tank to 0%
-- Change the dischargeSpeed variable below to your desired speed, default is 1.6 or ~1 minute

dischargeSpeed = 1.6

-- UI Position --
-- Change variables below to adjust the position of the indicator lights on your screen. --

topPercent = 50
leftPercent = 20

-- Hose Compatability --
-- Change the hoseOption variable below to your desired hose, see options below
-- extinguisher = default game fire extinguisher
-- hoseLS = enables HoseLS compatability

hoseOption = "extinguisher" 

-- Notification Preference --
-- Change the notiPref variable below to your desired preference for notifications
-- default = default game-based notifcations (no dependency needed)
-- tNotify = notifications through the T-Notify script

notiPref = "default"