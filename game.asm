#####################################################################
#
# CSCB58 Winter 2024 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Andre Fong, 1008156950, fongand5, andre.fong@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3? TODO
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission: TODO
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.eqv BASE_ADDRESS 0x10008000
.eqv BROWN 0x964B00
.eqv LIGHTBROWN 0xB27538

.eqv WHITE 0xFFFFFF
.eqv LIGHTGRAY 0xE9E9E9
.eqv GRAY 0xBEBEBE
.eqv LIGHTORANGE 0xFFD798

.eqv LIGHTYELLOW 0xFFAC6C
.eqv LIGHTBLUE 0xC9FBFF
.eqv DARKORANGE 0xD85F00

.data
# locations of static platforms
lv1Platforms:	.word	0x1000BB28, 0x1000B088	# TODO

# locations of moving platforms (up-down)
lv1MovePlatformsUD:	.word	0x1000B728, 0x1000A728
# move progress of respective platform (0 to 5)
lv1MovePlatformsUDProg:	.word		0, 5
# 0 = lowering, 1 = raising, 2+ = waiting
lv1MovePlatformsUDState:	.word		0, 1

# locations of moving platforms (left-right)
lv1MovePlatformsLR:	.word	0x1000B788	# TODO
# move progress of respective platform (0 to 7)
lv1MovePlatformsLRProg:	.word		0
# 0 = moving left, 1 = moving right, 2+ = waiting
lv1MovePlatformsLRState:	.word		0

# locations of feather pickups (increases jumping power)
lv1Feathers:	.word	0x1000A128
lv1FeathersAlive:	.word	1
featherInEffect:	.byte		0

# locations of hourglass pickups (slow down time)
lv1Hourglasses:	.word	0x1000A888
lv1HourglassesAlive:	.word	1
hourglassInEffect:	.byte		0

currentLv:		.word	1 # TODO

.text
main:	# IMPORTANT TEMP REGISTERS: t0 (PLAYER LOCATION), t1 (COLOR), 
		# t2 (PLAYER VERTICAL VELOCITY), t3 (TEMP PLAYER LOCATION),
		# t9 (GAME TICK)

		# INITIALIZE PLAYER POSITION (bottom left of character)
		li $t0, 0x1000BF28
		
		# iNITIALIZE PLAYER VERTICAL VELOCITY (0 to start)
		li $t2, 0
		
		# SET T3 (temp new player location) TO CURRENT PLAYER LOCATION
		move $t3, $t0
		
		# INITIALIZE GAME TICK TO 0 (inc. by 1 every iteration)
		li $t9, 0
		
		j drawPlayer

gameLoop:
		# TODO: CHECK IF PLAYER AT VERY TOP (CLEARED LEVEL)
		
		# SET T3 (temp new player location) TO CURRENT PLAYER LOCATION
		move $t3, $t0

		# SET T5 TO ADDRESS OF KEYBOARD INPUT
		li $t5, 0xffff0000
		lw $t8, 0($t5)
		beq $t8, 1, keypressHappened
		
		j updateLocation

keypressHappened:
		lw $t7, 4($t5) # this assumes $t5 is set to 0xfff0000 from before
		beq $t7, 0x61, respondToLeft 	# ASCII code of 'a' is 0x61
		beq $t7, 0x64, respondToRight	# ASCII code of 'd' is 0x64
		beq $t7, 0x77, respondToUp	# ASCII code of 'w' is 0x77
		beq $t7, 0x71, QUIT			# ASCII code of 'q' is 0x71
		# TODO: IMPLEMENT RESET
		
		j updateLocation
		
respondToLeft:
		# CHECK MOVEMENT VALID (playerLoc at very left)
		li $t8, 256
		div $t0, $t8
		mfhi $t4	# t4 = playerLoc % 256
		
		li $t5, 4
		beq $t4, $t5, updateLocation		# loc % 256 == 4 means player avatar at very left of screen
		
		# SET T3 TO NEW PLAYER LOC
		addi $t3, $t0, -4
		j updateLocation

respondToRight:
		# CHECK MOVEMENT VALID (playerLoc at very right)
		li $t8, 256
		div $t0, $t8
		mfhi $t4	#t4 = playerLoc % 256
		
		li $t8, 240
		beq $t4, $t8, updateLocation		# loc % 256 == 240 means player avatar at very right of screen
		
		# SET T3 TO NEW PLAYER LOC
		addi $t3, $t0, 4
		j updateLocation
		
respondToUp:
		# CHECK IF PLAYER IS GROUNDED
		jal isGrounded		# return value at v0
		beq $v0, $zero, SLEEP		# do nothing if player is not grounded (cannot jump while in midair)
		
		# CHECK IF FEATHER EFFECT IS ACTIVE
		la $t4, featherInEffect
		lb $t5, 0($t4)	# t5 = whether or not feather effect is active
		li $t6, 1
		beq $t5, $t6, respondToUpWithFeather
		
		# SET VERTICAL VELOCITY TO t2 (CANNOT SET TO VELOCITY THAT IS INDIVISIBLE BY FALL SPD)
		li $t2, 21	# adjust for QoL
		
		j updateLocation
		
respondToUpWithFeather:
		# SET VERTICAL VELOCITY TO t2 (higher than normal velocity)
		li $t2, 27
		
		# SET FEATHER IN EFFECT TO 0 (feather only lasts one jump)
		la $t4, featherInEffect
		sb $zero, 0($t4)		# feather in effect = 0
		
		j updateLocation
		
###################################################
# VERTICAL LOCATION (gravity)
###################################################

updateLocation:
		# CHECK VERTICAL VELOCITY
		bnez $t2, updateLocationVERTICAL	# if velocity is nonzero, update vertical location of player
		
		# IF PLAYER IS GROUNDED (and velocity is 0), SKIP UPDATING VELOCITY AND REDRAW
		jal isGrounded
		li $t5, 1
		beq $v0, $t5, undrawPlayer
		
		# ELSE, UPDATE VELOCITY (player velocity is 0, but player is not grounded, so player is now falling)
		j updateVelocityGravity

updateVelocityGravity:
		addi $t2, $t2, -1		# decrement velocity due to acceleration of gravity
		j undrawPlayer

updateLocationVERTICAL:
		# SKIP IF VELOCITY NOT DIVISIBLE BY 3 (for more floatiness while in midair)
		li $t4, 3
		div $t2, $t4
		mfhi $t5
		bnez $t5, updateVelocityGravity

		bgt $t2, $zero, increaseHeight	# if velocity is positive, increase player height
		j decreaseHeight		# otherwise, decrease player height

increaseHeight:
		li $t4, 8
		bge $t2, $t4, increaseHeightByTwo	# if velocity >= 8, increase height by 2 instead of 1
		
		# INCREASE HEIGHT BY 1 (guaranteed possible, since we've checked if we've cleared
		# the level already, ie, if we've reached the top of the screen)
		addi $t3, $t3, -256	# t3 is temp register that stores new player location before redrawing
		
		# UPDATE VELOCITY
		j updateVelocityGravity
increaseHeightByTwo:
		# INCREASE HEIGHT BY 2 IF POSSIBLE
		addi $t3, $t3, -512	# t3 is temp register that stores new player location before redrawing
		
		li $t4, BASE_ADDRESS
		bge $t3, $t4, updateVelocityGravity	# if new player location is valid (ie, t3 >= BASE_ADDRESS)
		
		addi $t3, $t3, 256	# decrease height by 1 since we can't increase by 2 (newplayer loc invalid)
		
		j updateVelocityGravity

decreaseHeight:
		# CHECK IF PLAYER IS GROUNDED
		jal isGrounded
		li $t4, 1
		beq $v0, $t4, setVelocityZero
		
		li $t4, -8
		ble $t2, $t4, decreaseHeightByTwo	# if velocity <= -8, decrease height by 2 instead of 1
		
		# DECREASE HEIGHT BY 1 (guaranteed possible, since we've checked that player is not grounded)
		addi $t3, $t3, 256
		
		# UPDATE VELOCITY
		j updateVelocityGravity
decreaseHeightByTwo:
		# DECREASE HEIGHT BY 2 IF POSSIBLE
		addi $t3, $t3, 512
		
		# CHECK NEW PLAYER LOC (t3) IS NOT A PLATFORM (BROWN)
		lw $t5, 0($t3)	# t5 = color of unit at new player loc (t3)
		li $t1, BROWN
		beq $t5, $t1, adjustDecreaseByTwoAfterPlatform
		lw $t5, 8($t3)	# t5 = color of unit at new player loc rightmost foot unit
		li $t1, BROWN
		beq $t5, $t1, adjustDecreaseByTwoAfterPlatform
		
		li $t4, BASE_ADDRESS
		addi $t4, $t4, 16380	# bottom rightmost unit on screen
		
		ble $t3, $t4, updateVelocityGravity	# if new location is valid (ie, t3 <= bottom rightmost unit on screen)
		
		addi $t3, $t3, -256	# increase height by 1 since we can't decrease by 2 (new player loc invalid)
		
		j updateVelocityGravity
adjustDecreaseByTwoAfterPlatform:
		addi $t3, $t3, -256	# increase height by 1 since we can't decrease by 2 (new player loc is a platform)
		
		j setVelocityZero

setVelocityZero:
		li $t2, 0
		j undrawPlayer

#################################################
# DRAWING (undraw player, draw background, pickups, platforms, moving platforms, draw player)
# AND HANDLING COLLISIONS
#################################################

# PREREQ: $t3 is a valid new player location within the screen
undrawPlayer:
		# REPLACE AVATAR WITH BLACK BACKGROUND
		li $t1, 0x0	# black
		# dress outline and lined pattern
		sw $t1, -260($t0)
		sw $t1, -256($t0)
		sw $t1, -252($t0)
		sw $t1, -248($t0)
		sw $t1, -244($t0)
		sw $t1, -500($t0)
		sw $t1, -1024($t0)
		sw $t1, -1020($t0)
		sw $t1, -1016($t0)
		# shoes
		sw $t1, 0($t0)
		sw $t1, 8($t0)
		# dress
		sw $t1, -512($t0)
		sw $t1, -508($t0)
		sw $t1, -504($t0)
		sw $t1, -764($t0)
		sw $t1, -760($t0)
		sw $t1, -1028($t0)
		sw $t1, -1012($t0)
		sw $t1, -1280($t0)
		sw $t1, -1276($t0)
		sw $t1, -1272($t0)
		# hair
		sw $t1, -1284($t0)
		sw $t1, -1540($t0)
		sw $t1, -1536($t0)
		sw $t1, -1524($t0)
		sw $t1, -1792($t0)
		sw $t1, -1788($t0)
		sw $t1, -1780($t0)
		sw $t1, -2048($t0)
		sw $t1, -2044($t0)
		sw $t1, -2040($t0)
		sw $t1, -2036($t0)
		# face
		sw $t1, -1532($t0)
		sw $t1, -1528($t0)
		sw $t1, -1784($t0)
		
		# UPDATE AVATAR POSITION USING TEMP POSITION (T3)
		move $t0, $t3
		
		# DRAW BACKGROUND NEXT
		j drawBackground
		
drawBackground:
		# TODO
		
		# DRAW PICKUPS NEXT
		j drawFeathers

drawFeathers:
		# INITIALIZE REGISTERS FOR DRAWING FEATHERS LOOP
		li $t4, 4	# t4 = number of total feathers to draw * 4
		li $t5, 0	# t5 = number of feathers drawn * 4
		la $s0, lv1Feathers	# s0 = memory address of array lv1Feathers
		la $s1, lv1FeathersAlive	# s1 = memory address of array lv1FeathersAlive
		la $s2, featherInEffect		# s2 = memory address of boolean featherInEffect
								# (0 = not in effect, 1 = in effect)
		
		j drawFeathersLoop

drawFeathersLoop:
		bge $t5, $t4, drawHourglasses	# start drawing hourglasses next if loop finishes
		
		# CHECK IF FEATHER IS STILL ALIVE (not picked up yet)
		add $t6, $s1, $t5	# t6 is memory address of lv1FeathersAlive[iteration]
		lw $t7, 0($t6)	# t7 = whether or not feather is still alive
		beqz $t7, drawFeathersIterEnd	# if feather is not alive, skip checking player dist and drawing

		# CHECK IF PLAYER IS NEAR FEATHER
		add $t6, $s0, $t5	# t6 is memory address of lv1Feathers[iteration]
		lw $t7, 0($t6)	# t7 = location of lv1Feathers[iteration] on game screen
		
		li $t8, 16
		add $t8, $t8, $t0
		bge $t8, $t7, checkPlayerTouchFeather		# if player loc + 16 >= feather loc, player may be touching feather
		
		# CHECK ONE ROW ABOVE FEATHER LOC (detect one more row)
		addi $t7, $t7, -256
		bge $t8, $t7, checkPlayerTouchFeather		# if player loc + 16 >= feather loc + one row, 
											# player may be touching feather
		
		# ELSE, DRAW FEATHER
		j drawFeatherOnScreen
		
checkPlayerTouchFeather:
		# Assume $t7 set to location of lv1Feathers[iteration] from previous branch
		li $t8, 28
		add $t8, $t8, $t7
		bge $t8, $t0, pickUpFeather		# if feather loc + 28 >= player loc AND
								# player loc + 16 >= feather loc, player IS touching feather
		
		# IF PLAYER ISN'T TOUCHING FEATHER, DRAW
		j drawFeatherOnScreen
		
pickUpFeather:
		# SET FEATHERALIVE[iteration] TO 0
		add $t6, $s1, $t5	# t6 is memory address of lv1FeathersAlive[iteration]
		sw $zero, 0($t6)	
		
		# SET FEATHER IN EFFECT TO 1
		li $t7, 1
		sb $t7, 0($s2)	# since s2 = memory address of boolean featherInEffect
		
		# UNDRAW FEATHER
		jal undrawFeatherOnScreen
		
		j drawFeathersIterEnd		# end of iteration (no need to draw feather, since it's been picked up)
		
drawFeatherOnScreen:
		add $t6, $s0, $t5	# t6 is memory address of lv1Feathers[iteration]
		lw $t7, 0($t6)	# t7 = location of lv1Feathers[iteration] on game screen
		
		# stem
		li $t1, LIGHTORANGE
		sw $t1, 0($t7)
		sw $t1, -256($t7)
		sw $t1, -508($t7)
		
		# feather white
		li $t1, WHITE
		sw $t1, -504($t7)
		sw $t1, -500($t7)
		sw $t1, -764($t7)
		sw $t1, -1020($t7)
		sw $t1, -1268($t7)
		sw $t1, -1008($t7)
		
		# feather shade
		li $t1, LIGHTGRAY
		sw $t1, -1016($t7)
		sw $t1, -1272($t7)
		sw $t1, -756($t7)
		sw $t1, -752($t7)
		sw $t1, -1520($t7)
		sw $t1, -1260($t7)
		
		# feather dark shade
		li $t1, GRAY
		sw $t1, -760($t7)
		sw $t1, -1012($t7)
		sw $t1, -1264($t7)
		sw $t1, -1516($t7)
		
		j drawFeathersIterEnd
				
drawFeathersIterEnd:
		addi $t5, $t5, 4	# increment # feathers handled * 4
		j drawFeathersLoop

# PREREQ: $s0 is the memory address of lv1Feathers[iteration]
#		  $t5 is the iteration count * 4
undrawFeatherOnScreen:
		add $t6, $s0, $t5	# t6 is memory address of lv1Feathers[iteration]
		lw $t7, 0($t6)	# t7 = location of lv1Feathers[iteration] on game screen
		
		li $t1, 0x0	# black
		
		# stem
		sw $t1, 0($t7)
		sw $t1, -256($t7)
		sw $t1, -508($t7)
		# feather white
		sw $t1, -504($t7)
		sw $t1, -500($t7)
		sw $t1, -764($t7)
		sw $t1, -1020($t7)
		sw $t1, -1268($t7)
		sw $t1, -1008($t7)
		# feather shade
		sw $t1, -1016($t7)
		sw $t1, -1272($t7)
		sw $t1, -756($t7)
		sw $t1, -752($t7)
		sw $t1, -1520($t7)
		sw $t1, -1260($t7)
		# feather dark shade
		sw $t1, -760($t7)
		sw $t1, -1012($t7)
		sw $t1, -1264($t7)
		sw $t1, -1516($t7)
		
		jr $ra
		
drawHourglasses:
		# INITIALIZE REGISTERS FOR DRAWING HOURGLASSES LOOP
		li $t4, 4	# t4 = number of total hourglasses to draw * 4
		li $t5, 0	# t5 = number of hourglasses drawn * 4
		la $s0, lv1Hourglasses	# s0 = memory address of array lv1Hourglasses
		la $s1, lv1HourglassesAlive	# s1 = memory address of array lv1HourglassesAlive
		la $s2, hourglassInEffect		# s2 = memory address of boolean hourglassInEffect
								# (0 = not in effect, 1 = in effect)
		
		j drawHourglassesLoop
drawHourglassesLoop:
		bge $t5, $t4, drawHearts	# start drawing hearts next if loop finishes
		
		# CHECK IF HOURGLASS IS STILL ALIVE (not picked up yet)
		add $t6, $s1, $t5	# t6 is memory address of lv1HourglassesAlive[iteration]
		lw $t7, 0($t6)	# t7 = whether or not hourglass is still alive
		beqz $t7, drawHourglassesIterEnd	# if hourglass is not alive, skip checking player dist and drawing

		# CHECK IF PLAYER IS NEAR HOURGLASS
		add $t6, $s0, $t5	# t6 is memory address of lv1Hourglasses[iteration]
		lw $t7, 0($t6)	# t7 = location of lv1Hourglasses[iteration] on game screen
		
		li $t8, 16
		add $t8, $t8, $t0
		bge $t8, $t7, checkPlayerTouchHourglass		# if player loc + 16 >= hourglass loc, 
											# player may be touching hourglass
											
		# CHECK ONE ROW ABOVE HOURGLASS LOC (detect one more row)
		addi $t7, $t7, -256
		bge $t8, $t7, checkPlayerTouchHourglass		# if player loc + 16 >= hourglass loc + one row, 
											# player may be touching hourglass
		
		# ELSE, DRAW HOURGLASS
		j drawHourglassOnScreen

checkPlayerTouchHourglass:
		# Assume $t7 set to location of lv1Hourglasses[iteration] 
		# OR lv1Hourglasses[iteration] + one row, from previous branch
		li $t8, 20
		add $t8, $t8, $t7
		bge $t8, $t0, pickUpHourglass		# if hourglass loc + 20 >= player loc AND
								# player loc + 16 >= hourglass loc, player IS touching hourglass
		
		# IF PLAYER ISN'T TOUCHING HOURGLASS, DRAW
		j drawHourglassOnScreen

pickUpHourglass:
		# SET HOURGLASSALIVE[iteration] TO 0
		add $t6, $s1, $t5	# t6 is memory address of lv1HourglassesAlive[iteration]
		sw $zero, 0($t6)
		
		# SET HOURGLASS IN EFFECT TO 1
		li $t7, 1
		sb $t7, 0($s2)	# since s2 = memory address of boolean hourglassInEffect
		
		# UNDRAW HOURGLASS
		jal undrawHourglassOnScreen
		
		j drawHourglassesIterEnd		# end of iteration (no need to draw hourglass, since it's been picked up)
		
drawHourglassOnScreen:
		add $t6, $s0, $t5	# t6 is memory address of lv1Hourglasses[iteration]
		lw $t7, 0($t6)	# t7 = location of lv1Hourglasses[iteration] on game screen
		
		# top and bottom cap
		li $t1, DARKORANGE
		sw $t1, 0($t7)
		sw $t1, 4($t7)
		sw $t1, 8($t7)
		sw $t1, 12($t7)
		sw $t1, -1536($t7)
		sw $t1, -1532($t7)
		sw $t1, -1528($t7)
		sw $t1, -1524($t7)
		
		# glass
		li $t1, LIGHTBLUE
		sw $t1, -256($t7)
		sw $t1, -244($t7)
		sw $t1, -512($t7)
		sw $t1, -500($t7)
		sw $t1, -764($t7)
		sw $t1, -760($t7)
		sw $t1, -1024($t7)
		sw $t1, -1012($t7)
		sw $t1, -1280($t7)
		sw $t1, -1268($t7)
		
		# sand
		li $t1, LIGHTYELLOW
		sw $t1, -252($t7)
		sw $t1, -248($t7)
		sw $t1, -508($t7)
		sw $t1, -504($t7)
		
		j drawHourglassesIterEnd
				
drawHourglassesIterEnd:
		addi $t5, $t5, 4	# increment # hourglasses handled * 4
		j drawHourglassesLoop

# PREREQ: $s0 is the memory address of lv1Hourglasses[iteration]
#		  $t5 is the iteration count * 4
undrawHourglassOnScreen:
		add $t6, $s0, $t5	# t6 is memory address of lv1Hourglasses[iteration]
		lw $t7, 0($t6)	# t7 = location of lv1Hourglasses[iteration] on game screen
		
		li $t1, 0x0	# black
		
		# top and bottom cap
		sw $t1, 0($t7)
		sw $t1, 4($t7)
		sw $t1, 8($t7)
		sw $t1, 12($t7)
		sw $t1, -1536($t7)
		sw $t1, -1532($t7)
		sw $t1, -1528($t7)
		sw $t1, -1524($t7)
		# glass
		sw $t1, -256($t7)
		sw $t1, -244($t7)
		sw $t1, -512($t7)
		sw $t1, -500($t7)
		sw $t1, -764($t7)
		sw $t1, -760($t7)
		sw $t1, -1024($t7)
		sw $t1, -1012($t7)
		sw $t1, -1280($t7)
		sw $t1, -1268($t7)
		# sand
		sw $t1, -252($t7)
		sw $t1, -248($t7)
		sw $t1, -508($t7)
		sw $t1, -504($t7)
		
		jr $ra

drawHearts:
		j drawPlatforms	# TODO

# PREREQ: none of the platforms are 6 or more units from the rightmost part of the screen
# 		  nor 2 or more units from the bottom of the screen
drawPlatforms:
		# INITIALIZE REGISTERS FOR DRAWING PLATFORM LOOP
		la $t8, lv1Platforms	# t8 = memory address of array lv1Platforms
		li $t4, 8	# t4 = number of total platforms to draw * 4
		li $t5, 0	# t5 = number of platforms drawn * 4
		
		j drawPlatformsLoop

drawPlatformsLoop:
		bge $t5, $t4, movePlatformsUD	# start moving platforms (up-down) next if loop finishes
		
		add $t6, $t8, $t5	# t6 is memory address of lv1Platforms[iteration]
		lw $t7, 0($t6)	# t7 = location of lv1Platforms[iteration] on game screen
		
		# DRAW PLATFORM (+6 units to the right)
		li $t1, BROWN
		sw $t1, 0($t7)
		sw $t1, 4($t7)
		sw $t1, 8($t7)
		sw $t1, 12($t7)
		sw $t1, 16($t7)
		sw $t1, 20($t7)
		
		# DRAW PLATFORM SUPPORT (under)
		li $t1, LIGHTBROWN
		sw $t1, 260($t7)
		sw $t1, 264($t7)
		sw $t1, 268($t7)
		sw $t1, 272($t7)
		
		addi $t5, $t5, 4	# increment # platforms drawn * 4
		j drawPlatformsLoop

# UP TO DOWN ########################
movePlatformsUD:
		# IF GAME TICK NOT DIVISIBLE BY 6, SKIP PLATFORM MOVING LOGIC AND DRAW MOVING PLATFORMS
		li $t6, 6
		div $t9, $t6
		mfhi $t7
		bnez $t7, drawPlatformsUD
		
		# INITIALIZE REGISTERS FOR HANDLING MOVING LOGIC (up-down)
		li $t4, 8	# t4 = number of total platforms to handle * 4
		li $t5, 0	# t5 = number of platforms handled * 4
		
		la $s0, lv1MovePlatformsUD	# s0 = memory address of array lv1MovePlatformsUD
		la $s1, lv1MovePlatformsUDProg	# s1 = address of array lv1MovePlatformsUDProg
		la $s2, lv1MovePlatformsUDState		#s2 = address of array lv1MovePlatformsUDState
		
		j movePlatformsUDLoop

movePlatformsUDLoop:
		bge $t5, $t4, drawPlatformsUD	# draw moving platforms next if handling moving is finished

		# AVAILABLE REGISTERS: t6, t7, t8
		
		# GET STATE OF PLATFORM (0 = lowering, 1 = raising, 2+ = waiting)
		add $t6, $s2, $t5	# t6 is memory address of lv1MovePlatformsUDState[iteration]
		lw $a0, 0($t6)	# a0 = STATE of platform lv1MovePlatformsUD[iteration]
		
		#TODO, print state
		li $v0, 1
		#syscall
		
		# GET PROG OF PLATFORM (0 to 5)
		add $t6, $s1, $t5	# t6 is memory address of lv1MovePlatformsUDProg[iteration]
		lw $a1, 0($t6)	# a1 = PROG of platform lv1MovePlatformsUD[iteration]
		
		beqz $a0, handleLowerPlatform	# if state == 0, handle lowering platform
		
		li $t7, 1
		beq $a0, $t7, handleRaisePlatform	# if state == 1, handle raising platform
		
		li $t7, 4
		beq $a0, $t7, handleContinuePlatformUD	# if state == 4, handle 
							# continuing to move platform (DONE WAITING)
		
		# OTHERWISE, 2 <= STATE < 4 (continue waiting)
		addi $a0, $a0, 1	# increment state
		add $t6, $s2, $t5	# t6 is memory address of lv1MovePlatformsUDState[iteration]
		sw $a0, 0($t6)	# store waiting state back into lv1MovePlatformsUDState[iteration]
		
		j movePlatformsUDIterEnd	# end of iteration

handleLowerPlatform:
		beqz $a1, handleDoneMovingPlatformUD	# if platform prog == 0, platform is done lowering
		
		# O/W PLATFORM IS STILL LOWERING
		add $t6, $s1, $t5	# t6 is memory address of lv1MovePlatformsUDProg[iteration]
		
		add $t7, $s0, $t5	# t7 is the memory address of lv1MovePlatformsUD[iteration]
		lw $a2, 0($t7)	# a2 is the location of lv1MovePlatformsUD[iteration] on the screen
		jal undrawPlatformUD	# undraw platform at old prog $a1, given platform at $a2
		
		addi $a1, $a1, -1		# decrement prog
		sw $a1, 0($t6)	# store decremented prog back into lv1MovePlatformsUDProg[iteration]
		
		j movePlatformsUDIterEnd	# end of iteration
		
handleRaisePlatform:
		li $t6, 5	# since progress is 0 to 5
		beq $a1, $t6, handleDoneMovingPlatformUD		# if platform prog == 5, platform is done raising
		
		# O/W PLATFORM IS STILL RAISING
		add $t6, $s1, $t5	# t6 is memory address of lv1MovePlatformsUDProg[iteration]
		
		add $t7, $s0, $t5	# t7 is the memory address of lv1MovePlatformsUD[iteration]
		lw $a2, 0($t7)	# a2 is the location of lv1MovePlatformsUD[iteration] on the screen
		jal undrawPlatformUD	# undraw platform at old prog $a1, given platform at $a2
		
		addi $a1, $a1, 1		# increment prog
		sw $a1, 0($t6)	# store incremented prog back into lv1MovePlatformsUDProg[iteration]
		
		j movePlatformsUDIterEnd	# end of iteration
		
handleDoneMovingPlatformUD:
		add $t6, $s2, $t5	# t6 is memory address of lv1MovePlatformsUDState[iteration]
		li $t7, 2	# t7 = waiting state (2)
		sw $t7, 0($t6)	# store waiting state back into lv1MovePlatformsUDState[iteration]
		
		j movePlatformsUDIterEnd	# end of iteration

handleContinuePlatformUD:
		beqz $a1, startRaising		# if prog == 0, then platform just finished lowering (should start raising)
		
		# O/W, PLATFORM SHOULD START LOWERING
		add $t6, $s2, $t5	# t6 is memory address of lv1MovePlatformsUDState[iteration]
		sw $zero, 0($t6)		# store lowering state (0) back into lv1MovePlatformsUDState[iteration]
		
		j movePlatformsUDIterEnd	# end of iteration
startRaising:
		# PLATFORM SHOULD START RAISING
		add $t6, $s2, $t5	# t6 is memory address of lv1MovePlatformsUDState[iteration]
		li $t7, 1	# t7 = raising state (1)
		sw $t7, 0($t6)	# store raising state back into lv1MovePlatformsUDState[iteration]
		
		j movePlatformsUDIterEnd	# end of iteration

movePlatformsUDIterEnd:
		addi $t5, $t5, 4	# increment # platforms handled * 4
		j movePlatformsUDLoop

# PREREQ: $a1 is set to the old offset of the platform (to undraw), 
#		  $a2 is set to the location of the platform
undrawPlatformUD:
		# GET OFFSET * 256
		li $t7, 256
		mult $a1, $t7
		mflo $t8	# t8 = vertical offset (0-5) * 256
		
		# UNDRAW PLATFORM wrt. OFFSET GIVEN BY PROG
		sub $t7, $a2, $t8		# t7 = location of moving platform - (vertical offset)
		
		# UNDRAW PLATFORM (+6 units to the right)
		li $t1, 0x0	# BLACK
		sw $t1, 0($t7)
		sw $t1, 4($t7)
		sw $t1, 8($t7)
		sw $t1, 12($t7)
		sw $t1, 16($t7)
		sw $t1, 20($t7)
		
		# UNDRAW PLATFORM SUPPORT (under)
		sw $t1, 260($t7)
		sw $t1, 264($t7)
		sw $t1, 268($t7)
		sw $t1, 272($t7)
		
		jr $ra

drawPlatformsUD:
		# INITIALIZE REGISTERS FOR DRAWING MOVING PLATFORMS (up-down)
		li $t4, 8	# t4 = number of total platforms to draw * 4
		li $t5, 0	# t5 = number of platforms drawn * 4
		la $s0, lv1MovePlatformsUD	# s0 = memory address of array lv1MovePlatformsUD
		la $s1, lv1MovePlatformsUDProg
		
		j drawPlatformsUDLoop
		
drawPlatformsUDLoop:
		bge $t5, $t4, movePlatformsLR	# once up-down platforms are done, start handling LEFT-RIGHT PLATFORMS
		
		# AVAILABLE REGISTERS: (t1), t6, t7, t8
		
		# GET VERTICAL OFFSET FROM PROG
		add $t6, $s1, $t5	# t6 is memory address of lv1MovePlatformsUDProg[iteration]
		lw $t7, 0($t6)	# t7 = vertical offset of platform lv1MovePlatforms[iteration]
		li $t8, 256
		mult $t7, $t8
		mflo $t6	# t6 = vertical offset (0-5) * 256
		
		# GET NEW PLATFORM LOCATION wrt. OFFSET GIVEN BY PROG
		add $t7, $s0, $t5	# t7 is memory address of lv1MovePlatformsUD[iteration]
		lw $t8, 0($t7)	# t8 = location of lv1MovePlatformsUD[iteration] on game screen
		
		sub $t8, $t8, $t6		# t8 = location of moving platform - (vertical offset)
		
		# CHECK IF NEW LOCATION OF PLATFORM IS OCCUPIED BY PLAYER
		# IF SO, MOVE PLAYER ONE UNIT UP
		addi $t6, $t0, 8
		ble $t8, $t6, checkPlayerInsideNewPlatform	# if new platform loc <= player loc + 8,
										# player MAY need to move up one unit
		
		j drawPlatformsUDIterEnd	# end of iteration

checkPlayerInsideNewPlatform:
		# Assume t8 (new platform loc) set from prev branch
		addi $t7, $t8, 20
		ble $t0, $t7, movePlayerWithRaisingPlatform		# player loc <= new platform loc + 20 (platform length)
											# AND new platform loc <= player loc + 4,
											# then player occupies new platform location
		j drawPlatformsUDIterEnd
movePlayerWithRaisingPlatform:
		addi $t0, $t0, -256
		j drawPlatformsUDIterEnd
		
drawPlatformsUDIterEnd:
		# DRAW PLATFORM (+6 units to the right)
		li $t1, BROWN
		sw $t1, 0($t8)
		sw $t1, 4($t8)
		sw $t1, 8($t8)
		sw $t1, 12($t8)
		sw $t1, 16($t8)
		sw $t1, 20($t8)
		
		# DRAW PLATFORM SUPPORT (under)
		li $t1, LIGHTBROWN
		sw $t1, 260($t8)
		sw $t1, 264($t8)
		sw $t1, 268($t8)
		sw $t1, 272($t8)
		
		addi $t5, $t5, 4	# increment # platforms drawn * 4
		j drawPlatformsUDLoop
		
# LEFT TO RIGHT ###########
movePlatformsLR:
		# IF GAME TICK NOT DIVISIBLE BY 6, SKIP PLATFORM MOVING LOGIC AND DRAW MOVING PLATFORMS
		li $t6, 6
		div $t9, $t6
		mfhi $t7
		bnez $t7, drawPlatformsLR
		
		# INITIALIZE REGISTERS FOR HANDLING MOVING LOGIC (left-right)
		li $t4, 4	# t4 = number of total platforms to handle * 4
		li $t5, 0	# t5 = number of platforms handled * 4
		
		la $s0, lv1MovePlatformsLR	# s0 = memory address of array lv1MovePlatformsLR
		la $s1, lv1MovePlatformsLRProg	# s1 = address of array lv1MovePlatformsLRProg
		la $s2, lv1MovePlatformsLRState		#s2 = address of array lv1MovePlatformsLRState
		
		j movePlatformsLRLoop

movePlatformsLRLoop:
		bge $t5, $t4, drawPlatformsLR	# draw moving platforms next if handling moving is finished

		# AVAILABLE REGISTERS: t6, t7, t8
		
		# GET STATE OF PLATFORM (0 = moving left, 1 = moving right, 2+ = waiting)
		add $t6, $s2, $t5	# t6 is memory address of lv1MovePlatformsLRState[iteration]
		lw $a0, 0($t6)	# a0 = STATE of platform lv1MovePlatformsLR[iteration]
		
		# GET PROG OF PLATFORM (0 to 7)
		add $t6, $s1, $t5	# t6 is memory address of lv1MovePlatformsLRProg[iteration]
		lw $a1, 0($t6)	# a1 = PROG of platform lv1MovePlatformsLR[iteration]
		
		beqz $a0, handleLeftPlatform	# if state == 0, handle moving platform left
		
		li $t7, 1
		beq $a0, $t7, handleRightPlatform	# if state == 1, handle moving platform right
		
		li $t7, 4
		beq $a0, $t7, handleContinuePlatformLR	# if state == 4, handle 
							# continuing to move platform (DONE WAITING)
		
		# OTHERWISE, 2 <= STATE < 4 (continue waiting)
		addi $a0, $a0, 1	# increment state
		add $t6, $s2, $t5	# t6 is memory address of lv1MovePlatformsLRState[iteration]
		sw $a0, 0($t6)	# store waiting state back into lv1MovePlatformsLRState[iteration]
		
		j movePlatformsLRIterEnd	# end of iteration

handleLeftPlatform:
		beqz $a1, handleDoneMovingPlatformLR	# if platform prog == 0, platform is done moving left
		
		# O/W PLATFORM IS STILL MOVING LEFT
		add $t6, $s1, $t5	# t6 is memory address of lv1MovePlatformsLRProg[iteration]
		
		add $t7, $s0, $t5	# t7 is the memory address of lv1MovePlatformsLR[iteration]
		lw $a2, 0($t7)	# a2 is the location of lv1MovePlatformsLR[iteration] on the screen
		jal undrawPlatformLR	# undraw platform at old prog $a1, given platform at $a2
		
		addi $a1, $a1, -1		# decrement prog
		sw $a1, 0($t6)	# store decremented prog back into lv1MovePlatformsLRProg[iteration]
		
		j movePlatformsLRIterEnd	# end of iteration
		
handleRightPlatform:
		li $t6, 7	# since progress is 0 to 7
		beq $a1, $t6, handleDoneMovingPlatformLR		# if platform prog == 7, platform is done moving right
		
		# O/W PLATFORM IS STILL MOVING RIGHT
		add $t6, $s1, $t5	# t6 is memory address of lv1MovePlatformsLRProg[iteration]
		
		add $t7, $s0, $t5	# t7 is the memory address of lv1MovePlatformsLR[iteration]
		lw $a2, 0($t7)	# a2 is the location of lv1MovePlatformsLR[iteration] on the screen
		jal undrawPlatformLR	# undraw platform at old prog $a1, given platform at $a2
		
		addi $a1, $a1, 1		# increment prog
		sw $a1, 0($t6)	# store incremented prog back into lv1MovePlatformsLRProg[iteration]
		
		j movePlatformsLRIterEnd	# end of iteration
		
handleDoneMovingPlatformLR:
		add $t6, $s2, $t5	# t6 is memory address of lv1MovePlatformsLRState[iteration]
		li $t7, 2	# t7 = waiting state (2)
		sw $t7, 0($t6)	# store waiting state back into lv1MovePlatformsLRState[iteration]
		
		j movePlatformsLRIterEnd	# end of iteration

handleContinuePlatformLR:
		beqz $a1, startMovingRight		# if prog == 0, then platform just finished going left (should start going right)
		
		# O/W, PLATFORM SHOULD START GOING LEFT
		add $t6, $s2, $t5	# t6 is memory address of lv1MovePlatformsLRState[iteration]
		sw $zero, 0($t6)		# store moving left state (0) back into lv1MovePlatformsLRState[iteration]
		
		j movePlatformsLRIterEnd	# end of iteration
startMovingRight:
		# PLATFORM SHOULD START MOVING RIGHT
		add $t6, $s2, $t5	# t6 is memory address of lv1MovePlatformsLRState[iteration]
		li $t7, 1	# t7 = moving right state (1)
		sw $t7, 0($t6)	# store moving right state back into lv1MovePlatformsLRState[iteration]
		
		j movePlatformsLRIterEnd	# end of iteration

movePlatformsLRIterEnd:
		addi $t5, $t5, 4	# increment # platforms handled * 4
		j movePlatformsLRLoop

# PREREQ: $a1 is set to the old offset of the platform (to undraw), 
#		  $a2 is set to the location of the platform
undrawPlatformLR:
		# GET OFFSET * 4
		li $t7, 4
		mult $a1, $t7
		mflo $t8	# t8 = horizontal offset (0-5) * 4
		
		# UNDRAW PLATFORM wrt. OFFSET GIVEN BY PROG
		add $t7, $a2, $t8		# t7 = location of moving platform + (horizontal offset)
		
		# UNDRAW PLATFORM (+6 units to the right)
		li $t1, 0x0	# BLACK
		sw $t1, 0($t7)
		sw $t1, 4($t7)
		sw $t1, 8($t7)
		sw $t1, 12($t7)
		sw $t1, 16($t7)
		sw $t1, 20($t7)
		
		# UNDRAW PLATFORM SUPPORT (under)
		sw $t1, 260($t7)
		sw $t1, 264($t7)
		sw $t1, 268($t7)
		sw $t1, 272($t7)
		
		jr $ra
		
drawPlatformsLR:
		# INITIALIZE REGISTERS FOR DRAWING MOVING PLATFORMS (left-right)
		li $t4, 4	# t4 = number of total platforms to draw * 4
		li $t5, 0	# t5 = number of platforms drawn * 4
		la $s0, lv1MovePlatformsLR	# s0 = memory address of array lv1MovePlatformsLR
		la $s1, lv1MovePlatformsLRProg
		
		j drawPlatformsLRLoop
		
drawPlatformsLRLoop:
		bge $t5, $t4, drawPlayer	# once left-right platforms are done, start drawing player
		
		# AVAILABLE REGISTERS: (t1), t6, t7, t8
		
		# GET HORIZONTAL OFFSET FROM PROG
		add $t6, $s1, $t5	# t6 is memory address of lv1MovePlatformsLRProg[iteration]
		lw $t7, 0($t6)	# t7 = horizontal offset of platform lv1MovePlatformsLR[iteration]
		li $t8, 4
		mult $t7, $t8
		mflo $t6	# t6 = horizontal offset (0-5) * 4
		
		# GET NEW PLATFORM LOCATION wrt. OFFSET GIVEN BY PROG
		add $t7, $s0, $t5	# t7 is memory address of lv1MovePlatformsLR[iteration]
		lw $t8, 0($t7)	# t8 = location of lv1MovePlatformsLR[iteration] on game screen
		
		add $t8, $t8, $t6		# t8 = location of moving platform + (horizontal unit offset)
		
		# DRAW PLATFORM (+6 units to the right)
		li $t1, BROWN
		sw $t1, 0($t8)
		sw $t1, 4($t8)
		sw $t1, 8($t8)
		sw $t1, 12($t8)
		sw $t1, 16($t8)
		sw $t1, 20($t8)
		
		# DRAW PLATFORM SUPPORT (under)
		li $t1, LIGHTBROWN
		sw $t1, 260($t8)
		sw $t1, 264($t8)
		sw $t1, 268($t8)
		sw $t1, 272($t8)
		
		addi $t5, $t5, 4	# increment # platforms drawn * 4
		j drawPlatformsLRLoop

drawPlayer:
		# DRAW AVATAR (width 5 x height 9)
		
		li $t1, 0xff4a60 # dark pink
		sw $t1, -260($t0)	# dress outline and lined pattern
		sw $t1, -256($t0)
		sw $t1, -252($t0)
		sw $t1, -248($t0)
		sw $t1, -244($t0)
		sw $t1, -500($t0)
		sw $t1, -1024($t0)
		sw $t1, -1020($t0)
		sw $t1, -1016($t0)
		
		li $t1, 0x7bf8eb # light diamond blue
		sw $t1, 0($t0)	# shoes
		sw $t1, 8($t0)
		
		li $t1, 0xf87b8a	# light pink
		sw $t1, -512($t0)	# dress
		sw $t1, -508($t0)
		sw $t1, -504($t0)
		sw $t1, -764($t0)
		sw $t1, -760($t0)
		sw $t1, -1028($t0)
		sw $t1, -1012($t0)
		sw $t1, -1280($t0)
		sw $t1, -1276($t0)
		sw $t1, -1272($t0)
		
		li $t1, 0xf8f37b	# golden yellow
		sw $t1, -1284($t0)	# hair
		sw $t1, -1540($t0)
		sw $t1, -1536($t0)
		sw $t1, -1524($t0)
		sw $t1, -1792($t0)
		sw $t1, -1788($t0)
		sw $t1, -1780($t0)
		sw $t1, -2048($t0)
		sw $t1, -2044($t0)
		sw $t1, -2040($t0)
		sw $t1, -2036($t0)
		
		li $t1, 0xf8c87b	# face
		sw $t1, -1532($t0)
		sw $t1, -1528($t0)
		sw $t1, -1784($t0)
		
		j SLEEP

# RETURNS 1 IF PLAYER IS ON A PLATFORM OR ON THE GROUND, 0 O/W
# PREREQ: $t3 is a valid new player location within the screen
isGrounded:
		# CHECK IF PLAYER LOCATION IS ON THE LAST ROW (bottom of screen)
		li $t4, 16128
		addi $t5, $t4, BASE_ADDRESS
		bge $t0, $t5, returnIsGrounded	# if t0 >= BASE_ADDRESS + 16128, player is on bottom of screen
		
		# CHECK IF PIXEL(s) BELOW PLAYER IS PLATFORM (BROWN)
		li $t1, BROWN
		
		lw $t6, 256($t0)		# load color of pixel below player loc (bottom leftmost player pixel)
		lw $t7, 264($t0)		# load color of pixel below player loc (bottom rightmost player pixel)
		
		beq $t6, $t1, returnIsGrounded
		beq $t7, $t1, returnIsGrounded
		
		# CHECK IF PIXEL(s) BELOW NEW PLAYER LOC IS PLATFORM (BROWN)
		lw $t6, 256($t3)
		lw $t7, 264($t3)
		beq $t6, $t1, returnIsGrounded
		beq $t7, $t1, returnIsGrounded
		
		# RETURN NOT GROUNDED IF PREVIOUS CHECKS ALL FAILED
		li $v0, 0
		jr $ra
returnIsGrounded:	
		li $v0, 1
		jr $ra

# RETURNS 1 IF PLAYER REACHED TOP OF SCREEN (finished level), 0 O/W
isFinishedLevel:
		# GET TOP LEFTMOST PLAYER LOCATION
		addi $t4, $t0, -2048	# 8 units above
		
		li $t5, 252
		addi $t6, $t5, BASE_ADDRESS	# t6 = rightmost unit on first row
		ble $t4, $t6, returnIsFinishedLevel	# if the player's topmost unit is on the first row of the screen
		
		# RETURN NOT FINISHED IF PREVIOUS CHECKS ALL FAILED
		li $v0, 0
		jr $ra
returnIsFinishedLevel:
		li $v0, 1
		jr $ra

SLEEP:	li $v0, 32
		li $a0, 30	# Wait 100ms (TODO)
		syscall
		
		#TODO: remove print
		li $v0, 1
		move $a0, $t9
		#syscall
		
		# RESET GAME TICK IF >= 2,147,483,646
		li $t4, 2147483646
		bge $t9, $t4, resetGameTick
		
		# ELSE, INCREASE GAME TICK AND RETURN TO GAME LOOP
		addi $t9, $t9, 1
		j gameLoop
resetGameTick:
		li $t9, 0
		j gameLoop

QUIT:	li $v0, 10
		syscall
