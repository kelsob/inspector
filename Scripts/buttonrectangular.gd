extends InteractableObject

@onready var anim = $buttonrectangular/AnimationPlayer

func pressed():
	anim.play('ButtonPress')
