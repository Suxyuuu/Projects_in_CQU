.data 
	msg:	.asciiz "****************************\n"
	msg0:   .asciiz "please input the 1st float:"
	msg1:   .asciiz "please input the 2nd float:"
	msg2:	.asciiz "Result: "
	msg7:	.asciiz "*error* UP OVERFLOW\n"
	msg8:	.asciiz "*error* DOWN OVERFLOW\n"
	msg9:	.asciiz "**********The End**********"
	msg11:	.asciiz "\nBinary:"
	msg12:	.asciiz "\nHex:"
	msgerr: .asciiz "*error* divisor can't be 0! Please input again:\n"
	msgquit:.asciiz "\ninput '0' to quit, otherwise continue:\n"
.text
mainloop:	
	li	$v0,	4
	la	$a0,	msg
	syscall 
	jal	getInput		#进入输入模块
	jal	divide			#进入除法模块
	
	li	$v0,	5		#读取是否退出的输入
	syscall
	
	add	$t0,	$v0,	$zero
	beq   	$t0,	0,	doquit	#等于0则结束程序

	j mainloop
	
.text 
getInput:
	subu	$sp,	$sp,	32 	
	sw 	$ra,	20($sp)
	sw	$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw 	$a0,	0($fp)			#压栈
	
	li 	$v0,	4
	la 	$a0,	msg0
	syscall 
	li	$v0,	6
	syscall 
	mfc1 	$s0,	$f0 			#第一个数的读入与存储
	
	li 	$v0,	4
	la 	$a0,	msg1
	syscall
	li	$v0,	6
	syscall 
	mfc1 	$s1,	$f0 			#第二个数的读入与存储
	
	lw	$ra,	20($sp)
	lw 	$fp,	16($sp)
	addiu 	$sp,	$sp,	32
	jr	$ra
	
.text
divide:
	subu	$sp,	$sp,	32 
	sw 	$ra,	20($sp)
	sw	$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw 	$a0,	0($fp)				#压栈

	beq 	$s1,	$zero,	divideError		#判断除数是否为零
	beq 	$s0,	$zero,	divideExistZero		#判断被除数是否为零
	j 	divideStart				#跳转到除法模块

divideError: 
	li 	$v0,	4
	la 	$a0,	msgerr
	syscall  
	jal  mainloop



divideStart:
	srl 	$t2,	$s0,	31              	#  sign1-->t2
	srl 	$t3,	$s1,	31             		#  sign2-->t3

	sll 	$t4,	$s0,	1
	srl 	$t4,	$t4,	24  			# exp1-->t4
	sll 	$t5,	$s1,	1
	srl 	$t5,	$t5,	24  			# exp2-->t5

	sll 	$t6,	$s0,	9
	srl 	$t6,	$t6,	9               	#frac1
	ori 	$t6,	$t6,	0x00800000      	#显露隐含前导1后的frac1-->t6

	sll 	$t7,	$s1,	9
	srl 	$t7,	$t7,	9			#frac2
	ori 	$t7,	$t7,	0x00800000      	#显露隐含前导1后的frac2-->t7

	sub 	$t4,	$t4,	$t5   			
	addi 	$t4,	$t4,	127			#final exp-->t4=t4-t5+127
	sub 	$t5,	$t5,	$t5			#t5清零

divideCompareSign:
	add 	$t2,	$t2,	$t3			#与乘法相同
	sll 	$t2,	$t2,	31    			#final sign-->0+0=0/0+1=1/1+0=1/1+1=10=0

	sub 	$t8,	$t8,	$t8 	 		#t8清零用来存 商
	sub 	$t3,	$t3,	$t3  			#t3清零用来存 余数（未实现）
	sub 	$t5,	$t5,	$t5  			#t5清零用来存 计数器

divideCompare:
	bge 	$t5,	24,	divideJudge		#frac共24位，需要循环24次,循环完成后跳转判断新的frac是否溢出
	blt 	$t6,	$t7,	divideLower		#判断被除数和除数的大小（由于两个frac都是以1开头的24位数，那么只需要实现等位除法即可）
							#等位除法实现：与手算原理相同，被除数比除数大则商上1，比被除数小则商上0，每次被除数和商都左移1位

divideGreater:
	sub 	$t6,	$t6,	$t7
	sll 	$t6,	$t6,	1
	sll 	$t8,	$t8,	1
	addi  	$t8,	$t8,	1			#被除数比除数大，商上1
	addi 	$t5,	$t5,	1			#计数器加1
	j 	divideCompare

divideLower:
	sll 	$t6,	$t6,	1
	sll 	$t8,	$t8,	1			#被除数比除数小，商上0
	addi 	$t5,	$t5,	1			#计数器加1
	j	divideCompare

divideJudge:
	blt 	$t8,	0x00800000,	divideAdjust1      #隐含前导须为1，调整后t8前8位为零
	bge 	$t8,	0x01000000,	divideAdjust2      #judge if the fraction is up overflow
	j 	divideResult

divideAdjust1  :                                  	#调整frac使开头为1	
	sll 	$t8,	$t8,	1
	subi 	$t4,	$t4,	1
	blt 	$t8,	0x00800000,	divideAdjust1
	j 	divideResult
	
divideAdjust2:                                   	#调整frac的溢出	     	     
	srl 	$t8,	$t8,	1
	addi 	$t4,	$t4,	1
	bge 	$t8,	0x01000000,	divideAdjust2
	j 	divideResult

divideResult:
	bgt 	$t4,	255,	divideExpOF2		#判断exp的上溢overflow
	blt     $t4      0,     divideExpOF1		#判断exp的下溢overflow
	sll 	$t8,	$t8,	9
	srl 	$t8,	$t8,	9			#result的frac-->将前导1隐藏

	sll 	$t4,	$t4,	24
	srl 	$t4,	$t4,	1			#result的exp-->t4
	add 	$t2,	$t2,	$t4			#reslut的sign-->t2
	add 	$t2,	$t2,	$t8			# save result-->s2
	add	$s2,	$t2,	$zero		

	li 	$v0,	4				
	la 	$a0,	msg2
	syscall 

	li 	$v0,	2               		#print result
	mtc1 	$t2,	$f12  
	syscall
	j	printbinary				#print binary and hex
	#j	diviedEnd

divideExistZero:					#被除数为零直接输出零
	la      $a0,	msg2
	li      $v0,	4
	syscall
	mtc1    $zero,	$f12	
	li 	$v0,	2     
	syscall
	j       diviedEnd

divideExpOF2:						#exp溢出报错
	la    	$a0,	msg2			 
	li    	$v0,	4
	syscall
	la      $a0,	msg7
	li      $v0,	4
	syscall      
	j      diviedEnd

divideExpOF1:						#exp溢出报错
	la    	$a0,	msg2			 
	li    	$v0,	4
	syscall
	la      $a0,	msg8
	li      $v0,	4
	syscall

diviedEnd:
	la    	$a0,	msgquit			 
	li    	$v0,	4
	syscall	

	lw	$ra,	20($sp)				#堆栈弹出
	lw 	$fp,	16($sp)
	addiu 	$sp,	$sp,	32
	jr	$ra


.text 
printbinary:
	la	$a0,	msg11			#print binary
	li	$v0,	4
	syscall 

	andi	$t7,	$t7,	0x00000000	#初始化t7
	addi	$t7,	$s2,	0		#计算的结果在s2, 取出来放入t7,避免影响s2中的值
	andi	$t5,	$s2,	0x80000000	#用t5来循环输出二进制的每一位,每次都输出第一位，然后再左移1位
	srl	$t5,	$t5,	31		
	la	$a0,	($t5)
	li	$v0,	1
	syscall 
	
	andi	$t6,	$t6,	0x00000000	#初始化t6,来记录循环次数
	addi	$t6,	$t6,	31
judgebinary:					#判断输出位数够不够32位
	bne	$t6,	0,	loopbinary
	j           printtohex			#跳转继续输出十六进制结果

loopbinary:					#循环输出每一位
	sll	$t7,	$t7,	1
	andi	$t5,	$t7,	0x80000000
	srl	$t5,	$t5,	31
	la	$a0,	($t5)
	li	$v0,	1
	syscall 
	subi	$t6,	$t6,	1
	j	judgebinary

printtohex:					#print hex
	la	$a0,	msg12
	li	$v0,	4	
	syscall 

	andi	$t6,	$t6,	0x00000000	#初始化t6用来记录循环次数
	addi	$t6,	$t6,	28
	andi	$t7,	$t7,	0x00000000	#保护s2中的结果
	addi	$t7,	$s2,	0
	andi	$t5,	$s2,	0xf0000000	#用t5来循环输出结果,原理同二进制输出，每次输出四位二进制数即一位十六进制数
	srl	$t5,	$t5,	28
	subi	$t8,	$t5,	10		#判断t5中的值是否大于10,应该用数字输出还是用字母
	bgez	$t8,	firstprintABCDEF	#  >=0 jump 用字母输出ABCDEF
	la	$a0,	($t5)			#用数字输出即可
	li	$v0,	1
	syscall 
	
	judgehex:				#判断输出位数够不够八位
	bne	$t6,	0,	loophex
	j	diviedEnd			#跳出输出块

	loophex:
	sll	$t7,	$t7,	4		#循环输出块,原理与二进制输出相同
	andi	$t5,	$t7,	0xf0000000
	srl	$t5,	$t5,	28
	subi	$t8,	$t5,	10		#判断是否大于等于10
	bgez	$t8,	printABCDEF		#  >=0 jump
	la	$a0,	($t5)
	li	$v0,	1
	syscall 
	subi	$t6,	$t6,	4
	j	judgehex

firstprintABCDEF:				#输出ABCDEF,原理是在ascii码中A==65,然后用字符输出即可
	addi	$t5,	$t5,	55
	la	$a0,	($t5)
	li	$v0,	11			#字符输出的系统调用
	syscall 
	j	judgehex
printABCDEF:
	addi	$t5,	$t5,	55
	la	$a0,	($t5)
	li	$v0,	11
	syscall 
	subi	$t6,	$t6,	4
	j	judgehex

.text
doquit:	
	la	$a0,	msg9
	li	$v0,	4	
	syscall
	li	$v0,	10
	syscall 				#结束
