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
# - Milestone 1,2,3,4 (ALL)
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. MOVING PLATFORMS (2 points)
# 	- multiple platforms that move left-to-right and up-and-down
# 2. DIFFERENT LEVELS (2 points)
#	- 3 different levels with ramping difficulty
#	- player finishes level when they jump and reach the top
# 3. PICKUP EFFECTS (2 points)
#	- feather: jump boost for the next jump only
#	- hourglass: slow down time (so moving platforms are easier to maneuver)
#	- heart: to restore player health (out of 3)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
# - https://www.youtube.com/watch?v=IGftLoSEIy4
#
# Are you OK with us sharing the video with people outside course staff?
# - yes, and please share this project github link as well!
# - https://github.com/andre-fong/Jump-Queen-Assembly (privated until end of April)
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

.eqv RED 0xFF0000
.eqv DARKGRAY 0x535353

.eqv PINK 0xFF5B5B

.data
playerHealth:	.byte		3

# locations of static platforms
lv1Platforms:	.word	0x1000B9B0, 0x1000B294, 0x1000AF5C, 0x1000B23C, 0x1000A75C, 0x10008DC4
lv1NumPlatforms:	.byte		24	# num platforms * 4
lv2Platforms:	.word	0x1000BBC4, 0x1000B614, 0x1000A614, 0x1000A550, 0x1000A780, 0x10008DC4
lv2NumPlatforms:	.byte		24	# num platforms * 4
lv3Platforms:	.word	0x1000BBC4, 0x1000BBBC, 0x1000B870, 0x1000A634, 0x1000A644, 0x1000A648, 0x1000954C, 0x1000953C, 0x1000952C, 0x1000951C
lv3NumPlatforms:	.byte		40	# num platforms * 4
curPlatformsAddr:	.word	0x0
curNumPlatforms:	.byte		0	# CURRENT LV'S number of static platforms

# locations of moving platforms (up-down)
lv1MovePlatformsUD:	.word	0x1000AA14, 0x1000A07C, 0x10009BA4
lv2MovePlatformsUD:	.word	0x1000AA14
lv3MovePlatformsUD:	.word	0x1000BD80, 0x1000B00C, 0x1000A2C4
curMovePlatformsUDAddr:	.word	0
# move progress of respective platform (0 to 5)
lv1MovePlatformsUDProg:	.word		0, 5, 0
lv2MovePlatformsUDProg:	.word		0
lv3MovePlatformsUDProg:	.word		3, 5, 0
curMovePlatformsUDProgAddr:	.word	0
# 0 = lowering, 1 = raising, 2+ = waiting
lv1MovePlatformsUDState:	.word		0, 1, 0
lv2MovePlatformsUDState:	.word		0
lv3MovePlatformsUDState:	.word		0, 1, 0
curMovePlatformsUDStateAddr:	.word	0
lv1NumMovePlatformsUD:	.byte		12	# num platforms UD * 4
lv2NumMovePlatformsUD:	.byte		0	# num platforms UD * 4
lv3NumMovePlatformsUD:	.byte		12	# num platforms UD * 4
curNumMovePlatformsUD:	.byte		0	# CURRENT LV'S number of up-down platforms

# locations of moving platforms (left-right)
lv1MovePlatformsLR:	.word	0
lv2MovePlatformsLR:	.word	0x1000BB7C, 0x1000BB30, 0x10009BA8
lv3MovePlatformsLR:	.word	0x1000BD2C, 0x1000A678, 0x10009580
curMovePlatformsLRAddr:	.word	0
# move progress of respective platform (0 to 7)
lv1MovePlatformsLRProg:	.word		0
lv2MovePlatformsLRProg:	.word		0, 7, 4
lv3MovePlatformsLRProg:	.word		3, 0, 6
curMovePlatformsLRProgAddr:	.word	0
# 0 = moving left, 1 = moving right, 2+ = waiting
lv1MovePlatformsLRState:	.word		0
lv2MovePlatformsLRState:	.word		0, 1, 0
lv3MovePlatformsLRState:	.word		0, 0, 1
curMovePlatformsLRStateAddr:	.word	0
lv1NumMovePlatformsLR:	.byte		0	# num platforms LR * 4
lv2NumMovePlatformsLR:	.byte		12	# num platforms LR * 4
lv3NumMovePlatformsLR:	.byte		12	# num platforms LR * 4
curNumMovePlatformsLR:	.byte		0	# CURRENT LV'S number of left-right platforms

# locations of feather pickups (increases jumping power)
lv1Feathers:	.word	0
lv1FeathersAlive:	.word	0
lv1NumFeathers:	.byte		0	# num feathers * 4
lv2Feathers:	.word	0x1000B318, 0x1000A584, 0x10009AC8
lv2FeathersAlive:	.word	1, 1, 1
lv2NumFeathers:	.byte		12	# num feathers * 4
lv3Feathers:	.word	0x1000B774, 0x10009424
lv3FeathersAlive:	.word	1, 1
lv3NumFeathers:	.byte		8	# num feathers * 4

curFeathersAddr:	.word	0
curFeathersAliveAddr:		.word	0
curNumFeathers:	.byte		0

featherInEffect:	.byte		0

# locations of hourglass pickups (slow down time)
lv1Hourglasses:	.word	0
lv1HourglassesAlive:	.word	0
lv1NumHourglasses:	.byte		0	# num hourglasses * 4
lv2Hourglasses:	.word	0x1000B5AC
lv2HourglassesAlive:	.word	1
lv2NumHourglasses:	.byte		4	# num hourglasses * 4
lv3Hourglasses:	.word	0x1000A54C
lv3HourglassesAlive:	.word	1
lv3NumHourglasses:	.byte		4	# num hourglasses * 4

curHourglassesAddr:	.word	0
curHourglassesAliveAddr:		.word	0
curNumHourglasses:	.byte		0

hourglassInEffect:	.byte		0
hourglassStartTime:	.word	0
platformMoveFrequency:	.byte		4

# locations of hearts pickups (adds health if player needs it)
lv1Hearts:	.word	0x1000A418
lv1HeartsAlive:	.word	1
lv1NumHearts:	.byte		4	# num heart pickups * 4
lv2Hearts:	.word	0x1000A018
lv2HeartsAlive:	.word	1
lv2NumHearts:	.byte		4	# num heart pickups * 4
lv3Hearts:	.word	0
lv3HeartsAlive:	.word	0
lv3NumHearts:	.byte		0	# num heart pickups * 4

curHeartsAddr:	.word	0
curHeartsAliveAddr:		.word	0
curNumHearts:	.byte		0

currentLv:		.byte		1

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
		
		# INITIALIZE *CURRENT LV*'s ADDRESSES AND VALUES
		
		# static platforms
		la $t4, lv1Platforms
		sw $t4, curPlatformsAddr
		lb $t5, lv1NumPlatforms
		sb $t5, curNumPlatforms
		
		# UD platforms
		la $t4, lv1MovePlatformsUD
		sw $t4, curMovePlatformsUDAddr
		la $t5, lv1MovePlatformsUDProg
		sw $t5, curMovePlatformsUDProgAddr
		la $t6, lv1MovePlatformsUDState
		sw $t6, curMovePlatformsUDStateAddr
		lb $t7, lv1NumMovePlatformsUD
		sb $t7, curNumMovePlatformsUD
		
		# LR platforms
		la $t4, lv1MovePlatformsLR
		sw $t4, curMovePlatformsLRAddr
		la $t5, lv1MovePlatformsLRProg
		sw $t5, curMovePlatformsLRProgAddr
		la $t6, lv1MovePlatformsLRState
		sw $t6, curMovePlatformsLRStateAddr
		lb $t7, lv1NumMovePlatformsLR
		sb $t7, curNumMovePlatformsLR
		
		# feathers
		la $t4, lv1Feathers
		sw $t4, curFeathersAddr
		la $t5, lv1FeathersAlive
		sw $t5, curFeathersAliveAddr
		lb $t6, lv1NumFeathers
		sb $t6, curNumFeathers
		
		# hourglasses
		la $t4, lv1Hourglasses
		sw $t4, curHourglassesAddr
		la $t5, lv1HourglassesAlive
		sw $t5, curHourglassesAliveAddr
		lb $t6, lv1NumHourglasses
		sb $t6, curNumHourglasses
		
		# hearts
		la $t4, lv1Hearts
		sw $t4, curHeartsAddr
		la $t5, lv1HeartsAlive
		sw $t5, curHeartsAliveAddr
		lb $t6, lv1NumHearts
		sb $t6, curNumHearts
		
		# RESET HEARTS ON LV1 AND LV2
		li $t4, 1
		sw $t4, lv1HeartsAlive
		sw $t4, lv2HeartsAlive
		
		# RESET ALL EFFECTS
		sb $zero, featherInEffect
		sb $zero, hourglassInEffect
		
		# RESET PLAYER HEALTH
		li $t5, 3
		sb $t5, playerHealth
		
		# RESET CURRENT LV COUNTER
		li $t6, 1
		sb $t6, currentLv
		
		j undrawScreen

beatLevel:
		# GET LEVEL
		lb $t4, currentLv
		
		# IF ALL LEVELS BEATEN, WIN GAME
		li $t5, 3
		beq $t4, $t5, winGame
		
		# ELSE, INCREMENT LEVEL AND UPDATE CURRENT LV'S ADDRESSES AND VALUES
		addi $t4, $t4, 1
		sb $t4, currentLv
		
		li $t0, 0x1000BEC8	# update position of player to bottom of screen + 1 row (since level restarted)
		move $t3, $t0	# update temp player pos to match t0
		li $t2, 12	# update velocity to be "jumping" initially
		
		beq $t4, $t5, beatSecondLevel	# if cur level + 1 = 3, we just beat second level
		
		# otherwise, we just beat first level
		# static platforms
		la $t4, lv2Platforms
		sw $t4, curPlatformsAddr
		lb $t5, lv2NumPlatforms
		sb $t5, curNumPlatforms
		
		# UD platforms
		la $t4, lv2MovePlatformsUD
		sw $t4, curMovePlatformsUDAddr
		la $t5, lv2MovePlatformsUDProg
		sw $t5, curMovePlatformsUDProgAddr
		la $t6, lv2MovePlatformsUDState
		sw $t6, curMovePlatformsUDStateAddr
		lb $t7, lv2NumMovePlatformsUD
		sb $t7, curNumMovePlatformsUD
		
		# LR platforms
		la $t4, lv2MovePlatformsLR
		sw $t4, curMovePlatformsLRAddr
		la $t5, lv2MovePlatformsLRProg
		sw $t5, curMovePlatformsLRProgAddr
		la $t6, lv2MovePlatformsLRState
		sw $t6, curMovePlatformsLRStateAddr
		lb $t7, lv2NumMovePlatformsLR
		sb $t7, curNumMovePlatformsLR
		
		# feathers
		la $t4, lv2Feathers
		sw $t4, curFeathersAddr
		la $t5, lv2FeathersAlive
		sw $t5, curFeathersAliveAddr
		lb $t6, lv2NumFeathers
		sb $t6, curNumFeathers
		
		# hourglasses
		la $t4, lv2Hourglasses
		sw $t4, curHourglassesAddr
		la $t5, lv2HourglassesAlive
		sw $t5, curHourglassesAliveAddr
		lb $t6, lv2NumHourglasses
		sb $t6, curNumHourglasses
		
		# hearts
		la $t4, lv2Hearts
		sw $t4, curHeartsAddr
		la $t5, lv2HeartsAlive
		sw $t5, curHeartsAliveAddr
		lb $t6, lv2NumHearts
		sb $t6, curNumHearts
		
		# RESET LV2's PICKUPS (except hearts)
		
		# INITIALIZE REGISTERS FOR LOOPING THROUGH LV2's PICKUPS
		lb $t4, lv2NumFeathers	# t4 = number of total feathers to reset
		li $t5, 0	# t5 = number of feathers reset * 4
		lb $t6, lv2NumHourglasses	# t6 = number of total hourglasses to reset
		li $t7, 0	# t7 = number of hourglasses reset * 4
		la $s0, lv2FeathersAlive	# s0 = memory address of array lv2FeathersAlive
		la $s1, lv2HourglassesAlive	# s1 = memory address of array lv2HourglassesAlive
		
		j resetFeathersLoop	# start resetting feather pickups
		
beatSecondLevel:
		# static platforms
		la $t4, lv3Platforms
		sw $t4, curPlatformsAddr
		lb $t5, lv3NumPlatforms
		sb $t5, curNumPlatforms
		
		# UD platforms
		la $t4, lv3MovePlatformsUD
		sw $t4, curMovePlatformsUDAddr
		la $t5, lv3MovePlatformsUDProg
		sw $t5, curMovePlatformsUDProgAddr
		la $t6, lv3MovePlatformsUDState
		sw $t6, curMovePlatformsUDStateAddr
		lb $t7, lv3NumMovePlatformsUD
		sb $t7, curNumMovePlatformsUD
		
		# LR platforms
		la $t4, lv3MovePlatformsLR
		sw $t4, curMovePlatformsLRAddr
		la $t5, lv3MovePlatformsLRProg
		sw $t5, curMovePlatformsLRProgAddr
		la $t6, lv3MovePlatformsLRState
		sw $t6, curMovePlatformsLRStateAddr
		lb $t7, lv3NumMovePlatformsLR
		sb $t7, curNumMovePlatformsLR
		
		# feathers
		la $t4, lv3Feathers
		sw $t4, curFeathersAddr
		la $t5, lv3FeathersAlive
		sw $t5, curFeathersAliveAddr
		lb $t6, lv3NumFeathers
		sb $t6, curNumFeathers
		
		# hourglasses
		la $t4, lv3Hourglasses
		sw $t4, curHourglassesAddr
		la $t5, lv3HourglassesAlive
		sw $t5, curHourglassesAliveAddr
		lb $t6, lv3NumHourglasses
		sb $t6, curNumHourglasses
		
		# hearts
		la $t4, lv3Hearts
		sw $t4, curHeartsAddr
		la $t5, lv3HeartsAlive
		sw $t5, curHeartsAliveAddr
		lb $t6, lv3NumHearts
		sb $t6, curNumHearts
		
		# INITIALIZE REGISTERS FOR LOOPING THROUGH LV3's PICKUPS
		lb $t4, lv3NumFeathers	# t4 = number of total feathers to reset
		li $t5, 0	# t5 = number of feathers reset * 4
		lb $t6, lv3NumHourglasses	# t6 = number of total hourglasses to reset
		li $t7, 0	# t7 = number of hourglasses reset * 4
		la $s0, lv3FeathersAlive	# s0 = memory address of array lv3FeathersAlive
		la $s1, lv3HourglassesAlive	# s1 = memory address of array lv3HourglassesAlive
		
		j resetFeathersLoop	# start resetting feather pickups
		
resetFeathersLoop:
		# Assume t4 = num feathers to reset, t5 = 0 at beginning of loop, s0 = address of feathers alive array
		bge $t5, $t4, resetHourglassesLoop	# if done resetting feathers, reset hourglasses
		
		add $t1, $t5, $s0	# t5 = address of feathersAlive[iteration]
		li $t8, 1
		sw $t8, 0($t1)	# feathersAlive[iteration] = 1
		
		addi $t5, $t5, 4	# iteration * 4
		j resetFeathersLoop
		
resetHourglassesLoop:
		# Assume t6 = num hourglasses to reset, t7 = 0 at beginning of loop, 
		# s1 = address of hourglasses alive array
		bge $t7, $t6, undrawScreen		# if done resetting pickups, undraw screen to prepare for
								# drawing of next level
								
		add $t1, $t7, $s1	# t5 = address of hourglassesAlive[iteration]
		li $t8, 1
		sw $t8, 0($t1)	# hourglassesAlive[iteration] = 1
		
		addi $t7, $t7, 4	# iteration * 4
		j resetHourglassesLoop
		
undrawScreen:
		# INITIALIZE REGISTERS TO PREPARE FOR UNDRAW SCREEN LOOP
		li $t4, BASE_ADDRESS
		addi $t4, $t4, 16380	# t4 = bottom rightmost unit on screen
		li $t5, BASE_ADDRESS		# t5 = current unit to erase
		li $t1, 0x0	# black
		
		j undrawScreenLoop
undrawScreenLoop:
		bge $t5, $t4, undrawPlayer		# draw all assets once screen is done being reset to black
		
		sw $t1, 0($t5)	# set unit color to black
		
		addi $t5, $t5, 4	# increment by 4
		j undrawScreenLoop
		
undrawScreenAfterGame:
		# INITIALIZE REGISTERS TO PREPARE FOR UNDRAW SCREEN LOOP
		li $t4, BASE_ADDRESS
		addi $t4, $t4, 16380	# t4 = bottom rightmost unit on screen
		li $t5, BASE_ADDRESS		# t5 = current unit to erase
		li $t1, 0x0	# black
		
		j undrawScreenAfterGameLoop
undrawScreenAfterGameLoop:
		bge $t5, $t4, finishedUndrawScreenAfterGame	# draw all assets once screen is done being reset to black
		
		sw $t1, 0($t5)	# set unit color to black
		
		addi $t5, $t5, 4	# increment by 4
		j undrawScreenAfterGameLoop
finishedUndrawScreenAfterGame:
		jr $ra
		
winGame:
		# CLEAR SCREEN
		jal undrawScreenAfterGame

		# DRAW WIN GAME SCREEN
		li $t1, PINK
		li $t4, BASE_ADDRESS
		addi $t4, $t4, 5704
		
		# S
		sw $t1, 8($t4)
		sw $t1, 12($t4)
		sw $t1, 260($t4)
		sw $t1, 264($t4)
		sw $t1, 512($t4)
		sw $t1, 516($t4)
		sw $t1, 772($t4)
		sw $t1, 776($t4)
		sw $t1, 1036($t4)
		sw $t1, 1292($t4)
		sw $t1, 1540($t4)
		sw $t1, 1544($t4)
		sw $t1, 1548($t4)
		sw $t1, 1792($t4)
		sw $t1, 1796($t4)
		sw $t1, 1800($t4)
		
		# L
		addi $t4, $t4, 24
		sw $t1, 0($t4)
		sw $t1, 256($t4)
		sw $t1, 512($t4)
		sw $t1, 768($t4)
		sw $t1, 1024($t4)
		sw $t1, 1280($t4)
		sw $t1, 1536($t4)
		sw $t1, 1540($t4)
		sw $t1, 1792($t4)
		sw $t1, 1796($t4)
		sw $t1, 1800($t4)
		sw $t1, 1804($t4)
		
		# A
		addi $t4, $t4, 28
		sw $t1, 0($t4)
		sw $t1, 256($t4)
		sw $t1, 252($t4)
		sw $t1, 260($t4)
		sw $t1, 508($t4)
		sw $t1, 516($t4)
		sw $t1, 764($t4)
		sw $t1, 772($t4)
		sw $t1, 1024($t4)
		sw $t1, 1020($t4)
		sw $t1, 1028($t4)
		sw $t1, 1276($t4)
		sw $t1, 1272($t4)
		sw $t1, 1284($t4)
		sw $t1, 1288($t4)
		sw $t1, 1528($t4)
		sw $t1, 1544($t4)
		sw $t1, 1784($t4)
		sw $t1, 1800($t4)
		
		# Y
		addi $t4, $t4, 24
		sw $t1, -8($t4)
		sw $t1, 8($t4)
		sw $t1, 252($t4)
		sw $t1, 248($t4)
		sw $t1, 260($t4)
		sw $t1, 264($t4)
		sw $t1, 508($t4)
		sw $t1, 516($t4)
		sw $t1, 764($t4)
		sw $t1, 768($t4)
		sw $t1, 772($t4)
		sw $t1, 1024($t4)
		sw $t1, 1280($t4)
		sw $t1, 1536($t4)
		sw $t1, 1792($t4)
		
		# !
		addi $t4, $t4, 24
		sw $t1, 0($t4)
		sw $t1, 252($t4)
		sw $t1, 256($t4)
		sw $t1, 260($t4)
		sw $t1, 508($t4)
		sw $t1, 512($t4)
		sw $t1, 516($t4)
		sw $t1, 764($t4)
		sw $t1, 768($t4)
		sw $t1, 772($t4)
		sw $t1, 1024($t4)
		sw $t1, 1280($t4)
		sw $t1, 1792($t4)
		
		# DRAW REMAINING PLAYER HEALTH
		li $t5, BASE_ADDRESS
		addi $t5, $t5, 9088	# unit offset for drawing heart
		
		li $t1, RED
		sw $t1, 4($t5)
		sw $t1, 12($t5)
		sw $t1, 256($t5)
		sw $t1, 260($t5)
		sw $t1, 264($t5)
		sw $t1, 272($t5)
		sw $t1, 516($t5)
		sw $t1, 520($t5)
		sw $t1, 524($t5)
		sw $t1, 776($t5)
		li $t1, WHITE
		sw $t1, 268($t5)
		
		addi $t5, $t5, -276	# unit offset for drawing number for remaining health
		li $t1, PINK
		
		lb $t6, playerHealth
		li $t7, 1
		beq $t6, $t7, drawOneRemainingHealth
		li $t7, 2
		beq $t6, $t7, drawTwoRemainingHealth
		
		# ELSE, DRAW 3 REMAINING HEALTH
		sw $t1, 0($t5)
		sw $t1, -4($t5)
		sw $t1, -8($t5)
		sw $t1, 256($t5)
		sw $t1, 512($t5)
		sw $t1, 508($t5)
		sw $t1, 504($t5)
		sw $t1, 768($t5)
		sw $t1, 1024($t5)
		sw $t1, 1020($t5)
		sw $t1, 1016($t5)
		
		# LOOP TO PROCESS PLAYER INPUT
		j processInputAfterGame
drawOneRemainingHealth:
		sw $t1, -4($t5)
		sw $t1, 252($t5)
		sw $t1, 248($t5)
		sw $t1, 508($t5)
		sw $t1, 764($t5)
		sw $t1, 1020($t5)
		sw $t1, 1016($t5)
		sw $t1, 1024($t5)
		
		# LOOP TO PROCESS PLAYER INPUT
		j processInputAfterGame
drawTwoRemainingHealth:
		sw $t1, 0($t5)
		sw $t1, -4($t5)
		sw $t1, -8($t5)
		sw $t1, 256($t5)
		sw $t1, 512($t5)
		sw $t1, 508($t5)
		sw $t1, 504($t5)
		sw $t1, 760($t5)
		sw $t1, 1016($t5)
		sw $t1, 1020($t5)
		sw $t1, 1024($t5)
		
		# LOOP TO PROCESS PLAYER INPUT
		j processInputAfterGame
loseGame:
		# CLEAR SCREEN
		jal undrawScreenAfterGame

		# DRAW LOSE GAME SCREEN
		li $t1, PINK
		li $t4, BASE_ADDRESS
		addi $t4, $t4, 5704
		
		# L
		sw $t1, 0($t4)
		sw $t1, 256($t4)
		sw $t1, 512($t4)
		sw $t1, 768($t4)
		sw $t1, 1024($t4)
		sw $t1, 1280($t4)
		sw $t1, 1284($t4)
		sw $t1, 1288($t4)
		
		# O
		addi $t4, $t4, 20
		sw $t1, 0($t4)
		sw $t1, 8($t4)
		sw $t1, 256($t4)
		sw $t1, 264($t4)
		sw $t1, 512($t4)
		sw $t1, 520($t4)
		sw $t1, 768($t4)
		sw $t1, 776($t4)
		sw $t1, 1024($t4)
		sw $t1, 1032($t4)
		sw $t1, 1280($t4)
		sw $t1, 1288($t4)
		sw $t1, 4($t4)
		sw $t1, 1284($t4)
		
		# S
		addi $t4, $t4, 20
		sw $t1, 0($t4)
		sw $t1, 4($t4)
		sw $t1, 8($t4)
		sw $t1, 256($t4)
		sw $t1, 512($t4)
		sw $t1, 516($t4)
		sw $t1, 772($t4)
		sw $t1, 776($t4)
		sw $t1, 1032($t4)
		sw $t1, 1288($t4)
		sw $t1, 1284($t4)
		sw $t1, 1280($t4)
		
		# E
		addi $t4, $t4, 20
		sw $t1, 0($t4)
		sw $t1, 4($t4)
		sw $t1, 8($t4)
		sw $t1, 256($t4)
		sw $t1, 512($t4)
		sw $t1, 516($t4)
		sw $t1, 520($t4)
		sw $t1, 768($t4)
		sw $t1, 772($t4)
		sw $t1, 776($t4)
		sw $t1, 1024($t4)
		sw $t1, 1280($t4)
		sw $t1, 1284($t4)
		sw $t1, 1288($t4)
		
		# ...
		addi $t4, $t4, 1044
		sw $t1, 0($t4)
		sw $t1, 256($t4)
		sw $t1, 12($t4)
		sw $t1, 268($t4)
		sw $t1, 24($t4)
		sw $t1, 280($t4)
		
		# DRAW REMAINING PLAYER HEALTH (0)
		li $t5, BASE_ADDRESS
		addi $t5, $t5, 9088	# unit offset for drawing heart
		
		li $t1, RED
		sw $t1, 4($t5)
		sw $t1, 12($t5)
		sw $t1, 256($t5)
		sw $t1, 260($t5)
		sw $t1, 264($t5)
		sw $t1, 272($t5)
		sw $t1, 516($t5)
		sw $t1, 520($t5)
		sw $t1, 524($t5)
		sw $t1, 776($t5)
		li $t1, WHITE
		sw $t1, 268($t5)
		
		addi $t5, $t5, -276	# unit offset for drawing number for remaining health
		li $t1, PINK
		
		# 0
		sw $t1, 0($t5)
		sw $t1, 8($t5)
		sw $t1, 256($t5)
		sw $t1, 264($t5)
		sw $t1, 512($t5)
		sw $t1, 520($t5)
		sw $t1, 768($t5)
		sw $t1, 776($t5)
		sw $t1, 1024($t5)
		sw $t1, 1032($t5)
		sw $t1, 4($t5)
		sw $t1, 1028($t5)
		
		# LOOP TO PROCESS PLAYER INPUT
		j processInputAfterGame
		
processInputAfterGame:
		# SET T5 TO ADDRESS OF KEYBOARD INPUT
		li $t5, 0xffff0000
		lw $t8, 0($t5)
		beq $t8, 1, keypressHappenedAfterGame

		li $v0, 32
		li $a0, 30	# Wait 30ms
		syscall
		
		j processInputAfterGame
keypressHappenedAfterGame:
		lw $t7, 4($t5) # this assumes $t5 is set to 0xfff0000 from before
		beq $t7, 0x71, QUIT			# ASCII code of 'q' is 0x71
		beq $t7, 0x72, main			# ASCII code of 'r' is 0x72
		
		j processInputAfterGame
		
loseLevel:
		# IF PLAYER IS STILL ON FIRST LEVEL, HITTING GROUND DOES NOT DO ANYTHING
		lb $t4, currentLv
		li $t5, 1
		beq $t4, $t5, undrawPlayer
		
		# ELSE, DECREMENT CURRENTLV
		addi $t4, $t4, -1
		sb $t4, currentLv
		
		# SET PLAYER LOCATION TO TOP OF SCREEN (to simulate falling down a level)
		addi $t0, $t0, -13824	# new player loc = old player loc + 13824 units (54 rows)
		move $t3, $t0	# update temp player pos to match t0
		
		# DECREMENT HEARTS IF POSSIBLE
		lb $t6, playerHealth
		addi $t6, $t6, -1
		sb $t6, playerHealth
		beqz $t6, loseGame	# if new player health after decrement == 0, player lost
		
		lb $t4, currentLv
		li $t7, 2
		beq $t4, $t7, lostThirdLevel		# if decremented level == 2, player just lost third level
		
		# OTHERWISE, PLAYER JUST LOST SECOND LEVEL
		
		# UPDATE CURRENT LV'S ADDRESSES AND VALUES (1)
		# static platforms
		la $t4, lv1Platforms
		sw $t4, curPlatformsAddr
		lb $t5, lv1NumPlatforms
		sb $t5, curNumPlatforms
		
		# UD platforms
		la $t4, lv1MovePlatformsUD
		sw $t4, curMovePlatformsUDAddr
		la $t5, lv1MovePlatformsUDProg
		sw $t5, curMovePlatformsUDProgAddr
		la $t6, lv1MovePlatformsUDState
		sw $t6, curMovePlatformsUDStateAddr
		lb $t7, lv1NumMovePlatformsUD
		sb $t7, curNumMovePlatformsUD
		
		# LR platforms
		la $t4, lv1MovePlatformsLR
		sw $t4, curMovePlatformsLRAddr
		la $t5, lv1MovePlatformsLRProg
		sw $t5, curMovePlatformsLRProgAddr
		la $t6, lv1MovePlatformsLRState
		sw $t6, curMovePlatformsLRStateAddr
		lb $t7, lv1NumMovePlatformsLR
		sb $t7, curNumMovePlatformsLR
		
		# feathers
		la $t4, lv1Feathers
		sw $t4, curFeathersAddr
		la $t5, lv1FeathersAlive
		sw $t5, curFeathersAliveAddr
		lb $t6, lv1NumFeathers
		sb $t6, curNumFeathers
		
		# hourglasses
		la $t4, lv1Hourglasses
		sw $t4, curHourglassesAddr
		la $t5, lv1HourglassesAlive
		sw $t5, curHourglassesAliveAddr
		lb $t6, lv1NumHourglasses
		sb $t6, curNumHourglasses
		
		# hearts
		la $t4, lv1Hearts
		sw $t4, curHeartsAddr
		la $t5, lv1HeartsAlive
		sw $t5, curHeartsAliveAddr
		lb $t6, lv1NumHearts
		sb $t6, curNumHearts
		
		j undrawScreen
lostThirdLevel:
		# UPDATE CURRENT LV'S ADDRESSES AND VALUES (2)
		# static platforms
		la $t4, lv2Platforms
		sw $t4, curPlatformsAddr
		lb $t5, lv2NumPlatforms
		sb $t5, curNumPlatforms
		
		# UD platforms
		la $t4, lv2MovePlatformsUD
		sw $t4, curMovePlatformsUDAddr
		la $t5, lv2MovePlatformsUDProg
		sw $t5, curMovePlatformsUDProgAddr
		la $t6, lv2MovePlatformsUDState
		sw $t6, curMovePlatformsUDStateAddr
		lb $t7, lv2NumMovePlatformsUD
		sb $t7, curNumMovePlatformsUD
		
		# LR platforms
		la $t4, lv2MovePlatformsLR
		sw $t4, curMovePlatformsLRAddr
		la $t5, lv2MovePlatformsLRProg
		sw $t5, curMovePlatformsLRProgAddr
		la $t6, lv2MovePlatformsLRState
		sw $t6, curMovePlatformsLRStateAddr
		lb $t7, lv2NumMovePlatformsLR
		sb $t7, curNumMovePlatformsLR
		
		# feathers
		la $t4, lv2Feathers
		sw $t4, curFeathersAddr
		la $t5, lv2FeathersAlive
		sw $t5, curFeathersAliveAddr
		lb $t6, lv2NumFeathers
		sb $t6, curNumFeathers
		
		# hourglasses
		la $t4, lv2Hourglasses
		sw $t4, curHourglassesAddr
		la $t5, lv2HourglassesAlive
		sw $t5, curHourglassesAliveAddr
		lb $t6, lv2NumHourglasses
		sb $t6, curNumHourglasses
		
		# hearts
		la $t4, lv2Hearts
		sw $t4, curHeartsAddr
		la $t5, lv2HeartsAlive
		sw $t5, curHeartsAliveAddr
		lb $t6, lv2NumHearts
		sb $t6, curNumHearts
		
		# RESET LV2's PICKUPS (except hearts)
		
		# INITIALIZE REGISTERS FOR LOOPING THROUGH LV2's PICKUPS
		lb $t4, lv2NumFeathers	# t4 = number of total feathers to reset
		li $t5, 0	# t5 = number of feathers reset * 4
		lb $t6, lv2NumHourglasses	# t6 = number of total hourglasses to reset
		li $t7, 0	# t7 = number of hourglasses reset * 4
		la $s0, lv2FeathersAlive	# s0 = memory address of array lv2FeathersAlive
		la $s1, lv2HourglassesAlive	# s1 = memory address of array lv2HourglassesAlive
		
		j resetFeathersLoop	# start resetting feather pickups

gameLoop:
		# CHECK IF PLAYER AT VERY TOP (CLEARED LEVEL)
		addi $t4, $t0, -2048	# top leftmost player unit
		
		li $t5, 252
		addi $t6, $t5, BASE_ADDRESS	# t6 = rightmost unit on first row
		ble $t4, $t6, beatLevel	# if the player's topmost unit is on the first row of the screen,
							# we beat the current level
		
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
		beq $t7, 0x72, main			# ASCII code of 'r' is 0x72
		
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
		li $t2, 18	# adjust for QoL
		
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
		beq $v0, $t4, checkIfPlayerLost
		
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
		
checkIfPlayerLost:
		# CHECK IF PLAYER LOCATION IS ON THE LAST ROW (bottom of screen)
		li $t4, 16128
		addi $t5, $t4, BASE_ADDRESS
		bge $t0, $t5, loseLevel	# if t0 >= BASE_ADDRESS + 16128, player is on bottom of screen,
							# hence, player lost level
							
		j setVelocityZero

setVelocityZero:
		li $t2, 0
		j undrawPlayer

#################################################
# DRAWING (undraw player, draw background, pickups, platforms, moving platforms, draw player, draw hearts UI)
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
		
		# DRAW FEATHERS NEXT
		j drawFeathers

drawFeathers:
		# INITIALIZE REGISTERS FOR DRAWING FEATHERS LOOP
		lb $t4, curNumFeathers	# t4 = number of total feathers to draw * 4
		li $t5, 0	# t5 = number of feathers drawn * 4
		lw $s0, curFeathersAddr	# s0 = memory address of array lv(x)feathers
		lw $s1, curFeathersAliveAddr	# s1 = memory address of array lv(x)FeathersAlive
		la $s2, featherInEffect		# s2 = memory address of boolean featherInEffect
								# (0 = not in effect, 1 = in effect)
		
		j drawFeathersLoop

drawFeathersLoop:
		bge $t5, $t4, drawHourglasses	# start drawing hourglasses next if loop finishes
		
		# CHECK IF FEATHER IS STILL ALIVE (not picked up yet)
		add $t6, $s1, $t5	# t6 is memory address of lv(x)FeathersAlive[iteration]
		lw $t7, 0($t6)	# t7 = whether or not feather is still alive
		beqz $t7, drawFeathersIterEnd	# if feather is not alive, skip checking player dist and drawing

		# CHECK IF PLAYER IS NEAR FEATHER
		add $t6, $s0, $t5	# t6 is memory address of lv(x)Feathers[iteration]
		lw $t7, 0($t6)	# t7 = location of lv(x)Feathers[iteration] on game screen
		
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
		# Assume $t7 set to location of lv(x)Feathers[iteration] from previous branch
		li $t8, 28
		add $t8, $t8, $t7
		bge $t8, $t0, pickUpFeather		# if feather loc + 28 >= player loc AND
								# player loc + 16 >= feather loc, player IS touching feather
		
		# IF PLAYER ISN'T TOUCHING FEATHER, DRAW
		j drawFeatherOnScreen
		
pickUpFeather:
		# SET FEATHERALIVE[iteration] TO 0
		add $t6, $s1, $t5	# t6 is memory address of lv(x)FeathersAlive[iteration]
		sw $zero, 0($t6)	
		
		# SET FEATHER IN EFFECT TO 1
		li $t7, 1
		sb $t7, 0($s2)	# since s2 = memory address of boolean featherInEffect
		
		# UNDRAW FEATHER
		jal undrawFeatherOnScreen
		
		j drawFeathersIterEnd		# end of iteration (no need to draw feather, since it's been picked up)
		
drawFeatherOnScreen:
		add $t6, $s0, $t5	# t6 is memory address of lv(x)Feathers[iteration]
		lw $t7, 0($t6)	# t7 = location of lv(x)Feathers[iteration] on game screen
		
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

# PREREQ: $s0 is the memory address of lv(x)Feathers[iteration]
#		  $t5 is the iteration count * 4
undrawFeatherOnScreen:
		add $t6, $s0, $t5	# t6 is memory address of lv(x)Feathers[iteration]
		lw $t7, 0($t6)	# t7 = location of lv(x)Feathers[iteration] on game screen
		
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
		lb $t4, curNumHourglasses	# t4 = number of total hourglasses to draw * 4
		li $t5, 0	# t5 = number of hourglasses drawn * 4
		lw $s0, curHourglassesAddr	# s0 = memory address of array lv(x)Hourglasses
		lw $s1, curHourglassesAliveAddr	# s1 = memory address of array lv(x)HourglassesAlive
		la $s2, hourglassInEffect		# s2 = memory address of boolean hourglassInEffect
								# (0 = not in effect, 1 = in effect)
		la $s3, hourglassStartTime	# s3 = time that hourglass was picked up
		
		# IF HOURGLASS IN EFFECT, PROCESS EFFECT FIRST
		lb $t6, 0($s2)	# t6 = whether or not hourglass effect is currently active
		bnez $t6, processHourglassEffect
		
		j drawHourglassesLoop
		
processHourglassEffect:
		lw $t6, 0($s3)	# t6 = hourglass effect start time
		addi $t6, $t6, 250
		bgt $t9, $t6, disableHourglassEffect	# if game tick > hourglass effect start time + 250, 
									# hourglass effect is finished
									
		# SET PLATFORM MOVE FREQUENCY TO 12 (triple of normal freq)
		li $t7, 12
		sb $t7, platformMoveFrequency
		
		j drawHourglassesLoop
		
disableHourglassEffect:
		# SET PLATFORM MOVE FREQUENCY TO 4 (normal freq)
		li $t7, 4
		sb $t7, platformMoveFrequency

		sb $zero, 0($s2)	# set hourglassInEffect to 0
		j drawHourglassesLoop

drawHourglassesLoop:
		bge $t5, $t4, drawHeartPickups	# start drawing heart pickups next if loop finishes
		
		# CHECK IF HOURGLASS IS STILL ALIVE (not picked up yet)
		add $t6, $s1, $t5	# t6 is memory address of lv(x)HourglassesAlive[iteration]
		lw $t7, 0($t6)	# t7 = whether or not hourglass is still alive
		beqz $t7, drawHourglassesIterEnd	# if hourglass is not alive, skip checking player dist and drawing

		# CHECK IF PLAYER IS NEAR HOURGLASS
		add $t6, $s0, $t5	# t6 is memory address of lv(x)Hourglasses[iteration]
		lw $t7, 0($t6)	# t7 = location of lv(x)Hourglasses[iteration] on game screen
		
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
		# Assume $t7 set to location of lv(x)Hourglasses[iteration] 
		# OR lv(x)Hourglasses[iteration] + one row, from previous branch
		li $t8, 20
		add $t8, $t8, $t7
		bge $t8, $t0, pickUpHourglass		# if hourglass loc + 20 >= player loc AND
								# player loc + 16 >= hourglass loc, player IS touching hourglass
		
		# IF PLAYER ISN'T TOUCHING HOURGLASS, DRAW
		j drawHourglassOnScreen

pickUpHourglass:
		# SET HOURGLASSALIVE[iteration] TO 0
		add $t6, $s1, $t5	# t6 is memory address of lv(x)HourglassesAlive[iteration]
		sw $zero, 0($t6)
		
		# SET HOURGLASS IN EFFECT TO 1
		li $t7, 1
		sb $t7, 0($s2)	# since s2 = memory address of boolean hourglassInEffect
		
		# SET HOURGLASS START TIME TO CURRENT GAME TICK
		sw $t9, 0($s3)
		
		# UNDRAW HOURGLASS
		jal undrawHourglassOnScreen
		
		j drawHourglassesIterEnd		# end of iteration (no need to draw hourglass, since it's been picked up)
		
drawHourglassOnScreen:
		add $t6, $s0, $t5	# t6 is memory address of lv(x)Hourglasses[iteration]
		lw $t7, 0($t6)	# t7 = location of lv(x)Hourglasses[iteration] on game screen
		
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

# PREREQ: $s0 is the memory address of lv(x)Hourglasses[iteration]
#		  $t5 is the iteration count * 4
undrawHourglassOnScreen:
		add $t6, $s0, $t5	# t6 is memory address of lv(x)Hourglasses[iteration]
		lw $t7, 0($t6)	# t7 = location of lv(x)Hourglasses[iteration] on game screen
		
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

drawHeartPickups:
		# INITIALIZE REGISTERS FOR DRAWING HEARTS LOOP
		lb $t4, curNumHearts	# t4 = number of total heart pickups to draw * 4
		li $t5, 0	# t5 = number of heart pickups drawn * 4
		lw $s0, curHeartsAddr	# s0 = memory address of array lv(x)Hearts
		lw $s1, curHeartsAliveAddr	# s1 = memory address of array lv(x)HeartsAlive
		
		j drawHeartsLoop

drawHeartsLoop:
		bge $t5, $t4, drawPlatforms		# start drawing platforms next if loop finishes
		
		# CHECK IF HEART IS STILL ALIVE (not picked up yet)
		add $t6, $s1, $t5	# t6 is memory address of lv(x)HeartsAlive[iteration]
		lw $t7, 0($t6)	# t7 = whether or not heart is still alive
		beqz $t7, drawHeartsIterEnd	# if heart is not alive, skip checking player dist and drawing
		
		# CHECK IF PLAYER DOESN'T NEED HEART (player health == 3)
		li $t7, 3
		lb $t8, playerHealth
		beq $t8, $t7, drawHeartOnScreen		# if player doesn't need heart, draw it and ignore checking

		# CHECK IF PLAYER IS NEAR HEART
		add $t6, $s0, $t5	# t6 is memory address of lv(x)Hearts[iteration]
		lw $t7, 0($t6)	# t7 = location of lv(x)Hearts[iteration] on game screen
		
		li $t8, 16
		add $t8, $t8, $t0
		bge $t8, $t7, checkPlayerTouchHeart		# if player loc + 16 >= heart loc, 
										# player may be touching heart
		
		# CHECK ONE ROW ABOVE HEART LOC (detect one more row)
		addi $t7, $t7, -256
		bge $t8, $t7, checkPlayerTouchHeart		# if player loc + 16 >= heart loc + one row, 
										# player may be touching heart
		
		# ELSE, DRAW HEART
		j drawHeartOnScreen
		
checkPlayerTouchHeart:
		# Assume $t7 set to location of lv(x)Hearts[iteration] from previous branch
		li $t8, 16
		add $t8, $t8, $t7
		bge $t8, $t0, pickUpHeart		# if heart loc + 16 >= player loc AND
								# player loc + 16 >= heart loc, player IS touching heart
		
		# IF PLAYER ISN'T TOUCHING HEART, DRAW
		j drawHeartOnScreen
		
pickUpHeart:
		# SET HEARTALIVE[iteration] TO 0
		add $t6, $s1, $t5	# t6 is memory address of lv(x)HeartsAlive[iteration]
		sw $zero, 0($t6)	
		
		# INCREMENT PLAYER HEALTH
		lb $t8, playerHealth
		addi $t8, $t8, 1
		sb $t8, playerHealth
		
		# UNDRAW HEART
		jal undrawHeartOnScreen
		
		j drawHeartsIterEnd		# end of iteration (no need to draw heart, since it's been picked up)

drawHeartOnScreen:
		add $t6, $s0, $t5	# t6 is memory address of lv(x)Hearts[iteration]
		lw $t7, 0($t6)	# t7 = location of lv(x)Hearts[iteration] on game screen
		
		# heart
		li $t1, RED
		sw $t1, 4($t7)
		sw $t1, -256($t7)
		sw $t1, -252($t7)
		sw $t1, -248($t7)
		sw $t1, -512($t7)
		sw $t1, -504($t7)
		
		j drawHeartsIterEnd
				
drawHeartsIterEnd:
		addi $t5, $t5, 4	# increment # hearts handled * 4
		j drawHeartsLoop
		
# PREREQ: $s0 is the memory address of lv(x)Hearts[iteration]
#		  $t5 is the iteration count * 4
undrawHeartOnScreen:
		add $t6, $s0, $t5	# t6 is memory address of lv(x)Hearts[iteration]
		lw $t7, 0($t6)	# t7 = location of lv(x)Hearts[iteration] on game screen
		
		li $t1, 0x0	# black
		
		# heart
		sw $t1, 4($t7)
		sw $t1, -256($t7)
		sw $t1, -252($t7)
		sw $t1, -248($t7)
		sw $t1, -512($t7)
		sw $t1, -504($t7)
		
		jr $ra

# PREREQ: none of the platforms are 6 or more units from the rightmost part of the screen
# 		  nor 2 or more units from the bottom of the screen
drawPlatforms:
		# INITIALIZE REGISTERS FOR DRAWING PLATFORM LOOP
		lw $t8, curPlatformsAddr	# t8 = memory address of array lv(x)Platforms
		lb $t4, curNumPlatforms	# t4 = number of total platforms to draw * 4
		li $t5, 0	# t5 = number of platforms drawn * 4
		
		j drawPlatformsLoop

drawPlatformsLoop:
		bge $t5, $t4, movePlatformsUD	# start moving platforms (up-down) next if loop finishes
		
		add $t6, $t8, $t5	# t6 is memory address of lv(x)Platforms[iteration]
		lw $t7, 0($t6)	# t7 = location of lv(x)Platforms[iteration] on game screen
		
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
		# IF GAME TICK NOT DIVISIBLE BY PLATFORM MOVE FREQUENCY, 
		# SKIP PLATFORM MOVING LOGIC AND DRAW MOVING PLATFORMS
		lb $t6, platformMoveFrequency
		div $t9, $t6
		mfhi $t7
		bnez $t7, drawPlatformsUD
		
		# INITIALIZE REGISTERS FOR HANDLING MOVING LOGIC (up-down)
		lb $t4, curNumMovePlatformsUD	# t4 = number of total platforms to handle * 4
		li $t5, 0	# t5 = number of platforms handled * 4
		
		lw $s0, curMovePlatformsUDAddr	# s0 = memory address of array lv(x)MovePlatformsUD
		lw $s1, curMovePlatformsUDProgAddr	# s1 = address of array lv(x)MovePlatformsUDProg
		lw $s2, curMovePlatformsUDStateAddr		#s2 = address of array lv(x)MovePlatformsUDState
		
		j movePlatformsUDLoop

movePlatformsUDLoop:
		bge $t5, $t4, drawPlatformsUD	# draw moving platforms next if handling moving is finished

		# AVAILABLE REGISTERS: t6, t7, t8
		
		# GET STATE OF PLATFORM (0 = lowering, 1 = raising, 2+ = waiting)
		add $t6, $s2, $t5	# t6 is memory address of lv(x)MovePlatformsUDState[iteration]
		lw $a0, 0($t6)	# a0 = STATE of platform lv(x)MovePlatformsUD[iteration]
		
		# GET PROG OF PLATFORM (0 to 5)
		add $t6, $s1, $t5	# t6 is memory address of lv(x)MovePlatformsUDProg[iteration]
		lw $a1, 0($t6)	# a1 = PROG of platform lv(x)MovePlatformsUD[iteration]
		
		beqz $a0, handleLowerPlatform	# if state == 0, handle lowering platform
		
		li $t7, 1
		beq $a0, $t7, handleRaisePlatform	# if state == 1, handle raising platform
		
		li $t7, 4
		beq $a0, $t7, handleContinuePlatformUD	# if state == 4, handle 
							# continuing to move platform (DONE WAITING)
		
		# OTHERWISE, 2 <= STATE < 4 (continue waiting)
		addi $a0, $a0, 1	# increment state
		add $t6, $s2, $t5	# t6 is memory address of lv(x)MovePlatformsUDState[iteration]
		sw $a0, 0($t6)	# store waiting state back into lv(x)MovePlatformsUDState[iteration]
		
		j movePlatformsUDIterEnd	# end of iteration

handleLowerPlatform:
		beqz $a1, handleDoneMovingPlatformUD	# if platform prog == 0, platform is done lowering
		
		# O/W PLATFORM IS STILL LOWERING
		add $t6, $s1, $t5	# t6 is memory address of lv(x)MovePlatformsUDProg[iteration]
		
		add $t7, $s0, $t5	# t7 is the memory address of lv(x)MovePlatformsUD[iteration]
		lw $a2, 0($t7)	# a2 is the location of lv(x)MovePlatformsUD[iteration] on the screen
		jal undrawPlatformUD	# undraw platform at old prog $a1, given platform at $a2
		
		addi $a1, $a1, -1		# decrement prog
		sw $a1, 0($t6)	# store decremented prog back into lv(x)MovePlatformsUDProg[iteration]
		
		j movePlatformsUDIterEnd	# end of iteration
		
handleRaisePlatform:
		li $t6, 5	# since progress is 0 to 5
		beq $a1, $t6, handleDoneMovingPlatformUD		# if platform prog == 5, platform is done raising
		
		# O/W PLATFORM IS STILL RAISING
		add $t6, $s1, $t5	# t6 is memory address of lv(x)MovePlatformsUDProg[iteration]
		
		add $t7, $s0, $t5	# t7 is the memory address of lv(x)MovePlatformsUD[iteration]
		lw $a2, 0($t7)	# a2 is the location of lv(x)MovePlatformsUD[iteration] on the screen
		jal undrawPlatformUD	# undraw platform at old prog $a1, given platform at $a2
		
		addi $a1, $a1, 1		# increment prog
		sw $a1, 0($t6)	# store incremented prog back into lv(x)MovePlatformsUDProg[iteration]
		
		j movePlatformsUDIterEnd	# end of iteration
		
handleDoneMovingPlatformUD:
		add $t6, $s2, $t5	# t6 is memory address of lv(x)MovePlatformsUDState[iteration]
		li $t7, 2	# t7 = waiting state (2)
		sw $t7, 0($t6)	# store waiting state back into lv(x)MovePlatformsUDState[iteration]
		
		j movePlatformsUDIterEnd	# end of iteration

handleContinuePlatformUD:
		beqz $a1, startRaising		# if prog == 0, then platform just finished lowering (should start raising)
		
		# O/W, PLATFORM SHOULD START LOWERING
		add $t6, $s2, $t5	# t6 is memory address of lv(x)MovePlatformsUDState[iteration]
		sw $zero, 0($t6)		# store lowering state (0) back into lv(x)MovePlatformsUDState[iteration]
		
		j movePlatformsUDIterEnd	# end of iteration
startRaising:
		# PLATFORM SHOULD START RAISING
		add $t6, $s2, $t5	# t6 is memory address of lv(x)MovePlatformsUDState[iteration]
		li $t7, 1	# t7 = raising state (1)
		sw $t7, 0($t6)	# store raising state back into lv(x)MovePlatformsUDState[iteration]
		
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
		lb $t4, curNumMovePlatformsUD	# t4 = number of total UD platforms to draw * 4
		li $t5, 0	# t5 = number of platforms drawn * 4
		lw $s0, curMovePlatformsUDAddr	# s0 = memory address of array lv(x)MovePlatformsUD
		lw $s1, curMovePlatformsUDProgAddr
		
		j drawPlatformsUDLoop
		
drawPlatformsUDLoop:
		bge $t5, $t4, movePlatformsLR	# once up-down platforms are done, start handling LEFT-RIGHT PLATFORMS
		
		# AVAILABLE REGISTERS: (t1), t6, t7, t8
		
		# GET VERTICAL OFFSET FROM PROG
		add $t6, $s1, $t5	# t6 is memory address of lv(x)MovePlatformsUDProg[iteration]
		lw $t7, 0($t6)	# t7 = vertical offset of platform lv(x)MovePlatforms[iteration]
		li $t8, 256
		mult $t7, $t8
		mflo $t6	# t6 = vertical offset (0-5) * 256
		
		# GET NEW PLATFORM LOCATION wrt. OFFSET GIVEN BY PROG
		add $t7, $s0, $t5	# t7 is memory address of lv(x)MovePlatformsUD[iteration]
		lw $t8, 0($t7)	# t8 = location of lv(x)MovePlatformsUD[iteration] on game screen
		
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
		# IF GAME TICK NOT DIVISIBLE BY PLATFORM MOVE FREQUENCY, 
		# SKIP PLATFORM MOVING LOGIC AND DRAW MOVING PLATFORMS
		lb $t6, platformMoveFrequency
		div $t9, $t6
		mfhi $t7
		bnez $t7, drawPlatformsLR
		
		# INITIALIZE REGISTERS FOR HANDLING MOVING LOGIC (left-right)
		lb $t4, curNumMovePlatformsLR	# t4 = number of total platforms to handle * 4
		li $t5, 0	# t5 = number of platforms handled * 4
		
		lw $s0, curMovePlatformsLRAddr	# s0 = memory address of array lv(x)MovePlatformsLR
		lw $s1, curMovePlatformsLRProgAddr	# s1 = address of array lv(x)MovePlatformsLRProg
		lw $s2, curMovePlatformsLRStateAddr		#s2 = address of array lv(x)MovePlatformsLRState
		
		j movePlatformsLRLoop

movePlatformsLRLoop:
		bge $t5, $t4, drawPlatformsLR	# draw moving platforms next if handling moving is finished

		# AVAILABLE REGISTERS: t6, t7, t8
		
		# GET STATE OF PLATFORM (0 = moving left, 1 = moving right, 2+ = waiting)
		add $t6, $s2, $t5	# t6 is memory address of lv(x)MovePlatformsLRState[iteration]
		lw $a0, 0($t6)	# a0 = STATE of platform lv(x)MovePlatformsLR[iteration]
		
		# GET PROG OF PLATFORM (0 to 7)
		add $t6, $s1, $t5	# t6 is memory address of lv(x)MovePlatformsLRProg[iteration]
		lw $a1, 0($t6)	# a1 = PROG of platform lv(x)MovePlatformsLR[iteration]
		
		beqz $a0, handleLeftPlatform	# if state == 0, handle moving platform left
		
		li $t7, 1
		beq $a0, $t7, handleRightPlatform	# if state == 1, handle moving platform right
		
		li $t7, 4
		beq $a0, $t7, handleContinuePlatformLR	# if state == 4, handle 
							# continuing to move platform (DONE WAITING)
		
		# OTHERWISE, 2 <= STATE < 4 (continue waiting)
		addi $a0, $a0, 1	# increment state
		add $t6, $s2, $t5	# t6 is memory address of lv(x)MovePlatformsLRState[iteration]
		sw $a0, 0($t6)	# store waiting state back into lv(x)MovePlatformsLRState[iteration]
		
		j movePlatformsLRIterEnd	# end of iteration

handleLeftPlatform:
		beqz $a1, handleDoneMovingPlatformLR	# if platform prog == 0, platform is done moving left
		
		# O/W PLATFORM IS STILL MOVING LEFT
		add $t6, $s1, $t5	# t6 is memory address of lv(x)MovePlatformsLRProg[iteration]
		
		add $t7, $s0, $t5	# t7 is the memory address of lv(x)MovePlatformsLR[iteration]
		lw $a2, 0($t7)	# a2 is the location of lv(x)MovePlatformsLR[iteration] on the screen
		jal undrawPlatformLR	# undraw platform at old prog $a1, given platform at $a2
		
		addi $a1, $a1, -1		# decrement prog
		sw $a1, 0($t6)	# store decremented prog back into lv(x)MovePlatformsLRProg[iteration]
		
		j movePlatformsLRIterEnd	# end of iteration
		
handleRightPlatform:
		li $t6, 7	# since progress is 0 to 7
		beq $a1, $t6, handleDoneMovingPlatformLR		# if platform prog == 7, platform is done moving right
		
		# O/W PLATFORM IS STILL MOVING RIGHT
		add $t6, $s1, $t5	# t6 is memory address of lv(x)MovePlatformsLRProg[iteration]
		
		add $t7, $s0, $t5	# t7 is the memory address of lv(x)MovePlatformsLR[iteration]
		lw $a2, 0($t7)	# a2 is the location of lv(x)MovePlatformsLR[iteration] on the screen
		jal undrawPlatformLR	# undraw platform at old prog $a1, given platform at $a2
		
		addi $a1, $a1, 1		# increment prog
		sw $a1, 0($t6)	# store incremented prog back into lv(x)MovePlatformsLRProg[iteration]
		
		j movePlatformsLRIterEnd	# end of iteration
		
handleDoneMovingPlatformLR:
		add $t6, $s2, $t5	# t6 is memory address of lv(x)MovePlatformsLRState[iteration]
		li $t7, 2	# t7 = waiting state (2)
		sw $t7, 0($t6)	# store waiting state back into lv(x)MovePlatformsLRState[iteration]
		
		j movePlatformsLRIterEnd	# end of iteration

handleContinuePlatformLR:
		beqz $a1, startMovingRight		# if prog == 0, then platform just finished going left (should start going right)
		
		# O/W, PLATFORM SHOULD START GOING LEFT
		add $t6, $s2, $t5	# t6 is memory address of lv(x)MovePlatformsLRState[iteration]
		sw $zero, 0($t6)		# store moving left state (0) back into lv(x)MovePlatformsLRState[iteration]
		
		j movePlatformsLRIterEnd	# end of iteration
startMovingRight:
		# PLATFORM SHOULD START MOVING RIGHT
		add $t6, $s2, $t5	# t6 is memory address of lv(x)MovePlatformsLRState[iteration]
		li $t7, 1	# t7 = moving right state (1)
		sw $t7, 0($t6)	# store moving right state back into lv(x)MovePlatformsLRState[iteration]
		
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
		lb $t4, curNumMovePlatformsLR	# t4 = number of total LR platforms to draw * 4
		li $t5, 0	# t5 = number of platforms drawn * 4
		lw $s0, curMovePlatformsLRAddr	# s0 = memory address of array lv(x)MovePlatformsLR
		lw $s1, curMovePlatformsLRProgAddr
		
		j drawPlatformsLRLoop
		
drawPlatformsLRLoop:
		bge $t5, $t4, drawPlayer	# once left-right platforms are done, start drawing player
		
		# AVAILABLE REGISTERS: (t1), t6, t7, t8
		
		# GET HORIZONTAL OFFSET FROM PROG
		add $t6, $s1, $t5	# t6 is memory address of lv(x)MovePlatformsLRProg[iteration]
		lw $t7, 0($t6)	# t7 = horizontal offset of platform lv(x)MovePlatformsLR[iteration]
		li $t8, 4
		mult $t7, $t8
		mflo $t6	# t6 = horizontal offset (0-5) * 4
		
		# GET NEW PLATFORM LOCATION wrt. OFFSET GIVEN BY PROG
		add $t7, $s0, $t5	# t7 is memory address of lv(x)MovePlatformsLR[iteration]
		lw $t8, 0($t7)	# t8 = location of lv(x)MovePlatformsLR[iteration] on game screen
		
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
		# IF HOURGLASS IN EFFECT, DRAW PLAYER GRAYSCALE
		lb $t4, hourglassInEffect
		li $t5, 1
		beq $t4, $t5, drawPlayerGrayscale
		
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
		
		li $t1, 0xf8c87b	# face
		sw $t1, -1532($t0)
		sw $t1, -1528($t0)
		sw $t1, -1784($t0)
		
		# IF FEATHER IN EFFECT, DRAW PLAYER HAIR WHITE
		lb $t4, featherInEffect
		li $t5, 1
		beq $t4, $t5, drawPlayerHairWhite
		
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
		
		j drawHeartsUI	# draw hearts UI after
		
drawPlayerGrayscale:
		# DRAW GRAYSCALE AVATAR (width 5 x height 9)
		li $t1, 0x6a6a6a # dark gray
		sw $t1, -260($t0)	# dress outline and lined pattern
		sw $t1, -256($t0)
		sw $t1, -252($t0)
		sw $t1, -248($t0)
		sw $t1, -244($t0)
		sw $t1, -500($t0)
		sw $t1, -1024($t0)
		sw $t1, -1020($t0)
		sw $t1, -1016($t0)
		
		li $t1, WHITE
		sw $t1, 0($t0)	# shoes
		sw $t1, 8($t0)
		
		li $t1, 0x959595	# light gray
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
		
		li $t1, WHITE
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
		
		li $t1, 0xd0d0d0
		sw $t1, -1532($t0)	# face
		sw $t1, -1528($t0)
		sw $t1, -1784($t0)
		
		j drawHeartsUI	# draw hearts UI after
		
drawPlayerHairWhite:
		li $t1, WHITE
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
		
		j drawHeartsUI

drawHeartsUI:
		# INITIALIZE REGISTERS TO DRAW HEARTS
		lb $t4, playerHealth	# t4 = player health (0 to 3)
		li $t5, 0	# number of hearts drawn
		
		# SET T6 TO FIRST HEART DRAWING LOCATION
		li $t6, BASE_ADDRESS
		addi $t6, $t6, 520	# first heart UI location = base address + 2 units down + 2 units right
		
		j drawHeartsUILoop

drawHeartsUILoop:
		li $t7, 3
		bge $t5, $t7, drawLevelNumber	# if 3 UI hearts have been drawn, draw level # UI
		bge $t5, $t4, drawEmptyHeartUI	# if number of hearts drawn >= player health, draw empty heart
		
		# DRAW HEART UI
		li $t1, RED
		sw $t1, 4($t6)
		sw $t1, 12($t6)
		sw $t1, 256($t6)
		sw $t1, 260($t6)
		sw $t1, 264($t6)
		sw $t1, 272($t6)
		sw $t1, 516($t6)
		sw $t1, 520($t6)
		sw $t1, 524($t6)
		sw $t1, 776($t6)
		li $t1, WHITE
		sw $t1, 268($t6)
		
		j drawHeartsUIIterEnd

drawEmptyHeartUI:
		# DRAW EMPTY HEART UI
		li $t1, DARKGRAY
		sw $t1, 4($t6)
		sw $t1, 12($t6)
		sw $t1, 256($t6)
		sw $t1, 260($t6)
		sw $t1, 264($t6)
		sw $t1, 268($t6)
		sw $t1, 272($t6)
		sw $t1, 516($t6)
		sw $t1, 520($t6)
		sw $t1, 524($t6)
		sw $t1, 776($t6)
		
		j drawHeartsUIIterEnd
		
drawHeartsUIIterEnd:
		addi $t6, $t6, 24		# move next heart UI location 7 units to the right
		addi $t5, $t5, 1	# increment UI hearts drawn
		j drawHeartsUILoop
		
drawLevelNumber:
		# DRAW LEVEL NUMBER (1, 2, 3) IN TOP RIGHT CORNER
		li $t4, BASE_ADDRESS
		addi $t4, $t4, 756
		li $t1, WHITE
		
		lb $t5, currentLv		# t5 = current level (1-3)
		li $t6, 3
		beq $t5, $t6, drawLevel3Ind
		
		li $t6, 2
		beq $t5, $t6, drawLevel2Ind
		
		# OTHERWISE, DRAW LEVEL 1 INDICATOR
		sw $t1, -4($t4)
		sw $t1, 252($t4)
		sw $t1, 248($t4)
		sw $t1, 508($t4)
		sw $t1, 764($t4)
		sw $t1, 1020($t4)
		sw $t1, 1016($t4)
		sw $t1, 1024($t4)
		
		j SLEEP
drawLevel2Ind:
		sw $t1, 0($t4)
		sw $t1, -4($t4)
		sw $t1, -8($t4)
		sw $t1, 256($t4)
		sw $t1, 512($t4)
		sw $t1, 508($t4)
		sw $t1, 504($t4)
		sw $t1, 760($t4)
		sw $t1, 1016($t4)
		sw $t1, 1020($t4)
		sw $t1, 1024($t4)
		
		j SLEEP
drawLevel3Ind:
		sw $t1, 0($t4)
		sw $t1, -4($t4)
		sw $t1, -8($t4)
		sw $t1, 256($t4)
		sw $t1, 512($t4)
		sw $t1, 508($t4)
		sw $t1, 504($t4)
		sw $t1, 768($t4)
		sw $t1, 1024($t4)
		sw $t1, 1020($t4)
		sw $t1, 1016($t4)
		
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
		li $a0, 30	# Wait 30ms
		syscall
		
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
