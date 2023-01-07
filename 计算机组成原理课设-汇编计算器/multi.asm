.data
	msg0:	 .asciiz 	"\n**********************************\n"
	msg1:   .asciiz 	"input the first floating-point value:"
	msg2:   .asciiz 	"input the second floating-point value:"
	msg3:	 .asciiz 	"result:"
	msg4:	 .asciiz 	"***************THE END**************"
	msg5:	 .asciiz 	"UP OVERFLOW\n"
	msg6:	 .asciiz 	"DOWN OVERFLOW\n"
	msg7:	 .asciiz 	"\nBinary:"
	msg8:	 .asciiz 	"\nHex:"
	msg9:	 .asciiz 	"\nInput‘0’to quit, otherwise to continue......"
	
.text 	
main:			#主函数
	li	$v0,	4
	la	$a0,	msg0
	syscall 
	jal	getInput			#输入num1，num2
	jal	mutilStart				#乘法计算
					
	li	$v0,	5
	syscall
	beq	$v0,	$zero,	end
	j	main
end:						# 程序结束
	li	$v0,	4
	la	$a0,	msg4
	syscall 
	li	$v0,	10
	syscall 
	
		
.text					#输入
getInput:
	subu	$sp,	$sp,	32 
	sw 	$ra,	20($sp)
	sw	$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw 	$a0,	0($fp)
	
	li 	$v0,	4
	la 	$a0,	msg1
	syscall 
	li	$v0,	6
	syscall 
	mfc1 	$s0,	$f0 	#第一个数的读入与存储
	
	li 	$v0,	4
	la 	$a0,	msg2
	syscall
	li	$v0,	6
	syscall 
	mfc1 	$s1,	$f0 	#第二个数的读入与存储
	
	lw	$ra,	20($sp)
	lw 	$fp,	16($sp)
	addiu 	$sp,	$sp,	32
	jr	$ra


.text					#乘法
	subu	$sp,	$sp,	32 		#入栈
	sw 	$ra,	20($sp)
	sw	$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw 	$a0,	0($fp)

	beq	$s0,	$zero,	mutilExistZero
	beq 	$s1,	$zero,	mutilExistZero		#若任意数为0，则直接输出0

mutilStart:
	subu	$sp,	$sp,	32 		#入栈
	sw 	$ra,	20($sp)
	sw	$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw 	$a0,	0($fp)

	beq	$s0,	$zero,	mutilExistZero
	beq 	$s1,	$zero,	mutilExistZero		#若任意数为0，则直接输出0
	
	srl 	$t2,	$s0,	31              # num1符号位
	srl 	$t3,	$s1,	31              # num2符号位

	sll 	$t4,	$s0,	1
	srl 	$t4,	$t4,	24  		# num1指数
	sll 	$t5,	$s1,	1
	srl 	$t5,	$t5,	24  		# num2指数


	sll	$t6,	$s0,	9
	srl 	$t6,	$t6,	9
	ori 	$t6,	$t6,	0x00800000	# num1尾数，含隐含1
	sll 	$t6,	$t6,	8      		#将尾数位移到高位，易于后面计算后取结果高32位
	addi 	$t4,	$t4,	1		#加上了隐含1，相当于尾数左移一位，所以指数加一


	sll 	$t7,	$s1,	9
	srl 	$t7,	$t7,	9
	ori 	$t7,	$t7,	0x00800000	# num2尾数,含隐含1
	sll 	$t7,	$t7,	8		#将尾数位移到高位，易于后面计算后取结果高32位
	addi 	$t5,	$t5,	1		#加上了隐含1，相当于尾数左移一位，所以指数加一

	sub 	$t4,	$t4,	127		#减去偏阶
	add 	$t4,	$t4,	$t5   		#最终的指数，算乘法指数直接相加
	blt 	$t4,	0,	multiExpof2         #溢出
	bgt 	$t4,	255,	multiExpof1         #溢出
	sub 	$t5,	$t5,	$t5		#归零

mutilCompareSign:
	add 	$t2,	$t2,	$t3
	sll 	$t2,	$t2,	31    		# 最终结果符号位

	multu 	$t6,	$t7
	mfhi 	$t5				#取结果高32位

	
	andi 	$t8,	$t5,	0x80000000
	beq 	$t8,	0x80000000,  adjustMulti	 #判断第31位是不是1，如果是则跳转，只需要左移一次，隐藏隐含1

	sll 	$t5,	$t5,	1			#如果第一位不是1，然而按照本算法，尾数最小为0x80000000
	sub 	$t4,	$t4,	1			#若最小的两个尾数相乘，二进制结果取高32位为0100 0000 0000 0000 0000 0000 0000 0000
							#所以最多只需要左移两次，即可隐藏隐含1，下面adjustMulti为第二次左移
	
adjustMulti:
	sll 	$t5,	$t5,	1     	        
	sub 	$t4,	$t4,	1		# 尾数左移，指数减一
	srl 	$t5,	$t5,	9  		# 最终的尾数

mutilResult:
	sll 	$t4,	$t4,	24		
	srl 	$t4,	$t4,	1		#将指数移到[30：23]
	addu 	$t2,	$t2,	$t4		#链接符号位
	addu 	$t2,	$t2,	$t5  		#链接尾数
	add	$s2,	$t2,	$zero		#将结果从临时寄存器里保存到$s2

	li 	$v0,	4
	la 	$a0,	msg3
	syscall 

	li 	$v0,	2
	mtc1 	$t2,	$f12  			#输出结果
	syscall
	j        printbinary

mutilExistZero:				#输出0，若任意数为0
	li 	$v0,	4
	la 	$a0,	msg3
	syscall 

	sub 	$s0,	$s0,	$s0
	mtc1 	$s0,	$f12
	li 	$v0,	2
	syscall
	j      printbinary

multiExpof1:
	la    	$a0,	msg3			 # 溢出输出
	li    	$v0,	4
	syscall
	la 	$a0,	msg5
	li	$v0,	4
	syscall
	j     multiEnd

multiExpof2:
	la    	$a0,	msg3			 # 溢出输出
	li    	$v0,	4
	syscall
	la 	$a0,	msg7
	li	$v0,	4
	syscall 

multiEnd:
	
	la    	$a0,	msg9			
	li    	$v0,	4
	syscall	

	lw	$ra,	20($sp)
	lw 	$fp,	16($sp)
	addiu 	$sp,	$sp,	32
	jr	$ra	



.text 					#二进制和十六进制输出
	printbinary:
	la	$a0,	msg7			#print binary
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
	la	$a0,	msg8
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
	j           multiEnd			#跳出输出块

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

