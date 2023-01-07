.data 
	msg:	.asciiz "****************************\n"
	msg0:   .asciiz "please input the 1st float:"
	msg1:   .asciiz "please input the 2nd float:"
	msg2:	.asciiz "Sum:"
	msg6:	.asciiz "Sub:"
	msg7:	.asciiz "*error* UP OVERFLOW\n"
	msg8:	.asciiz "*error* DOWN OVERFLOW\n"
	msg9:	.asciiz "**********The End**********"
	msg11:	.asciiz "\nBinary:"
	msg12:	.asciiz "\nHex:"
	msgop:  .asciiz "please input the option: 1->add  2->sub:\n"
	msgerr: .asciiz "input error! please input again\n"
	msgquit:.asciiz "\ninput '0' to quit, otherwise continue:\n"
.text
mainloop:	
	li	$v0,	4
	la	$a0,	msg
	syscall 
	jal	getInput		#进入输入模块
	jal	getoption		#调用指令模块
	
	#li	$v0,	4		#输出提示结束信息
	#la	$a0,	msgquit
	#syscall

	li	$v0,	5		#读取输入
	syscall
	
	add	$t0,	$v0,	$zero
	beq   	$t0,	0,	doquit	#等于0则结束程序

	j mainloop
	
.text 
getInput:
	subu	$sp,	$sp,	32 	#压栈
	sw 	$ra,	20($sp)
	sw	$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw 	$a0,	0($fp)
	
	li 	$v0,	4
	la 	$a0,	msg0
	syscall 
	li	$v0,	6
	syscall 
	mfc1 	$s0,	$f0 	#第一个数的读入与存储
	
	li 	$v0,	4
	la 	$a0,	msg1
	syscall
	li	$v0,	6
	syscall 
	mfc1 	$s1,	$f0 	#第二个数的读入与存储
	
	lw	$ra,	20($sp)
	lw 	$fp,	16($sp)
	addiu 	$sp,	$sp,	32
	jr	$ra
getoption:
	li 	$v0,	4
	la 	$a0,	msgop
	syscall
	li	$v0,	5
	syscall
	move	$t1,	$v0
	beq	$t1,	1,	mysum
	beq	$t1,	2,	mysub
	li	$v0,	4
	la	$a0,	msgerr
	syscall 
	j	getoption
	
.text
mysum:
	subu	$sp,	$sp,	32 
	sw 	$ra,	20($sp)
	sw	$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw 	$a0,	0($fp)
	
	beq	$s0,	0,	existonezero
	
continue:	
	srl	$s2,	$s0,	31	# $s2第一个数的符号位
	srl	$s5,	$s1,	31	# $s5第二个数字的符号位
	
	sll	$s3,	$s0,	1
	srl	$s3,	$s3,	24	# $s3 num1的指数位
	sll	$s6,	$s1,	1
	srl	$s6,	$s6,	24	# $s6 num2的指数位
	
	sll	$s4,	$s0,	9	
	srl 	$s4,	$s4,	9
	ori 	$s4,	$s4,	0x00800000 	# $4 num1的尾数
	sll	$s7,	$s1,	9	
	srl 	$s7,	$s7,	9
	ori 	$s7,	$s7,	0x00800000 	# $7 num2的尾数
	
	li	$v0,	4
	la	$a0,	msg2
	syscall
	jal     sumOperate
	
existonezero:
	bne	$s1,	0,	continue
	li	$v0,	4
	la	$a0,	msg2
	syscall
	li	$a0,	0
	li	$v0,	1
	syscall
	j	sumEnd
	 
	
	
.text 
mysub:
subu	$sp,	$sp,	32 
sw 	$ra,	20($sp)
sw	$fp,	16($sp)
addiu 	$fp,	$sp,	28
sw 	$a0,	0($fp)


srl 	$s2,	$s0,	31              # $s2第一个数的符号位
srl 	$s5,	$s1,	31              # $s2第一个数的符号位

sll 	$s3,	$s0,	1
srl 	$s3,	$s3,	24  		# 指数
sll 	$s6,	$s1,	1
srl 	$s6,	$s6,	24  		# 指数

# 尾数
sll	$s4,	$s0,	9
srl 	$s4,	$s4,	9
ori 	$s4,	$s4,	0x00800000     


sll 	$s7,	$s1,	9
srl 	$s7,	$s7,	9
ori 	$s7,	$s7,	0x00800000

xori   $s5,     $s5,    0x00000001

li	$v0,	4
la	$a0,	msg6
syscall

jal    sumOperate
	
.text
sumOperate:					     #比较指数的大小根据大小不同进行不同的移位
	sub	$t0,	$s3,	$s6
	bltz	$t0,		sumAdjust1          # 小于0则跳转
	bgtz	$t0,		sumAdjust2	     # 大于0则跳转
	beqz	$t0,		sumBegin		# 等于0则跳转
	

sumAdjust1:					
	addi	$s3,	$s3	1              #对num1指数加1，直到与num2指数相等
	srl	$s4,	$s4,	1		#由于指数加1，所以尾数要向右移1位
	sub	$t0,	$s3,	$s6		#判断指数是否相等
	bltz	$t0,		sumAdjust1
	beqz	$t0,		sumBegin	#此时指数已经相等，所以跳转到求和开始模块

sumAdjust2:					
	addi	$s6,	$s6,	1              #对num2指数加1，直到与num1指数相等
	srl	$s7,	$s7,	1		#由于指数加1，所以尾数要向右移1位
	sub	$t0,	$s3,	$s6		#判断指数是否相等
	bgtz	$t0,		sumAdjust2
	beqz	$t0,		sumBegin	#此时指数已经相等，所以跳转到求和开始模块
 
sumBegin:
	xor	$t3,	$s2,	$s5		#判断两个操作数的是异号还是同号
	beq	$t3,	0,	sumTH		# 同号进入求和函数
	beq	$t3,	1,	sumYH		# 异号进入求和函数
	
sumTH:							#同号求和
	add 	$t1,	$s4, 	$s7			#尾数相加
	sge 	$t2,	$t1,	0x01000000            #判断是否进位
	beq 	$t2,	1,     adjustF1	
	j	sumResult				#输出计算结果函数


sumYH:						#异号求和
	sub 	$t1,	$s4,	$s7
	bgt	$t1,	0,	sumB1	       # |n1|>|n2|
	blt	$t1,	0,	sumB2	       # |n1|<|n2|
	
	mtc1    $zero,	$f12			#如果相等则直接输出0
	li 	$v0,	2     
	syscall
	j	sumEnd
	
sumB1:
	blt 	$t1,	0x00800000,	sumAdjust11      #隐含前导须为1
	bge 	$t1,	0x01000000,	sumAdjust22      #溢出判断
	j 	sumResult

sumB2:
	sub 	$t1,	$s7,	$s4
	xori    $s2     $s2     0x00000001
	j     sumB1


adjustF1:                                 	
	srl	$t1,	$t1,	1
	addi	$s3,	$s3,	1
	j	sumResult				#输出

sumAdjust11:
	sll 	$t1,	$t1,	1
	subi 	$s3,	$s3,	1
	blt 	$t1,	0x00800000,	sumAdjust11
	j 	sumResult

sumAdjust22:
	srl 	$t1,	$t1,	1
	addi 	$s3,	$s3,	1
	bge 	$t8,	0x01000000,	sumAdjust22
	j 	sumResult
		
  	
 		
sumResult:	
	blt 	$s3,	0,	sumExpOF2            
	bgt 	$s3,	255,	sumExpOF1
  	
	sll	$s2,	$s2,	31           #符号位    
	sll	$s3,	$s3,	23		#指数位
	sll	$t1,	$t1,	9
	srl 	$t1,	$t1,	9		#尾数
	add	$s3,	$s3,	$t1
	add	$s2,	$s2,	$s3		#拼接
	mtc1    $s2,	$f12			#将$s2 值传给 $f12
  		
	li 	$v0,	2			
	syscall 				#输出
	j	printbinary
	

	
sumExpOF1:
	la 	$a0,	msg7
	li	$v0,	4
	syscall
	j           sumEnd    

sumExpOF2:
	la 	$a0,	msg8
	li	$v0,	4
	syscall
	j       sumEnd
 
 
sumEnd:				
	la    	$a0,	msgquit			 # new line
	li    	$v0,	4
	syscall
	
	lw	$ra,	20($sp)
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
judgebinary:				#判断输出位数够不够32位
	bne	$t6,	0,	loopbinary
	j           printtohex			#跳转继续输出十六进制结果

loopbinary:				#循环输出每一位
	sll	$t7,	$t7,	1
	andi	$t5,	$t7,	0x80000000
	srl	$t5,	$t5,	31
	la	$a0,	($t5)
	li	$v0,	1
	syscall 
	subi	$t6,	$t6,	1
	j	judgebinary

printtohex:				#print hex
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
	j           sumEnd			#跳出输出块

	loophex:
	sll	$t7,	$t7,	4		#循环输出块,原理与二进制输出相同
	andi	$t5,	$t7,	0xf0000000
	srl	$t5,	$t5,	28
	subi	$t8,	$t5,	10		#判断是否大于等于10
	bgez	$t8,	printABCDEF	#  >=0 jump
	la	$a0,	($t5)
	li	$v0,	1
	syscall 
	subi	$t6,	$t6,	4
	j	judgehex

firstprintABCDEF:		#输出ABCDEF,原理是在ascii码中A==65,然后用字符输出即可
	addi	$t5,	$t5,	55
	la	$a0,	($t5)
	li	$v0,	11		#字符输出的系统调用
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
	syscall 			#结束
