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
	msg9:	 .asciiz 	"\nInput��0��to quit, otherwise to continue......"
	
.text 	
main:			#������
	li	$v0,	4
	la	$a0,	msg0
	syscall 
	jal	getInput			#����num1��num2
	jal	mutilStart				#�˷�����
					
	li	$v0,	5
	syscall
	beq	$v0,	$zero,	end
	j	main
end:						# �������
	li	$v0,	4
	la	$a0,	msg4
	syscall 
	li	$v0,	10
	syscall 
	
		
.text					#����
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
	mfc1 	$s0,	$f0 	#��һ�����Ķ�����洢
	
	li 	$v0,	4
	la 	$a0,	msg2
	syscall
	li	$v0,	6
	syscall 
	mfc1 	$s1,	$f0 	#�ڶ������Ķ�����洢
	
	lw	$ra,	20($sp)
	lw 	$fp,	16($sp)
	addiu 	$sp,	$sp,	32
	jr	$ra


.text					#�˷�
	subu	$sp,	$sp,	32 		#��ջ
	sw 	$ra,	20($sp)
	sw	$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw 	$a0,	0($fp)

	beq	$s0,	$zero,	mutilExistZero
	beq 	$s1,	$zero,	mutilExistZero		#��������Ϊ0����ֱ�����0

mutilStart:
	subu	$sp,	$sp,	32 		#��ջ
	sw 	$ra,	20($sp)
	sw	$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw 	$a0,	0($fp)

	beq	$s0,	$zero,	mutilExistZero
	beq 	$s1,	$zero,	mutilExistZero		#��������Ϊ0����ֱ�����0
	
	srl 	$t2,	$s0,	31              # num1����λ
	srl 	$t3,	$s1,	31              # num2����λ

	sll 	$t4,	$s0,	1
	srl 	$t4,	$t4,	24  		# num1ָ��
	sll 	$t5,	$s1,	1
	srl 	$t5,	$t5,	24  		# num2ָ��


	sll	$t6,	$s0,	9
	srl 	$t6,	$t6,	9
	ori 	$t6,	$t6,	0x00800000	# num1β����������1
	sll 	$t6,	$t6,	8      		#��β��λ�Ƶ���λ�����ں�������ȡ�����32λ
	addi 	$t4,	$t4,	1		#����������1���൱��β������һλ������ָ����һ


	sll 	$t7,	$s1,	9
	srl 	$t7,	$t7,	9
	ori 	$t7,	$t7,	0x00800000	# num2β��,������1
	sll 	$t7,	$t7,	8		#��β��λ�Ƶ���λ�����ں�������ȡ�����32λ
	addi 	$t5,	$t5,	1		#����������1���൱��β������һλ������ָ����һ

	sub 	$t4,	$t4,	127		#��ȥƫ��
	add 	$t4,	$t4,	$t5   		#���յ�ָ������˷�ָ��ֱ�����
	blt 	$t4,	0,	multiExpof2         #���
	bgt 	$t4,	255,	multiExpof1         #���
	sub 	$t5,	$t5,	$t5		#����

mutilCompareSign:
	add 	$t2,	$t2,	$t3
	sll 	$t2,	$t2,	31    		# ���ս������λ

	multu 	$t6,	$t7
	mfhi 	$t5				#ȡ�����32λ

	
	andi 	$t8,	$t5,	0x80000000
	beq 	$t8,	0x80000000,  adjustMulti	 #�жϵ�31λ�ǲ���1�����������ת��ֻ��Ҫ����һ�Σ���������1

	sll 	$t5,	$t5,	1			#�����һλ����1��Ȼ�����ձ��㷨��β����СΪ0x80000000
	sub 	$t4,	$t4,	1			#����С������β����ˣ������ƽ��ȡ��32λΪ0100 0000 0000 0000 0000 0000 0000 0000
							#�������ֻ��Ҫ�������Σ�������������1������adjustMultiΪ�ڶ�������
	
adjustMulti:
	sll 	$t5,	$t5,	1     	        
	sub 	$t4,	$t4,	1		# β�����ƣ�ָ����һ
	srl 	$t5,	$t5,	9  		# ���յ�β��

mutilResult:
	sll 	$t4,	$t4,	24		
	srl 	$t4,	$t4,	1		#��ָ���Ƶ�[30��23]
	addu 	$t2,	$t2,	$t4		#���ӷ���λ
	addu 	$t2,	$t2,	$t5  		#����β��
	add	$s2,	$t2,	$zero		#���������ʱ�Ĵ����ﱣ�浽$s2

	li 	$v0,	4
	la 	$a0,	msg3
	syscall 

	li 	$v0,	2
	mtc1 	$t2,	$f12  			#������
	syscall
	j        printbinary

mutilExistZero:				#���0����������Ϊ0
	li 	$v0,	4
	la 	$a0,	msg3
	syscall 

	sub 	$s0,	$s0,	$s0
	mtc1 	$s0,	$f12
	li 	$v0,	2
	syscall
	j      printbinary

multiExpof1:
	la    	$a0,	msg3			 # ������
	li    	$v0,	4
	syscall
	la 	$a0,	msg5
	li	$v0,	4
	syscall
	j     multiEnd

multiExpof2:
	la    	$a0,	msg3			 # ������
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



.text 					#�����ƺ�ʮ���������
	printbinary:
	la	$a0,	msg7			#print binary
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
	la	$a0,	msg8
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
	j           multiEnd			#���������

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

