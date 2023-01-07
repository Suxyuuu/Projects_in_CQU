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
	jal	getInput		#��������ģ��
	jal	getoption		#����ָ��ģ��
	
	#li	$v0,	4		#�����ʾ������Ϣ
	#la	$a0,	msgquit
	#syscall

	li	$v0,	5		#��ȡ����
	syscall
	
	add	$t0,	$v0,	$zero
	beq   	$t0,	0,	doquit	#����0���������

	j mainloop
	
.text 
getInput:
	subu	$sp,	$sp,	32 	#ѹջ
	sw 	$ra,	20($sp)
	sw	$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw 	$a0,	0($fp)
	
	li 	$v0,	4
	la 	$a0,	msg0
	syscall 
	li	$v0,	6
	syscall 
	mfc1 	$s0,	$f0 	#��һ�����Ķ�����洢
	
	li 	$v0,	4
	la 	$a0,	msg1
	syscall
	li	$v0,	6
	syscall 
	mfc1 	$s1,	$f0 	#�ڶ������Ķ�����洢
	
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
	srl	$s2,	$s0,	31	# $s2��һ�����ķ���λ
	srl	$s5,	$s1,	31	# $s5�ڶ������ֵķ���λ
	
	sll	$s3,	$s0,	1
	srl	$s3,	$s3,	24	# $s3 num1��ָ��λ
	sll	$s6,	$s1,	1
	srl	$s6,	$s6,	24	# $s6 num2��ָ��λ
	
	sll	$s4,	$s0,	9	
	srl 	$s4,	$s4,	9
	ori 	$s4,	$s4,	0x00800000 	# $4 num1��β��
	sll	$s7,	$s1,	9	
	srl 	$s7,	$s7,	9
	ori 	$s7,	$s7,	0x00800000 	# $7 num2��β��
	
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


srl 	$s2,	$s0,	31              # $s2��һ�����ķ���λ
srl 	$s5,	$s1,	31              # $s2��һ�����ķ���λ

sll 	$s3,	$s0,	1
srl 	$s3,	$s3,	24  		# ָ��
sll 	$s6,	$s1,	1
srl 	$s6,	$s6,	24  		# ָ��

# β��
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
sumOperate:					     #�Ƚ�ָ���Ĵ�С���ݴ�С��ͬ���в�ͬ����λ
	sub	$t0,	$s3,	$s6
	bltz	$t0,		sumAdjust1          # С��0����ת
	bgtz	$t0,		sumAdjust2	     # ����0����ת
	beqz	$t0,		sumBegin		# ����0����ת
	

sumAdjust1:					
	addi	$s3,	$s3	1              #��num1ָ����1��ֱ����num2ָ�����
	srl	$s4,	$s4,	1		#����ָ����1������β��Ҫ������1λ
	sub	$t0,	$s3,	$s6		#�ж�ָ���Ƿ����
	bltz	$t0,		sumAdjust1
	beqz	$t0,		sumBegin	#��ʱָ���Ѿ���ȣ�������ת����Ϳ�ʼģ��

sumAdjust2:					
	addi	$s6,	$s6,	1              #��num2ָ����1��ֱ����num1ָ�����
	srl	$s7,	$s7,	1		#����ָ����1������β��Ҫ������1λ
	sub	$t0,	$s3,	$s6		#�ж�ָ���Ƿ����
	bgtz	$t0,		sumAdjust2
	beqz	$t0,		sumBegin	#��ʱָ���Ѿ���ȣ�������ת����Ϳ�ʼģ��
 
sumBegin:
	xor	$t3,	$s2,	$s5		#�ж�����������������Ż���ͬ��
	beq	$t3,	0,	sumTH		# ͬ�Ž�����ͺ���
	beq	$t3,	1,	sumYH		# ��Ž�����ͺ���
	
sumTH:							#ͬ�����
	add 	$t1,	$s4, 	$s7			#β�����
	sge 	$t2,	$t1,	0x01000000            #�ж��Ƿ��λ
	beq 	$t2,	1,     adjustF1	
	j	sumResult				#�������������


sumYH:						#������
	sub 	$t1,	$s4,	$s7
	bgt	$t1,	0,	sumB1	       # |n1|>|n2|
	blt	$t1,	0,	sumB2	       # |n1|<|n2|
	
	mtc1    $zero,	$f12			#��������ֱ�����0
	li 	$v0,	2     
	syscall
	j	sumEnd
	
sumB1:
	blt 	$t1,	0x00800000,	sumAdjust11      #����ǰ����Ϊ1
	bge 	$t1,	0x01000000,	sumAdjust22      #����ж�
	j 	sumResult

sumB2:
	sub 	$t1,	$s7,	$s4
	xori    $s2     $s2     0x00000001
	j     sumB1


adjustF1:                                 	
	srl	$t1,	$t1,	1
	addi	$s3,	$s3,	1
	j	sumResult				#���

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
  	
	sll	$s2,	$s2,	31           #����λ    
	sll	$s3,	$s3,	23		#ָ��λ
	sll	$t1,	$t1,	9
	srl 	$t1,	$t1,	9		#β��
	add	$s3,	$s3,	$t1
	add	$s2,	$s2,	$s3		#ƴ��
	mtc1    $s2,	$f12			#��$s2 ֵ���� $f12
  		
	li 	$v0,	2			
	syscall 				#���
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

	andi	$t7,	$t7,	0x00000000	#��ʼ��t7
	addi	$t7,	$s2,	0		#����Ľ����s2, ȡ��������t7,����Ӱ��s2�е�ֵ
	andi	$t5,	$s2,	0x80000000	#��t5��ѭ����������Ƶ�ÿһλ,ÿ�ζ������һλ��Ȼ��������1λ
	srl	$t5,	$t5,	31		
	la	$a0,	($t5)
	li	$v0,	1
	syscall 
	
	andi	$t6,	$t6,	0x00000000	#��ʼ��t6,����¼ѭ������
	addi	$t6,	$t6,	31
judgebinary:				#�ж����λ��������32λ
	bne	$t6,	0,	loopbinary
	j           printtohex			#��ת�������ʮ�����ƽ��

loopbinary:				#ѭ�����ÿһλ
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

	andi	$t6,	$t6,	0x00000000	#��ʼ��t6������¼ѭ������
	addi	$t6,	$t6,	28
	andi	$t7,	$t7,	0x00000000	#����s2�еĽ��
	addi	$t7,	$s2,	0
	andi	$t5,	$s2,	0xf0000000	#��t5��ѭ��������,ԭ��ͬ�����������ÿ�������λ����������һλʮ��������
	srl	$t5,	$t5,	28
	subi	$t8,	$t5,	10		#�ж�t5�е�ֵ�Ƿ����10,Ӧ�������������������ĸ
	bgez	$t8,	firstprintABCDEF	#  >=0 jump ����ĸ���ABCDEF
	la	$a0,	($t5)			#�������������
	li	$v0,	1
	syscall 
	
	judgehex:				#�ж����λ����������λ
	bne	$t6,	0,	loophex
	j           sumEnd			#���������

	loophex:
	sll	$t7,	$t7,	4		#ѭ�������,ԭ��������������ͬ
	andi	$t5,	$t7,	0xf0000000
	srl	$t5,	$t5,	28
	subi	$t8,	$t5,	10		#�ж��Ƿ���ڵ���10
	bgez	$t8,	printABCDEF	#  >=0 jump
	la	$a0,	($t5)
	li	$v0,	1
	syscall 
	subi	$t6,	$t6,	4
	j	judgehex

firstprintABCDEF:		#���ABCDEF,ԭ������ascii����A==65,Ȼ�����ַ��������
	addi	$t5,	$t5,	55
	la	$a0,	($t5)
	li	$v0,	11		#�ַ������ϵͳ����
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
	syscall 			#����
