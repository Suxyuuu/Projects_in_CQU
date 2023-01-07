        .data
hello:   .asciiz "Hello\n"   
hh:   .asciiz "\n"
good:   .asciiz "Good:"
total:   .asciiz "Total:"
godie:   .asciiz "Thank you Bye" 
.text
main:
la    	$a0,	hello			
li    	$v0,	4
syscall
li  $v0, 40           #seed
addi $a0, $0, 10  
syscall
move $s1,$0 
move $s0,$0 # for i=0
mainloop:
beq $s0,100,end# i<100
addi $s0,$s0,1 # i++
jal getrandom#a0放第一个浮点数
move $a1,$a0#a1放第二个浮点数
mov.s $f1,$f0
jal getrandom
jal getmul#######################  四选一： getadd  getsub  getmul getdiv ##############################
move $a3,$t0
jal yourfunc#浮点数放在$a0,$a1中，请将计算结果放入$a2中，临时寄存器可以随意修改，其他寄存器改了请恢复
bne $a2,$a3,mainloop
addi $s1,$s1,1
j mainloop

yourfunc:
######################
###请在这里填写你的代码
######################
jr $ra


getrandom:
li  $v0, 43           #getrandom
addi $a0, $0, 10  # 
syscall
sub $sp,$sp,4
s.s $f0,($sp)
lw $a0,($sp)
addi $a0,$a0,0x2000000
andi $a0,$a0,0xfffff000
sw $a0,($sp)
l.s $f0,($sp)
addi $sp,$sp,4
jr $ra

getadd:
add.s $f0,$f0,$f1
sub $sp,$sp,4
s.s $f0,($sp)
lw $t0,($sp)
addi $sp,$sp,4
jr $ra
getsub:
sub.s $f0,$f0,$f1
sub $sp,$sp,4
s.s $f0,($sp)
lw $t0,($sp)
addi $sp,$sp,4
jr $ra
getmul:
mul.s $f0,$f0,$f1
sub $sp,$sp,4
s.s $f0,($sp)
lw $t0,($sp)
addi $sp,$sp,4
jr $ra
getdiv:
div.s $f0,$f0,$f1
sub $sp,$sp,4
s.s $f0,($sp)
lw $t0,($sp)
addi $sp,$sp,4
jr $ra
end:
la    	$a0,	good			
li    	$v0,	4
syscall
move $a0,$s1		
li    	$v0,	1
syscall
la    	$a0,	hh			
li    	$v0,	4
syscall
la    	$a0,	total			
li    	$v0,	4
syscall
move $a0,$s0		
li    	$v0,	1
syscall
la    	$a0,	hh			
li    	$v0,	4
syscall
la    	$a0,	godie			
li    	$v0,	4
syscall
