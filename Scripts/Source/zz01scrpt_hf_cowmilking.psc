Scriptname zz01SCRPT_HF_CowMilking extends Actor  
{This script is for milking cows}
;==============================================================


Import Game
Import Utility
Import Debug
Import Math

Potion Property BYOHFoodMilk Auto
{Click "Auto-Fill" to place milk here}

Int Property HowManyMilkPer Auto
{Seleect amount of milk to be gained per milking, e.g, 1, 2, etc.}

String Property WhatYouGot Auto
{Add the notification that will be shown when milked eg, 1 Milk Added}

MISCOBJECT PROPERTY Bucket AUTO
{Add a bucket to go under the cow, unless you use the static version below}

Float Property DaystoWait Auto
{Select amount of days to wait between milking, e.g 1.00, 2.00 etc.}

Static Property XMarker Auto
{Auto-Fill for XMarker or add static non-collision bucket, must be used to set player direction}

sound property MilkingSound auto
{Find a sound to play once per second while milking}

Idle Property IdleStop_Loose Auto
{Autofill}

String property FailureMessage auto
{Message that appears when you have already milked this cow today}

Float OffsetAngle
Float OffsetDistance

ObjectReference MilkingBucket
ObjectReference XMarkCrouch

float property lastHarvestedDay auto Hidden
{the game day this was last successfuly harvested, used to know when to respawn}

Int CowIsDead = 0

;===================================================================
;;STATE BLOCK
;===================================================================

auto state readyForHarvest
event onActivate(objectReference akActivator)
goToState("waitingToRespawn")
fakeHarvest(akActivator)
endEvent
endState

state waitingToRespawn
event onBeginState()
lastHarvestedDay = utility.getCurrentGameTime()
endEvent

event onActivate(objectReference akActivator)
If (lastHarvestedDay + DaystoWait) <= utility.getCurrentGameTime() && !(CowIsDead == 1)
goToState("readyForHarvest")
Else
Notification(FailureMessage)
EndIf
endEvent


endState

;===================================================================
;;FUNCTION BLOCK
;===================================================================


Event OnDeath(Actor akKiller)

CowIsDead = 1

EndEvent

;--------------------------------------------------------------------------------
function fakeHarvest(objectReference akActivator)

if (akActivator as actor)
Actor Player = Game.GetPlayer()
If CowIsDead == 1
Else
self.EnableAI(FALSE)
Debug.SendAnimationEvent(Self, "cowFeedStart")
MilkingBucket = Self.PlaceAtMe(Bucket)
MilkingBucket.SetScale(0.5)
MilkingBucket.MoveTo(Self, -50 * Math.Sin(Self.GetAngleZ()), -50 * Math.Cos(Self.GetAngleZ()), abMatchRotation = true)
Game.ForceThirdPerson()
Game.DisablePlayerControls(abMovement = true, abFighting = false, abCamSwitch = true, abLooking = false, abSneaking = false, abMenu = true, abActivate = false, abJournalTabs = false)
XMarkCrouch = MilkingBucket.PlaceAtMe(XMarker)
XMarkCrouch.MoveTo(Self, -45 * Math.Sin(Self.GetAngleZ()), -45 * Math.Cos(Self.GetAngleZ()), abMatchRotation = true)
Utility.Wait(0.5)
Game.SetPlayerAIDriven()
Player.SetLookAt(XMarkCrouch , true)
;float AngleZ = XMarkCrouch .GetAngleZ() + OffsetAngle
;float AngleX = XMarkCrouch .GetAngleZ() + OffsetAngle
;float OffsetX = OffsetDistance * Math.Sin(AngleX) + 50
;float OffsetY = OffsetDistance * Math.Cos(AngleZ)

Float BucketAngleZ = (XMarkCrouch.GetAngleZ() + 85)
Player.MoveTo(XMarkCrouch, -55 * Math.Sin(BucketAngleZ ), -55 * Math.Cos(BucketAngleZ ))
Player.SetLookAt(XMarkCrouch, true)
Utility.wait(1.5)
Debug.SendAnimationEvent(Player, "IdleWarmHandsCrouched")
Utility.wait(1.0)
int instanceID = MilkingSound.play(self)
Utility.wait(0.4)
Sound.StopInstance(instanceID)
Utility.wait(1.0)
int instanceID2 = MilkingSound.play(self)
Utility.wait(0.4)
Sound.StopInstance(instanceID2)
Utility.wait(1.0)
int instanceID3 = MilkingSound.play(self)
Utility.wait(0.4)
Sound.StopInstance(instanceID3)
Utility.wait(1.0)
int instanceID4 = MilkingSound.play(self)
Utility.wait(0.4)
Sound.StopInstance(instanceID4)
Utility.wait(1.0)

Player.PlayIdle(IdleStop_Loose)
Game.EnablePlayerControls()
self.EnableAI(TRUE)
Self.MoveTo(XMarkCrouch, 60 * Math.Sin(XMarkCrouch.GetAngleZ()), 60 * Math.Cos(XMarkCrouch.GetAngleZ()), abMatchRotation = true)
MilkingBucket.Delete()
XMarkCrouch.Delete()
Utility.wait(1.0)
Game.ForceFirstPerson()
Game.SetPlayerAIDriven(False)

Player.AddItem(BYOHFoodMilk, HowManyMilkPer, True)
Notification(WhatYouGot)

EndIf
EndIf
EndFunction