Mystery Briefcase addon for Epoch mod
=================

Version 1.0

For discussion & demo video, visit here: 
> http://epochmod.com/forum/index.php?/topic/28388-release-mystery-briefcase/


##Features
Mystery Briefcase is a simple addon script that turns an otherwise completely useless item into a prize-giving briefcase. You obtain the briefcase, right click on it, select Open and you are rewarded with 6 randomly picked items ranging from beans to chainsaws.


##How does it work?
It uses the base briefcase model as an item and turns it into a Mystery Briefcase. The base briefcase model (classnamed ItemBriefcase_Base) isn't used as an item itself leaving it free to mess around with. The base briefcase item doesn't have the same properties as the other briefcases. You cannot add or remove metals from it but it looks exactly the same as the others. It's simply an item that doesn't have a function (until now).


##Requirements
* Epoch mod 1.0.5.1 or later
* [Maca's Right Click Option addon](http://epochservers.com/viewtopic.php?f=14&t=13)


##Installation
1. Firstly, download & install Maca134's ***Right Click Option*** script if you haven't done it already:

	> http://epochservers.com/viewtopic.php?f=14&t=13

1. Click [Download ZIP](https://github.com/Rocu/Epoch_MysterBriefcase/archive/master.zip) on the right side of the page to download the files for Mystery Briefcase

1. Un-pack your mission's PBO (using PBO manager or a similar tool)

	> Copy the ***mbc*** folder into your mission's ***addons*** folder. If you don't have an addons folder in there then create it

1. Open ***description.ext*** (from mission PBO)

1. Find:

	~~~~java
	class DayZ_loadingScreen
	~~~~

1. Above it, add this:

	~~~~java
	class CfgSounds
	{
		sounds[] = {Brief_Open_Sound};
		class Brief_Open_Sound
		{
			name = "Brief_Open_Sound";
			sound[] = {addons\mbc\brief_open.ogg,0.4,1};
			titles[] = {};
		};
	};
	~~~~
	***Note*** if you already have custom sounds in your description.ext then just add the Brief_Open_Sound class manually (using the example above)
	
1.	At the bottom of description.ext, add this:
	
	~~~~java
	// Mystery Briefcase by Rocu
	#include "addons\mbc\dialogs.hpp"
	~~~~
	
1. Save & close description.ext

1. Open up your custom ***compiles.sqf*** file (if you don't have one, [click this link here](http://epochmod.com/forum/index.php?/topic/5211-creating-a-custom-compilessqf/))

1. At the very bottom, add this:

	~~~~java
// Mystery Briefcase by Rocu
call compile preprocessFileLineNumbers "addons\mbc\config.sqf";
	~~~~

1. Save & close ***compiles.sqf***
	
1. Open ***extra_rc.hpp*** (if you installed Maca's script correctly you should have that file in ***\custom\*** folder)

1. Find:

	~~~~java
	class ExtraRc {
	~~~~
	
1. Below it, add:

	~~~~java
class ItemBriefcase_Base {
	class OpenSurpriseBrief {
		text = "Open Briefcase";
		script = "execVM 'addons\mbc\open_brief.sqf'";
	};
};
	~~~~

1. Save & close extra_rc.hpp

1. Re-pack your mission's PBO and you're done!

> If you wish to further configure the script you can do so in ***config.sqf*** file in the ***mbc*** folder.



***Note*** that the briefcase item itself doesn't spawn anywhere by default so you need to add it to the game manually. You can add it to the loot tables or traders using the following class name:

> ItemBriefcase_Base

If you're planning to sell the briefcase in traders I recommend not setting it's price lower than 200,000 (or 2 briefcases if you're not using Single Currency). 