	.data
		kb_buf_size:	.word  0
		kb_buf:		.space 1000

		score:			.asciiz "Score: "
		new_line:		.asciiz "\n"
		border:			.asciiz "#"
		player:			.asciiz "P"
		reward:			.asciiz "R"
		both_players:		.asciiz "X"
		other_player:		.asciiz "E"
		empty:			.asciiz " "
		S:			.asciiz "S"
		s:			.asciiz "s"
		c:			.asciiz "c"
		o:			.asciiz "o"
		r:			.asciiz "r"
		e:			.asciiz "e"
		sign:			.asciiz ":"
		W:			.asciiz "W"
		i:			.asciiz "i"
		n:			.asciiz "n"
		eks:			.asciiz "!"
		l:			.asciiz "l"
		a:			.asciiz "a"
		y:			.asciiz "y"
		n1:			.asciiz "1"
		n2:			.asciiz "2"
		

	.text
	
	li $s0, 0		#s0 = PlayerPositionI
	li $s1, 0		#s1 = PlayerPositionJ
	li $s2, 0		#s2 = RewardPositionI
	li $s3, 0		#s3 = RewardPositionJ
	li $s4, 0		#PlayerPoint = 0
	li $s5, 0		#s5 = OtherPlayerPositionI
	li $s6, 0		#s6 = OtherPlayerPositionJ
	li $s7, 0		#OtherPlayerPoint = 0
	#Didint have to declear a;ll of them as 0, just needed for documantaion and to remember which register is
	#declear as what position of the player on the axis
	
	again3:
	#Generating a random number for PlayerPositionI
	jal generateRandomI
	add $s0, $a0, 0
	beq $s0, $zero, again3		#If the number is 0 goto again3
	
	again4:
	#Generating a random number for PlayerPositionJ
	jal generateRandomJ
	add $s1, $a0, 0
	beq $s1, $zero, again4		#If the number is 0 goto again4
	
	again5:
	#Generating a random number for OtherPlayerPositionI
	jal generateRandomI
	add $s5, $a0, 0
	beq $s5, $s0, again5		#If OtherPlayerPositionI == PlayerPositionI, goto again5
	beq $s5, $zero, again5		#If OtherPlayerPositionI == 0, goto again5
	
	again6:
	#Generating a random number for OtherPlayerPositionJ
	jal generateRandomJ
	add $s6, $a0, 0
	beq $s6, $s1, again6		#If OtherPlayerPositionJ == PlayerPositionJ, goto again6
	beq $s6, $zero, again6		#If OtherPlayerPositionJ == 0, goto again5
	
	again1:
	#Generating a random number for RewardPositionI
	jal generateRandomI
	add $s2, $a0, 0
	beq $s0, $s2, again1		#If PlayerPositionI == RewardPositionI, goto again1
	beq $s5, $s2, again1		#If OtherPlayerPositionI == RewardPositionI, goto again1
	beq $s2, $zero, again1		#If the number is 0 goto again1
	
	again2:
	#Generating a random number for RewardPositionJ
	jal generateRandomJ
	add $s3, $a0, 0
	beq $s1, $s3, again2		#If PlayerPosition J == RewardPositionJ, goto again2
	beq $s6, $s3, again2		#If OtherPlayerPositionJ == RewardPositionJ, goto again2
	beq $s3, $zero, again2		#If the number is 0 goto again2
	
	li $t0, 0 		#i = 0
	li $t1, 0		#j = 0
	li $t2, 9		#t2 = 9 , used for the "for loop" for horizontal width of game
	li $t3, 7		#t3 = 7 , we need this to compare it to t0,t1 to print the border
	
	jal printScore
	jal printBoard
	j main
	
####################################################################################
	# poll for keyboard input
poll:
	li	$t4, 0xffff0000		# keyboard control register
	lw	$t5, ($t4)		# read keyboard control register
	andi	$t5, $t5, 1		# check data bit
	beq	$t5, $zero, exit	# if not ready, exit
	
	#pull data from keyboard, dispaly adn store in buffer
	#lw	$t3, 4($t0)
	
	# pull data from keyboard and store in buffer
	lw	$t7, 4($t4)		# load current character from kb data
	la	$t5, kb_buf		# load address of buffer
	lw	$t6, kb_buf_size	# current size of buffer
	add	$t5, $t5, $t6		# move buffer pointer to next free spot
	sb	$t7, 0($t5)		# store byte (sb) character into buffer
	
	# update buffer metadata
	add	$t6, $t6, 1		# increment buffer size
	sw	$t6, kb_buf_size	# push new size back to memory
	
	#Checking for W movment
	li $t8, 0x77			#w
	bne $t7, $t8, check_s_move	#If $t7 != "w", goto check_s_move
	add $s0, $s0, -1		#$s0 -= 1
	
	#Checking for S movment
	check_s_move:
	li $t8, 0x73			#s
	bne $t7, $t8, check_a_move	#If $t7 != "s", goto check_a_move
	add $s0, $s0, 1			#s0 += 1
	
	#Checking for A movment
	check_a_move:
	li $t8, 0x61			#a
	bne $t7, $t8, check_d_move	#If $t7 != "a", goto check_d_move
	add $s1, $s1, -1		#s1 -= 1
	
	#Checking for D movment
	check_d_move:
	li $t8, 0x64			#d
	bne $t7, $t8, check_i_move	#If $t7 != "d", goto check_i_move
	add $s1, $s1, 1			#s1 += 1
	
	#Checking for I movment
	check_i_move:
	li $t8, 0x69			#i
	bne $t7, $t8, check_j_move	#If t7 != "i", goto check_j_move
	add $s5, $s5 -1			#s5 -= 1	
	
	#Checking for J movment
	check_j_move:
	li $t8, 0x6A			#j
	bne $t7, $t8, check_k_move	#If t7 != "j", goto check_k_move
	add $s6, $s6, -1		#s6 -= 1
	
	#Cheking for K movment
	check_k_move:
	li $t8, 0x6B			#k
	bne $t7, $t8, check_l_move	#If t7 != "k", goto check_l_move
	add $s5, $s5, 1			#s5 += 1
	
	#Checking for L movment
	check_l_move:
	li $t8, 0x6C			#l
	bne $t7, $t8, almost_finito	#If t7 != l, goto almost_finito
	add $s6, $s6, 1			#s6 += 1
	
	
	almost_finito:
	jal printScore
	jal printBoard
exit:
	j loop
	
	
####################################################################################
	# entry point
main:
	li	$t4, 0xffff0000		# kb control register
	li	$t5, 0			#]
	sw	$t5, ($t4)		#] clear interrupt-enable bit
	
loop:
	andi	$t5, $t5, 1		# check data bit
	beq	$t5, $zero, keepWaiting	# if there isnt an input goto keepWaiting
	jal checkRewardCollectedWASD
	jal checkRewardCollectedIJKL
	jal checkWinWASD
	jal checkWinIJKL
	jal printScore
	jal printBoard
	jal checkCollision
	
	keepWaiting:
	jal checkRewardCollectedWASD
	jal checkRewardCollectedIJKL
	jal checkWinWASD
	jal checkWinIJKL
	jal checkCollision
	j	poll
	
	
	
	
	
printBoard:
	li $t0, 0		#Setting the i to 0, redundency reasons
	li $t1, 0		#Setting the j to 0, redundency reasons
    	
	loop2:
		bgt $t0, $t3, i_equals_7		#Goto end_outer_loop if $t0 > 7
		bgt $t1, $t2, j_equals_9		#Goto end_inner_loop if $t1 > 9

		
		
		beq $t0, $zero, print_border_i 		#if(i == 0) goto print_border_i
		beq $t0, $t3, print_border_i 		#if(i == 6) goto print_border_i
		#If i != 0 or i != 6
		j try_printing_border_j			#Goto try_printing_border_j
			
		print_border_i:		#X axis border
		la $a0, border
		lbu $t6, ($a0)       # load byte from address in $a0
		beqz $t6, try_printing_border_j # if byte is 0, jump to try_printing_border_j
		sb $t6, ($t5)        # store byte in Display device
    		addi $a0, $a0, 1     # increment address in $a0
		
		j incrementing_j			#Goto incrementing, after printing we want it to increment
			
			
		
		try_printing_border_j:
		beq $t1, $zero, print_border_j 		#if(j == 0) goto print_border_j
		beq $t1, $t2, print_border_j		#if(j == 9) goto print_border_j
		#If j != 0 or j != 8
		j try_printing_player
			
		print_border_j:
		la $a0, border
		lbu $t6, ($a0)       # load byte from address in $a0
		beqz $t6, both_players_same_square # if byte is 0, jump to try_printing_reward_position
		sb $t6, ($t5)        # store byte in Display device
    		addi $a0, $a0, 1     # increment address in $a0
		j incrementing_j			#Goto incrementing, after printing we want it to increment
			
			
			
		both_players_same_square:
		bne $s0, $s5, try_printing_player	#If P1PositionI != P2PositionI, goto try_printing_player
		bne $s1, $s6, try_printing_player	#If P1PositionJ != P2PositionJ, goto try_printing_player
		#Else do this
		la $a0, both_players
		lbu $t6, ($a0)       # load byte from address in $a0
		beqz $t6, try_printing_player # if byte is 0, jump to try_printing_player
		sb $t6, ($t5)        # store byte in Display device
    		addi $a0, $a0, 1     # increment address in $a0
		j incrementing_j
			
			
			
			
		try_printing_player:
		bne $t0, $s0, try_printing_other_player	#if(i != PlayerPositionI) goto try_printing_reward_position
		beq $t1, $s1, print_player		#if(j == PlayerPositionJ) goto print_player
		#If i == PlayerPositionI AND j == PlayerPositionJ goto print_player
		#If above false goto try_Printing_other_player
		j try_printing_other_player
			
		print_player:
		la $a0, player
		lbu $t6, ($a0)       # load byte from address in $a0
		beqz $t6, try_printing_reward_position # if byte is 0, jump to try_printing_reward_position
		sb $t6, ($t5)        # store byte in Display device
    		addi $a0, $a0, 1     # increment address in $a0
		
		j incrementing_j			#Goto end_inner_loop
			
		
		
		
		try_printing_other_player:
		bne $t0, $s5, try_printing_reward_position	#If i != OtherPlayerPositionI goto try_printing_reward_position
		beq $t1, $s6, print_other_player		#If j == OtherPlayerPositionJ goto print_other_player
		#If above false, goto try_printing_reward_position
		j try_printing_reward_position
		
		print_other_player:
		la $a0, other_player
		lbu $t6, ($a0)       # load byte from address in $a0
		beqz $t6, try_printing_reward_position # if byte is 0, jump to try_printing_reward_position
		sb $t6, ($t5)        # store byte in Display device
    		addi $a0, $a0, 1     # increment address in $a0
		
		j incrementing_j			#Goto end_inner_loop
			
			
			
			
			
		try_printing_reward_position:
		bne $t0, $s2, print_empty	#If(i != RewardPositionI) goto print_empty
		beq $t1, $s3, print_reward		#If(j == RewardPositionJ) goto print reward
		#If i == RewardPositionI AND j == RewardPositionJ goto print_reward
		#If (i != RewardPositionI AND j != RewardPositionJ) goto try_printing_player
		#If above false goto print_empty
		j print_empty
			
		print_reward:
		la $a0, reward
		lbu $t6, ($a0)       # load byte from address in $a0
		beqz $t6, incrementing_j # if byte is 0, jump to incrementing_j
		sb $t6, ($t5)        # store byte in Display device
    		addi $a0, $a0, 1     # increment address in $a0
		
		j incrementing_j			#Goto incrementing, after printing we want it to increment
			
			
		print_empty:
		#If Nothing above is printed that means we need to print empty space
		la $a0, empty
		lbu $t6, ($a0)       # load byte from address in $a0
		beqz $t6, incrementing_j # if byte is 0, jump to incrementing_j
		sb $t6, ($t5)        # store byte in Display device
    		addi $a0, $a0, 1     # increment address in $a0
			
		incrementing_j:
		add $t1, $t1, 1				#t1 += 1
		j loop2
		
	end_inner_loop:
	j loop2

j_equals_9:
	li $t1, 0
	la $a0, new_line
	lbu $t6, ($a0)       # load byte from address in $a0
	beqz $t6, loop 	# if byte is 0, jump to loop
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
	add $t0, $t0, 1
	j loop2
	
i_equals_7:
	jr $ra
	
	
	
	
generateRandomI:
	li $a1, 7  #Here you set $a1 to the max bound.
	li $v0, 42  #generates the random number.
    	syscall
    	add $a0, $a0, 1  #Here you add the lowest bound
    	syscall
	jr $ra
	
	#We need 2functions because X axis has 9 squares, while the Y has 7





generateRandomJ:
	li $a1, 5  #Here you set $a1 to the max bound.
	li $v0, 42  #generates the random number.
    	syscall
    	add $a0, $a0, 1  #Here you add the lowest bound
    	syscall
	jr $ra
	
	
	
	
	
checkRewardCollectedWASD:
	bne $s0, $s2, forward1
	bne $s1, $s3, forward1
	#If playerI == rewardI AND playerJ == rewardJ then do this, else goto forward
	add $s4, $s4, 1			#If the player colected the reward, reward += 10
		
	tryAgain1:
	li $a1, 7  #Here you set $a1 to the max bound.
	li $v0, 42  #generates the random number.
    	syscall
    	add $a0, $a0, 1  #Here you add the lowest bound
    	syscall
	add $s2, $a0, 0
		
	tryAgain2:
	li $a1, 5  #Here you set $a1 to the max bound.
	li $v0, 42  #generates the random number.
    	syscall
    	add $a0, $a0, 1  #Here you add the lowest bound
    	syscall
	add $s3, $a0, 0
		
	beq $s1, $s3, tryAgain1
	beq $s2, $zero, tryAgain1
	beq $s3, $zero, tryAgain2
	#If playerI == rewardI AND playerJ == rewardJ then goto tryAgain1 ELSE goto forward
		
		
		
	forward1:
	jr $ra
	

checkRewardCollectedIJKL:
	bne $s5, $s2, forward2
	bne $s6, $s3, forward2
	#If playerI == rewardI AND playerJ == rewardJ then do this, else goto forward
	add $s7, $s7, 1			#If the player colected the reward, reward += 10
		
	tryAgain11:
	li $a1, 7  #Here you set $a1 to the max bound.
	li $v0, 42  #generates the random number.
    	syscall
    	add $a0, $a0, 1  #Here you add the lowest bound
    	syscall
	add $s2, $a0, 0
		
	tryAgain22:
	li $a1, 5  #Here you set $a1 to the max bound.
	li $v0, 42  #generates the random number.
    	syscall
    	add $a0, $a0, 1  #Here you add the lowest bound
    	syscall
	add $s3, $a0, 0
		
	beq $s1, $s3, tryAgain22
	beq $s0, $s2, tryAgain11
	beq $s2, $zero, tryAgain11
	beq $s3, $zero, tryAgain22
	beq $s2, $s5, tryAgain11
	beq $s3, $s6, tryAgain22
	#If playerI == rewardI AND playerJ == rewardJ then goto tryAgain1 ELSE goto forward
		
		
		
	forward2:
	jr $ra
	
	



checkCollision:
	beq $s0, $zero, player_wasd_lost
	beq $s0, $t3, player_wasd_lost
	beq $s1, $zero, player_wasd_lost
	beq $s1, $t2, player_wasd_lost
	beq $s5, $zero, player_ijkl_lost
	beq $s5, $t3, player_ijkl_lost
	beq $s6, $zero, player_ijkl_lost
	beq $s6, $t2, player_ijkl_lost
	#If any position of the player is in the wall goto wasd/ijkl_lost
	jr $ra
	
	
	
	
	
	
printScore:
	li $t5, 0xffff000c   # address of Display device in MARS
	li $t8, 0x0c
	sb $t8, ($t5)
	li $t9, 0
	
	nop
	nop
	nop
	
	#Under is printing "Score"
	
	la $a0, player
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, n1
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, empty
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0

	la $a0, S
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, c
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, o
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, r
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, e
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, sign
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, empty
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	nop
    	nop
    	nop
    	nop
    	nop
    	
    	addi $t9, $zero, 48   # Load ASCII value of '0' into $t1
	add $a3, $s4, $t9
	sb $a3, ($t5)
	
	nop
	nop
	nop
	nop
	nop
	
	li $a3, 48
	sb $a3, ($t5)
	
	nop
	nop
	nop
	nop
	nop
    	
    	la $a0, new_line
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, player
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, n2
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, empty
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0

	la $a0, S
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, c
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, o
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, r
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, e
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, sign
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, empty
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	nop
    	nop
    	nop
    	nop
    	nop
    	
    	addi $t9, $zero, 48   # Load ASCII value of '0' into $t1
	add $a3, $s7, $t9
	sb $a3, ($t5)
	
	nop
	nop
	nop
	nop
	nop
	
	li $a3, 48
	sb $a3, ($t5)
	
	nop
	nop
	nop
	nop
	nop
    	
    	la $a0, new_line
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	jr $ra
    	
    	
    	
    	
    	
    	
    	
checkWinWASD:
	blt $s4, 0xA, no_win1
	
	la $t5, 0xffff000c   # address of Display device in MARS
	
	li $t8, 0x0c	#Clear screen
	sb $t8, ($t5)
	
	nop
	nop
	nop
	
	#Under is printing "Winner"
	
	la $a0, player
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, n1
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, empty
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, W
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, i
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, n
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, s
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	
    	
    	li $v0, 10
    	syscall
    	
	no_win1:
	jr $ra
	
	
	
	
	
	
checkWinIJKL:
	blt $s7, 0xA, no_win2
	
	la $t5, 0xffff000c   # address of Display device in MARS
	
	li $t8, 0x0c	#Clear screen
	sb $t8, ($t5)
	
	nop
	nop
	nop
	
	#Under is printing "P2 Wins"
	
	la $a0, player
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, n2
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, empty
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, W
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, i
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, n
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, s
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	li $v0, 10
    	syscall
    	
	no_win2:
	jr $ra
	
	
	
	
	
	
	
	
player_wasd_lost:
	la $t5, 0xffff000c   # address of Display device in MARS
	
	li $t8, 0x0c	#Clear screen
	sb $t8, ($t5)
	
	nop
	nop
	nop
	
	la $a0, player
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, l
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, a
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, y
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, e
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, r
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, empty
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, n2
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, empty
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, W
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, o
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, n
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	nop
    	nop
    	nop
    	
    	li $v0, 10
    	syscall
	
	
player_ijkl_lost:
	la $t5, 0xffff000c   # address of Display device in MARS
	
	li $t8, 0x0c	#Clear screen
	sb $t8, ($t5)
	
	nop
	nop
	nop
	
	la $a0, player
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, l
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, a
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, y
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, e
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, r
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, empty
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, n1
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, empty
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, W
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, o
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	la $a0, n
	lbu $t6, ($a0)       # load byte from address in $a0
	sb $t6, ($t5)        # store byte in Display device
    	addi $a0, $a0, 1     # increment address in $a0
    	
    	nop
    	nop
    	nop
    	
    	li $v0, 10
    	syscall
