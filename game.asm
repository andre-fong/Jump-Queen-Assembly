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
		
		beq $t4, $zero, SLEEP		# loc % 256 == 0 means player at left
		
		# SET T3 TO NEW PLAYER LOC
		addi $t3, $t0, -4
		j updateLocation

respondToRight:
		# CHECK MOVEMENT VALID (playerLoc at very right)
		li $t8, 256
		div $t0, $t8
		mfhi $t4	#t4 = playerLoc % 256
		
		li $t8, 248
		beq $t4, $t8, SLEEP		# loc % 256 == 248 means player at right (since player loc is 2 units wide)
		
		# SET T3 TO NEW PLAYER LOC
		addi $t3, $t0, 4
		j updateLocation
		
respondToUp:
		# CHECK IF PLAYER IS GROUNDED
		jal isGrounded		# return value at v0
		beq $v0, $zero, SLEEP		# do nothing if player is not grounded (cannot jump while in midair)
		
		# SET VERTICAL VELOCITY TO t2 (CANNOT SET TO VELOCITY THAT IS INDIVISIBLE BY FALL SPD)
		li $t2, 24	# adjust for QoL
		
		j updateLocation
		
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
		lw $t5, 4($t3)	# t5 = color of unit at new player loc rightmost unit (since player is cube)
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
		
# PREREQ: $t3 is a valid new player location within the screen
undrawPlayer:
		# REPLACE CUBE POSITION WITH BLACK BACKGROUND
		li $t1, 0x0	# black
		sw $t1, 0($t0)
		sw $t1, 4($t0)
		sw $t1, -256($t0)
		sw $t1, -252($t0)
		
		# UPDATE CUBE POSITION USING TEMP POSITION (T3)
		move $t0, $t3
		
		# DRAW BACKGROUND NEXT
		j drawBackground
		
drawBackground:
		# TODO
		
		# DRAW PLATFORMS NEXT
		j drawPlatforms

# PREREQ: none of the platforms are 6 or more units from the rightmost part of the screen
# 		  nor 2 or more units from the bottom of the screen
drawPlatforms:
		# INITIALIZE REGISTERS FOR DRAWING PLATFORM LOOP
		li $t1, BROWN	# t1 = BROWN
		la $t8, lv1Platforms	# t8 = memory address of array lv1Platforms
		li $t4, 8	# t4 = number of total platforms to draw * 4
		li $t5, 0	# t5 = number of platforms drawn * 4
		
		j drawPlatformsLoop

drawPlatformsLoop:
		bge $t5, $t4, movePlatformsUD	# start moving platforms (up-down) next if loop finishes
		
		add $t6, $t8, $t5	# t6 is memory address of lv1Platforms[iteration]
		lw $t7, 0($t6)	# t7 = location of lv1Platforms[iteration] on game screen
		
		# DRAW PLATFORM (+6 units to the right)
		sw $t1, 0($t7)
		sw $t1, 4($t7)
		sw $t1, 8($t7)
		sw $t1, 12($t7)
		sw $t1, 16($t7)
		sw $t1, 20($t7)
		
		# DRAW PLATFORM SUPPORT (under)
		#sw $t1, 260($t7)
		#sw $t1, 264($t7)
		#sw $t1, 268($t7)
		#sw $t1, 272($t7)
		
		addi $t5, $t5, 4	# increment # platforms drawn * 4
		j drawPlatformsLoop

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
		
		jr $ra

drawPlatformsUD:
		# INITIALIZE REGISTERS FOR DRAWING MOVING PLATFORMS (up-down)
		li $t1, BROWN
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
		# TODO: CHANGE THIS ONCE PLAYER MODEL CHANGES
		addi $t6, $t0, 4
		ble $t8, $t6, checkPlayerInsideNewPlatform	# if new platform loc <= player loc + 4,
										# player MAY need to move up one unit
		
		j drawPlatformsUDIterEnd	# end of iteration

checkPlayerInsideNewPlatform:
		# Assume t8 (new platform loc) set from prev branch
		addi $t7, $t8, 20
		ble $t0, $t7, movePlayerWithRaisingPlatform		# player loc <= new platform loc + 20
											# AND new platform loc <= player loc + 4,
											# then player occupies new platform location
		j drawPlatformsUDIterEnd
movePlayerWithRaisingPlatform:
		addi $t0, $t0, -256
		j drawPlatformsUDIterEnd
		
drawPlatformsUDIterEnd:
		# DRAW PLATFORM (+6 units to the right)
		sw $t1, 0($t8)
		sw $t1, 4($t8)
		sw $t1, 8($t8)
		sw $t1, 12($t8)
		sw $t1, 16($t8)
		sw $t1, 20($t8)
		
		addi $t5, $t5, 4	# increment # platforms drawn * 4
		j drawPlatformsUDLoop
		
##########################
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
		
		jr $ra
		
drawPlatformsLR:
		# INITIALIZE REGISTERS FOR DRAWING MOVING PLATFORMS (left-right)
		li $t1, BROWN
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
		sw $t1, 0($t8)
		sw $t1, 4($t8)
		sw $t1, 8($t8)
		sw $t1, 12($t8)
		sw $t1, 16($t8)
		sw $t1, 20($t8)
		
		addi $t5, $t5, 4	# increment # platforms drawn * 4
		j drawPlatformsLRLoop

#################################

drawPlayer:
		# DRAW CUBE (2x2)
		li $t1, 0xff0000 # red
		sw $t1, 0($t0)
		sw $t1, 4($t0)
		sw $t1, -256($t0)
		sw $t1, -252($t0)
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
		
		# TODO: CHANGE CONDITION ONCE PLAYER MODEL CHANGES
		lw $t6, 256($t0)		# load color of pixel below player loc (bottom leftmost player pixel)
		lw $t7, 260($t0)		# load color of pixel below player loc (bottom rightmost player pixel)
		
		beq $t6, $t1, returnIsGrounded
		beq $t7, $t1, returnIsGrounded
		
		# CHECK IF PIXEL(s) BELOW NEW PLAYER LOC IS PLATFORM (BROWN)
		# TODO: CHANGE CONDITION ONCE PLAYER MODEL CHANGES
		lw $t6, 256($t3)
		lw $t7, 260($t3)
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
		addi $t4, $t0, -256	# only one unit above since player is cube (TODO)
		
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
