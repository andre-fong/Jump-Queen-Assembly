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
lv1Platforms:	.word	0x1000BB28, 0x1000B788	# TODO
lv1MovePlatformsUD:	.word	0x1000B728	# TODO: MAKE PLATFORMS MOVE!!!!!
lv1MovePlatformsLR:	.word	0x0	# TODO
currentLv:		.word	1 # TODO

.text
main:	# IMPORTANT TEMP REGISTERS: t0 (PLAYER LOCATION), t1 (COLOR), 
		# t2 (PLAYER VERTICAL VELOCITY), t3 (TEMP PLAYER LOCATION)

		# INITIALIZE PLAYER POSITION (bottom left of character)
		li $t0, 0x1000BF28
		
		# iNITIALIZE PLAYER VERTICAL VELOCITY (0 to start)
		li $t2, 0
		
		# SET T3 (temp new player location) TO CURRENT PLAYER LOCATION
		move $t3, $t0
		
		j drawPlayer

gameLoop:
		# SET T3 (temp new player location) TO CURRENT PLAYER LOCATION
		move $t3, $t0

		# SET T9 TO ADDRESS OF KEYBOARD INPUT
		li $t9, 0xffff0000
		lw $t8, 0($t9)
		beq $t8, 1, keypressHappened
		
		j updateLocation

keypressHappened:
		lw $t7, 4($t9) # this assumes $t9 is set to 0xfff0000 from before
		beq $t7, 0x61, respondToLeft 	# ASCII code of 'a' is 0x61
		beq $t7, 0x64, respondToRight	# ASCII code of 'd' is 0x64
		beq $t7, 0x77, respondToUp	# ASCII code of 'w' is 0x77
		beq $t7, 0x71, QUIT			# ASCII code of 'q' is 0x71
		# TODO: IMPLEMENT RESET
		
		j updateLocation
		
respondToLeft:
		# CHECK MOVEMENT VALID (playerLoc at very left)
		li $t9, 256
		div $t0, $t9
		mfhi $t4	# t4 = playerLoc % 256
		
		beq $t4, $zero, SLEEP		# loc % 256 == 0 means player at left
		
		# SET T3 TO NEW PLAYER LOC
		addi $t3, $t0, -4
		j updateLocation

respondToRight:
		# CHECK MOVEMENT VALID (playerLoc at very right)
		li $t9, 256
		div $t0, $t9
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
		li $t2, 27
		
		j updateLocation
		
updateLocation:
		# CHECK VERTICAL VELOCITY
		bnez $t2, updateLocationVERTICAL	# if velocity is nonzero, update vertical location of player
		
		# IF PLAYER IS GROUNDED (and velocity is 0), SKIP UPDATING VELOCITY AND REDRAW
		jal isGrounded
		li $t5, 1
		beq $v0, $t5, undrawPlayer
		
		# UPDATE VELOCITY
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

# TODO: BELOW FUNC NOT NEEDED
skipDecreaseHeight:
		# IF PLAYER IS GROUNDED (and velocity is negative), SET VELOCITY TO ZERO
		jal isGrounded
		li $t5, 1
		beq $v0, $t5, setVelocityZero
		
		# ELSE, UPDATE VELOCITY
		j updateVelocityGravity
		
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
		la $t9, lv1Platforms	# t9 = memory address of array lv1Platforms
		li $t4, 8	# t4 = number of total platforms to draw * 4
		li $t5, 0	# t5 = number of platforms drawn * 4
		
		j drawPlatformsLoop

drawPlatformsLoop:
		bge $t5, $t4, drawPlayer	# draw player next if platforms are done being drawn
		
		add $t6, $t9, $t5	# t6 is memory address of lv1Platforms[iteration]
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
		
		lw $t6, 256($t0)		# load color of pixel below player loc (bottom leftmost player pixel)
		lw $t7, 260($t0)		# load color of pixel below player loc (bottom rightmost player pixel)
		
		beq $t6, $t1, returnIsGrounded
		beq $t7, $t1, returnIsGrounded
		
		# CHECK IF PIXEL(s) BELOW NEW PLAYER LOC IS PLATFORM (BROWN)
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
		
		# TODO: remove printing velocity
		li $v0, 1
		move $a0, $t2
		syscall
		
		j gameLoop	# jump back to game loop

QUIT:	li $v0, 10
		syscall

			
