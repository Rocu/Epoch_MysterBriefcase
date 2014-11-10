disableSerialization;

private ["_item","_spawnCrate","_crateName","_pos","_crateClass","_dir","_selectDelay","_inVehicle"];

(findDisplay 106) closedisplay 0;
closeDialog 0;

_inVehicle = (vehicle player) != player;
if(_inVehicle) exitWith {
	cutText [format["You cannot open %1 in a vehicle.", MBT_NAME] , "PLAIN DOWN"];
};

player playActionNow "Medic";

r_interrupt = false;
_animState = animationState player;
r_doLoop = true;
_started = false;
_finished = false;
_briefSoundPlay = false;
_briefSoundCount = 0;

while {r_doLoop} do {
	_animState = animationState player;
	_isMedic = ["medic",_animState] call fnc_inString;
	_briefSoundCount = _briefSoundCount + 1;
	if (_briefSoundCount > 10 && !_briefSoundPlay) then { //Just to delay the sound a bit
		[objNull, player, rSAY, "Brief_Open_Sound", 30] call RE;
		_briefSoundPlay = true;
	};
	if (_isMedic) then {
		_started = true;
	};
	if (_started and !_isMedic) then {
		r_doLoop = false;
		_finished = true;
	};
	if (r_interrupt) then {
		r_doLoop = false;
	};
	sleep 0.1;
};
r_doLoop = false;

if (!_finished) exitWith { 
	r_interrupt = false;
	if (vehicle player == player) then {
		[objNull, player, rSwitchMove,""] call RE;
		player playActionNow "stop";
	};
	cutText [format["Opening %1 cancelled.",MBT_NAME] , "PLAIN DOWN"];
};

if (_finished) then {

	private ["_dialog","_cashToAdd","_canContinue"];
	mbc_rewardlist_temp = [];
	_canContinue = false;

	_item = "ItemBriefcase_Base";

	if (_item in magazines player) then {
		player removeMagazine _item;
		_canContinue = true;
	};
	
	if (!_canContinue) exitWith { //Anti-duping
		cutText [format["Opening %1 failed.", MBT_NAME] , "PLAIN DOWN"];
	};

	_crateClass = "USOrdnanceBox";

	_dir = getdir player;
	_pos = getposATL player;
	_pos = [(_pos select 0)+1*sin(_dir),(_pos select 1)+1*cos(_dir), (_pos select 2)];

	_spawnCrate = _crateClass createVehicleLocal _pos;

	_spawnCrate setDir _dir;
	_spawnCrate setposATL _pos;
	
	clearWeaponCargoGlobal _spawnCrate;
	clearMagazineCargoGlobal _spawnCrate;
	clearBackpackCargoGlobal _spawnCrate;
	
	_lootRandomizer = [];
	
	//Let's crate an array to randomize loot depending on rarity
	{
		private ["_forEachTempIndexNo"];
		_forEachTempIndexNo = _forEachIndex;
		for "_i" from 1 to (_x select 4) do {
			_lootRandomizer set [count _lootRandomizer, _forEachTempIndexNo];
		};
	} forEach MBC_REWARDLIST;
	
	Sleep 0.2;
	diagLogr = "---------------------------------";
	publicVariable "diagLogr";

	for "_i" from 1 to 6 do {
		private ["_loot","_lootIndex","_lootType"];
		_loot = [];
		_lootIndex = _lootRandomizer call BIS_fnc_selectRandom;
		_loot = + MBC_REWARDLIST;
		_loot = _loot select _lootIndex;
		_lootType = _loot select 0;
		
		//Let's pick the random items out of groups right away, so we can properly display it on the UI
		switch (_lootType) do {
			case "group_wep": {
				Sleep 0.2;
				diagLogr = format["[BRIEF] Before weapon randomizer: %1",_loot];
				publicVariable "diagLogr";
				_groupingArray = _loot select 1;
				_weapon = _groupingArray call BIS_fnc_selectRandom;
				_loot set [1, _weapon]; // Random weapon
				_loot set [2, (1 + floor(random 3))]; // Random amount of mags
			};
			case "group_mag": {
				Sleep 0.2;
				diagLogr = format["[BRIEF] Before magazine randomizer: %1",(_loot select 1)];
				publicVariable "diagLogr";
				_mag = (_loot select 1) call BIS_fnc_selectRandom;
				_loot set [1, _mag]; // Random item
			};
		};
		mbc_rewardlist_temp set [count mbc_rewardlist_temp, _loot];
		_loot = [];
	};
	
	diagLogr = format["[BRIEF] Array created: %1",mbc_rewardlist_temp];
	publicVariable "diagLogr";
	
	UpdateMBCDialog = {
		{
			private ["_pic","_text","_itemName","_qty","_addInfo"];
			
			ctrlSetText [81401, MBT_DIALOG_TITLE];
			ctrlSetText [81402, MBT_DIALOG_CLAIM];
			ctrlSetText [81403, MBT_DIALOG_NOTE];
			
			_addInfo = "";
			switch (_x select 0) do {
				case "group_wep": {
					_pic = getText (configFile >> 'CfgWeapons' >> _x select 1 >> 'picture');
					_itemName = getText (configFile >> 'CfgWeapons' >> _x select 1 >> 'displayName');
					_qty = _x select 2;
					_text = format["%1\n+%2 magazines", _itemName, _qty];
				};
				case "group_mag": {
					_pic = getText (configFile >> 'CfgMagazines' >> _x select 1 >> 'picture');
					_itemName = getText (configFile >> 'CfgMagazines' >> _x select 1 >> 'displayName');
					_qty = _x select 2;
					if (_qty > 1) then {
						_addInfo = format["\nx %1",_qty];
					};
					_text = format["%1%2", _itemName, _addInfo];
				};
				case "coins": {
					_pic = getText (configFile >> 'CfgWeapons' >> 'EvMoney' >> 'picture');
					_qty = _x select 2;
					_text = format["%1 %2", _qty call BIS_fnc_numberText, _x select 1];
				};
				case "weapon": {
					_pic = getText (configFile >> 'CfgWeapons' >> _x select 1 >> 'picture');
					_itemName = getText (configFile >> 'CfgWeapons' >> _x select 1 >> 'displayName');
					_qty = _x select 2;
					if (_qty > 1) then {
						_addInfo = format["\nx %1",_qty];
					};
					_text = format["%1%2", _itemName, _addInfo];
				};
				case "magazine": {
					_pic = getText (configFile >> 'CfgMagazines' >> _x select 1 >> 'picture');
					_itemName = getText (configFile >> 'CfgMagazines' >> _x select 1 >> 'displayName');
					_qty = _x select 2;
					if (_qty > 1) then {
						_addInfo = format["\nx %1",_qty];
					};
					_text = format["%1%2", _itemName, _addInfo];
				};
				case "script": {
					_pic = "";
					_text = _x select 1;
				};
			};
			
			ctrlSetText [81201 + _forEachIndex, _pic];
			ctrlSetText [81301 + _forEachIndex, _text];
			
			_display = findDisplay 81000;
			_frame_ctrl = _display displayCtrl 81101 + _forEachIndex;
			_text_ctrl = _display displayCtrl 81301 + _forEachIndex;
			
			switch (_x select 3) do {
				case 1: {
					_frame_ctrl ctrlSetTextColor [0.6,0.6,0.6,0.5];
					_text_ctrl ctrlSetTextColor [0.6,0.6,0.6,0.5];
				};
				case 2: {
					_frame_ctrl ctrlSetTextColor [1,1,1,0.5];
					_text_ctrl ctrlSetTextColor [1,1,1,0.5];
				};
				case 3: {
					_frame_ctrl ctrlSetTextColor [0.93,0.79,0,0.9];
					_text_ctrl ctrlSetTextColor [0.93,0.79,0,0.9];
				};
				case 4: {
					_frame_ctrl ctrlSetTextColor [0.83,0.29,0.41,1];
					_text_ctrl ctrlSetTextColor [0.83,0.29,0.41,1];
				};
			};
		} forEach mbc_rewardlist_temp;
	};

	Sleep 0.2;
	_dialog = createdialog "MBC_DIALOG";
	call UpdateMBCDialog;
	waitUntil { !dialog };

	cutText [format["You have opened a %1",MBT_NAME],"PLAIN DOWN"];
	
	Sleep 0.2;
	
	_cashToAdd = 0;
	
	{
		private["_magazines","_magazineClass","_currentMoney"];
		switch (_x select 0) do {
			case "group_wep": {
				_spawnCrate addWeaponCargoGlobal [_x select 1, 1];
				_magazines = getArray (configFile >> "CfgWeapons" >> _x select 1 >> "magazines");
				if (count _magazines > 0) then
				{
					_magazineClass = _magazines select 0;
					_spawnCrate addMagazineCargoGlobal [_magazineClass, _x select 2];
				}
			};
			case "group_mag": {
				_spawnCrate addMagazineCargoGlobal [_x select 1, _x select 2];
			};
			case "coins": {
				_cashToAdd = _cashToAdd + (_x select 2);
			};
			case "weapon": {
				_spawnCrate addWeaponCargoGlobal [_x select 1, _x select 2];
			};
			case "magazine": {
				_spawnCrate addMagazineCargoGlobal [_x select 1, _x select 2];
			};
			case "script": {
				[_x select 2] execVM _x select 1;
			};
		};
		Sleep 0.1;
	} forEach mbc_rewardlist_temp;
	
	if (_cashToAdd > 0) then {
		_currentMoney = player getVariable["cashMoney",0];
		player setVariable["cashMoney",_currentMoney + _cashToAdd, true];
	};
	
	PVDZE_plr_Save = [player,(magazines player),true,true] ;
	publicVariableServer "PVDZE_plr_Save";
	
	sleep MBT_CRATEDELAY;
	deletevehicle _spawnCrate;

};