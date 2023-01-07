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
	jal	getInput		#��������ģ��
	jal	divide			#�������ģ��
	
	li	$v0,	5		#��ȡ�Ƿ��˳�������
	syscall
	
	add	$t0,	$v0,	$zero
	beq   	$t0,	0,	doquit	#����0���������

	j mainloop
	
.text 
getInput:
	subu	$sp,	$sp,	32 	
	sw 	$ra,	20($sp)
	sw	$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw 	$a0,	0($fp)			#ѹջ
	
	li 	$v0,	4
	la 	$a0,	msg0
	syscall 
	li	$v0,	6
	syscall 
	mfc1 	$s0,	$f0 			#��һ�����Ķ�����洢
	
	li 	$v0,	4
	la 	$a0,	msg1
	syscall
	li	$v0,	6
	syscall 
	mfc1 	$s1,	$f0 			#�ڶ������Ķ�����洢
	
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
	sw 	$a0,	0($fp)				#ѹջ

	beq 	$s1,	$zero,	divideError		#�жϳ����Ƿ�Ϊ��
	beq 	$s0,	$zero,	divideExistZero		#�жϱ������Ƿ�Ϊ��
	j 	divideStart				#��ת������ģ��

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
	ori 	$t6,	$t6,	0x00800000      	#��¶����ǰ��1���frac1-->t6

	sll 	$t7,	$s1,	9
	srl 	$t7,	$t7,	9			#frac2
	ori 	$t7,	$t7,	0x00800000      	#��¶����ǰ��1���frac2-->t7

	sub 	$t4,	$t4,	$t5   			
	addi 	$t4,	$t4,	127			#final exp-->t4=t4-t5+127
	sub 	$t5,	$t5,	$t5			#t5����

divideCompareSign:
	add 	$t2,	$t2,	$t3			#��˷���ͬ
	sll 	$t2,	$t2,	31    			#final sign-->0+0=0/0+1=1/1+0=1/1+1=10=0

	sub 	$t8,	$t8,	$t8 	 		#t8���������� ��
	sub 	$t3,	$t3,	$t3  			#t3���������� ������δʵ�֣�
	sub 	$t5,	$t5,	$t5  			#t5���������� ������

divideCompare:
	bge 	$t5,	24,	divideJudge		#frac��24λ����Ҫѭ��24��,ѭ����ɺ���ת�ж��µ�frac�Ƿ����
	blt 	$t6,	$t7,	divideLower		#�жϱ������ͳ����Ĵ�С����������frac������1��ͷ��24λ������ôֻ��Ҫʵ�ֵ�λ�������ɣ�
							#��λ����ʵ�֣�������ԭ����ͬ���������ȳ�����������1���ȱ�����С������0��ÿ�α��������̶�����1λ

divideGreater:
	sub 	$t6,	$t6,	$t7
	sll 	$t6,	$t6,	1
	sll 	$t8,	$t8,	1
	addi  	$t8,	$t8,	1			#�������ȳ���������1
	addi 	$t5,	$t5,	1			#��������1
	j 	divideCompare

divideLower:
	sll 	$t6,	$t6,	1
	sll 	$t8,	$t8,	1			#�������ȳ���С������0
	addi 	$t5,	$t5,	1			#��������1
	j	divideCompare

divideJudge:
	blt 	$t8,	0x00800000,	divideAdjust1      #����ǰ����Ϊ1��������t8ǰ8λΪ��
	bge 	$t8,	0x01000000,	divideAdjust2      #judge if the fraction is up overflow
	j 	divideResult

divideAdjust1  :                                  	#����fracʹ��ͷΪ1	
	sll 	$t8,	$t8,	1
	subi 	$t4,	$t4,	1
	blt 	$t8,	0x00800000,	divideAdjust1
	j 	divideResult
	
divideAdjust2:                                   	#����frac�����	     	     
	srl 	$t8,	$t8,	1
	addi 	$t4,	$t4,	1
	bge 	$t8,	0x01000000,	divideAdjust2
	j 	divideResult

divideResult:
	bgt 	$t4,	255,	divideExpOF2		#�ж�exp������overflow
	blt     $t4      0,     divideExpOF1		#�ж�exp������overflow
	sll 	$t8,	$t8,	9
	srl 	$t8,	$t8,	9			#result��frac-->��ǰ��1����

	sll 	$t4,	$t4,	24
	srl 	$t4,	$t4,	1			#result��exp-->t4
	add 	$t2,	$t2,	$t4			#reslut��sign-->t2
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

divideExistZero:					#������Ϊ��ֱ�������
	la      $a0,	msg2
	li      $v0,	4
	syscall
	mtc1    $zero,	$f12	
	li 	$v0,	2     
	syscall
	j       diviedEnd

divideExpOF2:						#exp�������
	la    	$a0,	msg2			 
	li    	$v0,	4
	syscall
	la      $a0,	msg7
	li      $v0,	4
	syscall      
	j      diviedEnd

divideExpOF1:						#exp�������
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

	lw	$ra,	20($sp)				#��ջ����
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
judgebinary:					#�ж����λ��������32λ
	bne	$t6,	0,	loopbinary
	j           printtohex			#��ת�������ʮ�����ƽ��

loopbinary:					#ѭ�����ÿһλ
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
	j	diviedEnd			#���������

	loophex:
	sll	$t7,	$t7,	4		#ѭ�������,ԭ��������������ͬ
	andi	$t5,	$t7,	0xf0000000
	srl	$t5,	$t5,	28
	subi	$t8,	$t5,	10		#�ж��Ƿ���ڵ���10
	bgez	$t8,	printABCDEF		#  >=0 jump
	la	$a0,	($t5)
	li	$v0,	1
	syscall 
	subi	$t6,	$t6,	4
	j	judgehex

firstprintABCDEF:				#���ABCDEF,ԭ������ascii����A==65,Ȼ�����ַ��������
	addi	$t5,	$t5,	55
	la	$a0,	($t5)
	li	$v0,	11			#�ַ������ϵͳ����
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
	syscall 				#����
