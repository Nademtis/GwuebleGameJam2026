extends Node
#global Events

@warning_ignore("unused_signal")
signal load_new_level
@warning_ignore("unused_signal")
signal restart_current_level

@warning_ignore("unused_signal")
signal storm_state_changed(new_state : StormManager.StormState)
