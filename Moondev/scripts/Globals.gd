extends Node



onready var options_file := "user://options.dat"
onready var savefile_dir := "user://savegames/"

var file := File.new()
var music_volume := 100
var sfx_volume := 100
var music_toggle := true
var sfx_toggle := true
var default_savegame:= "#"

func UpdateFile() -> void:
	var strng = str(globals.music_volume) + "," + str(globals.sfx_volume) + \
	"," + str(int(globals.music_toggle)) + "," + str(int(globals.sfx_toggle)) + \
	"," + globals.default_savegame
# warning-ignore:return_value_discarded
	globals.file.open(globals.options_file, File.WRITE)
	globals.file.store_string(strng)
	globals.file.close()
	pass

func Init_Directories() -> void:
	var dir = Directory.new()
	dir.open("user://")
	if not dir.dir_exists(savefile_dir):
		dir.make_dir("savegames")

func Init_Options() -> void:
	if file.file_exists(options_file):
# warning-ignore:return_value_discarded
		var upd:=false
		file.open(options_file, File.READ)
		var input = file.get_as_text()
		var settings = input.split(",")
		if(settings.size()>=1):
			music_volume = int(settings[0])
		else: upd=true
		
		if(settings.size()>=2):
			sfx_volume = int(settings[1])
		else: upd=true
		
		if(settings.size()>=3):
			music_toggle = bool(int(settings[2]))
		else: upd=true
		
		if(settings.size()>=4):
			sfx_toggle = bool(int(settings[3]))
		else: upd=true
		
		if(settings.size()>=5):
			default_savegame = settings[4]
		else: upd=true

		file.close()
		if upd==true: UpdateFile()
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	Init_Directories()
	Init_Options()
	pass

func list_files_in_directory(path,ext):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
# warning-ignore:shadowed_variable
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.get_extension() == ext:
			files.append(file)

	dir.list_dir_end()

	return files

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
