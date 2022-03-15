extends Control

var svgInputTxt:="null"
var popup_choice:=false
var slot_node
var continue_popup_choice:=false
var rmv_popup_choice:=false
var button_press_sfx = preload("res://sfx/button_advance.wav")
var button_back_sfx = preload("res://sfx/button_back.wav")
var attention_popup_sfx = preload("res://sfx/attention_popup.wav")
var dialogue_popup_sfx = preload("res://sfx/dialogue_popup.wav")
var err_sfx = preload("res://sfx/err.wav")
var quit_sfx = preload("res://sfx/quit.wav")


func _ready():
	var children = self.get_children()
	for i in range (0,children.size()):
		if children[i].name!="Music" && children[i].name!="SFX": children[i].visible = false
	for i in range (0,4):
		children[i].visible = true
	
	if globals.default_savegame!="#":
		get_node("VBoxContainer/Continue").visible=true
	get_node("MusicSlider").value = globals.music_volume
	get_node("SfxSlider").value = globals.sfx_volume
	get_node("MusicSlider/isMusicOn").pressed = globals.music_toggle
	get_node("SfxSlider/isSfxOn").pressed = globals.sfx_toggle
	$"VBoxContainer/New Game".grab_focus()
	pass 

func Hide_UI() -> void:
	$NG_menu.visible = true
	$VBoxContainer.visible = false
	pass

func CheckFileExists(name:String) -> bool:
	var files:PoolStringArray = globals.list_files_in_directory(globals.savefile_dir,"dat")
	for x in files:
		if x==name:
			return true
	return false

func _on_SavegameInput_text_entered(new_text):
	svgInputTxt=new_text
	if svgInputTxt=="":
		svgInputTxt="null"
	pass 

func _on_Create_pressed():
	$NG_menu/SavegameInput.emit_signal("text_entered",$NG_menu/SavegameInput.text)
	pass 
	
func _on_SvgPopUp_confirmed():
	popup_choice = true
	$SvgPopUp.hide()
	pass 
	
func CheckNumberOfSaves() -> int:
	var files = globals.list_files_in_directory(globals.savefile_dir,"dat")
	return files.size()

func _on_New_Game_pressed():
	Hide_UI()
	if CheckNumberOfSaves()>=10:
		$NG_menu.visible=false
		$SvgErrPopUp.popup()
		yield($SvgErrPopUp,"popup_hide")
		$VBoxContainer.visible = true
		return
	$NG_menu/SavegameInput.text=""
	yield($NG_menu/SavegameInput,"text_entered")
	var name:String = svgInputTxt
	svgInputTxt="null" 
	var file_exists:bool = CheckFileExists(name+".dat")
	popup_choice = false
	if file_exists:
		# ask overwrite
		$NG_menu.visible=false
		$SvgPopUp.dialog_text="Savegame "+name+" already exists. Overwrite?"
		$SvgPopUp.popup()
		yield($SvgPopUp,"popup_hide")
		#
	if !file_exists || popup_choice==true:
			var file=File.new()
			file.open(globals.savefile_dir+name+".dat",File.WRITE)
			file.store_string("")
			file.close()
			globals.default_savegame=name+".dat"
			globals.UpdateFile()
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://scenes/NG.tscn") # exit the main menu and start NG
	elif file_exists && popup_choice==false:
		yield(_on_New_Game_pressed(),"completed")
	pass

func _on_Options_pressed():
	get_node("VBoxContainer").visible=false
	get_node("MusicSlider").visible=true
	get_node("SfxSlider").visible=true
	get_node("options_back").visible=true
	pass

func _on_Quit_pressed():
	get_tree().quit()
	pass

func _on_options_back_pressed():
	get_node("VBoxContainer").visible=true
	get_node("MusicSlider").visible=false
	get_node("SfxSlider").visible=false
	get_node("options_back").visible=false
	pass 


func _on_MusicSlider_value_changed(value):
	var stream = get_node("Music")
	stream.volume_db = linear2db(value/100.0)
	if globals.music_volume != value:
		globals.music_volume = value
		globals.music_toggle = true
		$MusicSlider/isMusicOn.pressed = true
		globals.UpdateFile()
	pass 


	pass # Replace with function body.


# warning-ignore:unused_argument
func _on_isMusicOn_toggled(button_pressed):
	var stream = get_node("Music")
	if get_node("MusicSlider/isMusicOn").is_pressed():
		stream.volume_db = - linear2db(get_node("MusicSlider").value/100.0)
		globals.music_toggle = true
		globals.UpdateFile()
	else: 
		stream.volume_db = -80
		globals.music_toggle = false
		globals.UpdateFile()
	pass # Replace with function body.


# warning-ignore:unused_argument
func _on_isSfxOn_toggled(button_pressed):
	if get_node("SfxSlider/isSfxOn").is_pressed():
		globals.sfx_toggle = true
		globals.UpdateFile()
	else: 
		globals.sfx_toggle = false
		globals.UpdateFile()
	pass # Replace with function body.


func _on_SfxSlider_value_changed(value):
	if value!=globals.sfx_volume:
		globals.sfx_volume = value
		globals.sfx_toggle = true
		$SfxSlider/isSfxOn.pressed=true
		globals.UpdateFile()
	pass # Replace with function body.


func _on_Back_NG_pressed():
	$NG_menu.visible = false
	$VBoxContainer.visible = true
	pass 

func isalphanum(c) -> bool:
	return c>='0' && c<='9' || c>='a' && c<='z' || c>='A' && c<='Z'

func _on_SavegameInput_text_changed(new_text):
	if new_text.length()>0 && !isalphanum(new_text[new_text.length()-1]):
		new_text.erase(new_text.length()-1,1)
		$NG_menu/SavegameInput.text=new_text
		$NG_menu/SavegameInput.caret_position=new_text.length()
	pass

func _on_Savegames_pressed():
	$Savegames_menu.visible = true
	$VBoxContainer.visible = false
	var files = globals.list_files_in_directory(globals.savefile_dir,"dat")
	var number_of_saves = files.size()
	var savegames = $Savegames_menu/Savegame_slots.get_children()
	for i in range(0,number_of_saves):
		savegames[i].visible = true
		savegames[i].text = files[i]
	pass # Replace with function body.


func _on_Back_pressed():
	$Savegames_menu.visible=false
	$VBoxContainer.visible = true
	pass # Replace with function body.

func SlotChosen(node):
	$Savegames_menu/Savegame_slots.visible = false
	$Savegames_menu/Back.visible = false
	$"Savegames_menu/Slot Options".visible = true
	slot_node = node
	pass

func _on_slot1_pressed():
	SlotChosen($Savegames_menu/Savegame_slots/slot1)
	pass 


func _on_slot2_pressed():
	SlotChosen($Savegames_menu/Savegame_slots/slot2)
	pass # Replace with function body.


func _on_slot3_pressed():
	SlotChosen($Savegames_menu/Savegame_slots/slot3)
	pass # Replace with function body.


func _on_slot4_pressed():
	SlotChosen($Savegames_menu/Savegame_slots/slot4)
	pass # Replace with function body.


func _on_slot5_pressed():
	SlotChosen($Savegames_menu/Savegame_slots/slot5)
	pass # Replace with function body.


func _on_slot6_pressed():
	SlotChosen($Savegames_menu/Savegame_slots/slot6)
	pass # Replace with function body.


func _on_slot7_pressed():
	SlotChosen($Savegames_menu/Savegame_slots/slot7)
	pass # Replace with function body.


func _on_slot8_pressed():
	SlotChosen($Savegames_menu/Savegame_slots/slot8)
	pass # Replace with function body.


func _on_slot9_pressed():
	SlotChosen($Savegames_menu/Savegame_slots/slot9)
	pass # Replace with function body.


func _on_slot10_pressed():
	SlotChosen($Savegames_menu/Savegame_slots/slot10)
	pass # Replace with function body.


func _on_Back_Slot_pressed():
	$Savegames_menu/Savegame_slots.visible = true
	$Savegames_menu/Back.visible = true
	$"Savegames_menu/Slot Options".visible = false
	pass # Replace with function body.

func _on_Remove_pressed():
	if slot_node.text==globals.default_savegame:
		$"Savegames_menu/Remove default".popup()
		$Savegames_menu.visible=false
		yield($"Savegames_menu/Remove default","popup_hide")
		$Savegames_menu.visible=true
		if(rmv_popup_choice==false):
			return
	rmv_popup_choice=false
	globals.default_savegame="#"
	globals.UpdateFile()
	$VBoxContainer/Continue.visible=false
	var dir = Directory.new()
	dir.remove(globals.savefile_dir + slot_node.text)
	slot_node.visible=false
	_on_Back_Slot_pressed()
		
	pass 

func _on_Default_pressed():
	globals.default_savegame=slot_node.text
	globals.UpdateFile()
	$VBoxContainer/Continue.visible=true
	_on_Back_Slot_pressed()
	pass 


func _on_Continue_pressed():
	$VBoxContainer.visible=false
	$SvgName_Continue.dialog_text = "Continue on savegame:\n" + globals.default_savegame + " ?"
	$SvgName_Continue.popup()
	yield($SvgName_Continue,"popup_hide")
	if continue_popup_choice==true:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/NG.tscn") # TODO: Load Game
		continue_popup_choice=false
	else:
		$VBoxContainer.visible = true
	pass 

func _on_SvgName_Continue_confirmed():
	continue_popup_choice = true
	$SvgName_Continue.hide()
	pass


func _on_Remove_default_confirmed():
	rmv_popup_choice=true
	$"Savegames_menu/Remove default".hide()
	pass 
