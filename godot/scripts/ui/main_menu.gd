extends Control
## Main menu with login, register, and play functionality.

@onready var main_buttons: VBoxContainer = %MainButtons
@onready var login_form: VBoxContainer = %LoginForm
@onready var register_form: VBoxContainer = %RegisterForm
@onready var status_label: Label = %StatusLabel

# Login form fields
@onready var login_email: LineEdit = %LoginEmail
@onready var login_password: LineEdit = %LoginPassword

# Register form fields
@onready var register_email: LineEdit = %RegisterEmail
@onready var register_password: LineEdit = %RegisterPassword
@onready var register_username: LineEdit = %RegisterUsername


func _ready() -> void:
	_show_main_buttons()
	status_label.text = ""


func _show_main_buttons() -> void:
	main_buttons.visible = true
	login_form.visible = false
	register_form.visible = false


func _show_login_form() -> void:
	main_buttons.visible = false
	login_form.visible = true
	register_form.visible = false
	login_email.text = ""
	login_password.text = ""
	status_label.text = ""


func _show_register_form() -> void:
	main_buttons.visible = false
	login_form.visible = false
	register_form.visible = true
	register_email.text = ""
	register_password.text = ""
	register_username.text = ""
	status_label.text = ""


func _on_login_button_pressed() -> void:
	_show_login_form()


func _on_register_button_pressed() -> void:
	_show_register_form()


func _on_play_button_pressed() -> void:
	if GameManager.is_logged_in:
		SceneManager.go_to_village()
	else:
		status_label.text = "Please log in first."


func _on_login_submit_pressed() -> void:
	var email := login_email.text.strip_edges()
	var password := login_password.text.strip_edges()
	if email.is_empty() or password.is_empty():
		status_label.text = "Please fill in all fields."
		return

	status_label.text = "Logging in..."
	var result: Dictionary = await GameManager.login(email, password)
	if result.get("success", false):
		status_label.text = "Login successful!"
		SceneManager.go_to_village()
	else:
		status_label.text = result.get("error", "Login failed.")


func _on_register_submit_pressed() -> void:
	var email := register_email.text.strip_edges()
	var password := register_password.text.strip_edges()
	var username := register_username.text.strip_edges()
	if email.is_empty() or password.is_empty() or username.is_empty():
		status_label.text = "Please fill in all fields."
		return

	status_label.text = "Registering..."
	var result: Dictionary = await GameManager.register(email, password, username)
	if result.get("success", false):
		status_label.text = "Registration successful!"
		SceneManager.go_to_village()
	else:
		status_label.text = result.get("error", "Registration failed.")


func _on_back_to_menu_pressed() -> void:
	_show_main_buttons()
