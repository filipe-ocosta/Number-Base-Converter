.data 
	.align 0
	
	#defining labels and space that will be used throughout the program
	nro_hexa: .space 10
	nro_bin: .space 34
	nro_dec: .space 12
	
	#strings that will be printed throughout the program
	str_basei: .asciiz "Enter a number base for the input number between the options: B(for binary), H(for hexadecimal) ou D(for decimal)\n"
	str_nro: .asciiz "Enter a number less than 2^32 according to the chosen base:\n"
	str_basef: .asciiz "Enter a number base for the output number\n"
    str_final: .asciiz "The number converted to the chosen base is: "
	str_dec: .asciiz "4294967295"
 
	#error string
	str_erro: .asciiz "\nInvalid input!\n"

	.align 2

	numeroDecimal: .space 4
	
.text

main:	
	li $v0, 4 
	la $a0, str_basei
	syscall				#printing string str_basei
		
	li $v0, 12
	syscall				#reading the char that refers to the input numerical base
	move $t0, $v0			#moving the char read in $v0 to register $t0 

	li $v0, 12
	syscall				#reading the character "\n" after the refered char
	
	#comparing the char in $t0 to confer the type of input
	li $s0, 'H'
	beq $t0, $s0, entradaHex	#branching to hex input routine
	li $s0, 'h'
	beq $t0, $s0, entradaHex

	li $s0, 'B'
	beq $t0, $s0, entradaBin	#branching to binary input routine
	li $s0, 'b'
	beq $t0, $s0, entradaBin

	li $s0, 'D'
	beq $t0, $s0, entradaDec	#branching to decimal input routine
	li $s0, 'd'
	beq $t0, $s0, entradaDec

	#if the input is not equal to any of the number bases, the program goes to "error"

error:
	li $v0, 4
	la $a0, str_erro		#prints error message "Invalid input"! and goes to "end"
	syscall
	
end:						
	li $v0, 10			#ends the program
	syscall

#################################################
# Routines to read the input number in any base #
#################################################

entradaHex:
	li $v0, 4
	la $a0, str_nro
	syscall				#printing string str_nro

	li $v0, 8
	la $a0, nro_hexa		#reading the input hex number as a string
	li $a1, 10
	syscall

	j HextoDec			#jump to the routine that will turn the hex into a decimal number

entradaBin:
	li $v0, 4
	la $a0, str_nro
	syscall				#printing string str_nro

	li $v0, 8
	la $a0, nro_bin			#reading the input binary number as a string
	li $a1, 34
	syscall

	j BintoDec			#jump to the routine that will turn the binary into a decimal number

entradaDec:
	li $v0, 4
	la $a0, str_nro
	syscall				#printing string str_nro

	li $v0, 8
	la $a0, nro_dec			#reading the input decimal number as a string
	li $a1, 12
	syscall
	
	j StrtoDec			#jump to the routine that will turn the string into a int type decimal

#################################################
# Converters from input strings to int variable #
#################################################

HextoDec:
	la $s1, nro_hexa		#moving to $s1 the address of nro_hexa string
	li $s2, 0			#initializing register $s2 which will store the length of the string
	li $s4, 8			#storing in $s4 the maximum length of the string
	li $s3, '\0'
	li $t9, '\n'			#$s3 and $t9 will be used to find the end of string
	li $s5, 1			#$s5 holds the value of the powers of 16, starting with 16^0 and increasing the exponent with each execution
	li $s7, 16			#multiplies the $s5 incresing the exponent
	li $s6, 0			#used as an adder
	lb $t7, 0($s1)			#$t7 will store the value of each char in the string

	achaTamanho:				#this function traverses the string to find the length
		beq $s3, $t7, testeOverflow 	#breaks loop if end of string is found
		beq $t9, $t7, testeOverflow
		addi $s1, $s1, 1		#when the loop ends, it points to the last element of the string
		addi $s2, $s2, 1		#store the length of string
		lb $t7, 0($s1)
		j achaTamanho
	
	testeOverflow:
		bgt $s2, $s4, error		#tests if there is an overflow by comparing the length of string
	converterHD:
		sw $s6, numeroDecimal		#store the final sum value in numeroDecimal
		beq $s2, $zero, baseSaida	#ends the loop when the entire string has been traversed, going to baseSaida
	
		addi $s1, $s1, -1		#move to $t7 the value of next char
		lb $t7, 0($s1)

		sub $t7, $t7, 48		#sequency of tests to extract character values
		blt $t7, $zero, error 		#verify possible errors and ends the program if finds one
		li $s4, 9
		ble $t7, $s4  multiPot 
		sub $t7, $t7, 7
		ble $t7, $s4, error
		li $s4, 15
		ble $t7, $s4, multiPot
		sub $t7, $t7, 32
		bgt $t7, $s4, error
		li $s4, 10
		blt $t7, $s4, error

	multiPot:
		mul $t5, $s5, $t7		#multiplying the power of 16 by the value of the char and storing it in $t5
		add $s6, $s6, $t5		#store the sum value in $s6
		mul $s5, $s5, $s7		#increasing the power of 16 exponent
		addi $s2, $s2, -1		#decreasing the current position
		j converterHD


BintoDec:
	la $s1, nro_bin
	li $s2, 0			#initializing register $s2 which will store the length of the string
	li $t1, 32			#storing in $t1 the maximum length of the string
	li $s3, '\0'
	li $t9, '\n'
	li $s4, '0'
	li $t4, '1'			#$s4 and $t4 will be used to compare the value of char
	li $s5, 1			#$s5 holds the value of the powers of 2, starting with 2^0 and increasing the exponent with each execution
	li $s7, 2			#multiplies the $s5 incresing the exponent
	li $s6, 0
	lb $t7, 0($s1)

	findLength:				
		beq $s3, $t7, testeOver 
		beq $t9, $t7, testeOver
		addi $s1, $s1, 1
		addi $s2, $s2, 1
		lb $t7, 0($s1)
		j findLength
	
	testeOver:
		bgt $s2, $t1, error		#tests if there is an overflow by comparing the length of string

	converterBD:
		sw $s6, numeroDecimal		#store the final sum value in numeroDecimal
		beq $s2, $zero, baseSaida

		addi $s1, $s1, -1
		lb $t7, 0($s1)
		
		beq $s4, $t7, continue		#if char equal to '0' goes to "continue"
		bne $t4, $t7, error			#if char different of '1' goes to error
		add $s6, $s6, $s5			#adding the power of 2 to the sum if char equal to '1'
		continue:
			mul $s5, $s5, $s7		#increasing the power of 2 exponent
			addi $s2, $s2, -1		
			j converterBD


StrtoDec:
	la $s1, nro_dec
	la $t1, str_dec
	li $s2, 0
	li $s3, '\0'
	li $t9, '\n'
	li $s5, 1
	li $s7, 10
	li $s6, 0
	lb $t7, 0($s1)
	lb $t8, 0($t1)
	
	achaLength:
		beq $s3, $t7, testeO
		beq $t9, $t7, testeO
		addi $s1, $s1, 1
		addi $s2, $s2, 1
		lb $t7, 0($s1)
		j achaLength

	
	testeO:
		bgt $s2, $s7, error		#tests if there is an overflow by comparing the length of string
		bne $s2, $s7, converterSD		#if the length of string was less than 10 goes to converterSD
		sub $s1, $s1, $s2		#other way it tests if the number is equal or greater than 2^32
		lb $t7, 0($s1)
		bgt $t7, $t8, error
		add $s1, $s1, $s2
		lb $t7, 0($s1)

	converterSD:
		sw $s6, numeroDecimal
		beq $s2, $zero, baseSaida
		addi $s1, $s1, -1
		lb $t7, 0($s1)
		addi $t7, $t7, -48
		bge $t7, $s7, error
		blt $t7, $zero, error
		mul $t9, $t7, $s5
		add $s6, $s6, $t9
		mul $s5, $s5, $s7
		addi $s2, $s2, -1
		j converterSD

#############################################
# Routine to read the output numerical base #
#############################################

baseSaida:
	li, $v0, 4
	la, $a0, str_basef
	syscall				#printing string str_basef
	
	li $v0, 12			#reading the char that refers to the input numerical base
	syscall
	move $t0, $v0			#moving the char read in $v0 to register $t0 

	li $v0, 12
	syscall				#reading the character "\n" after the refered char

sentToConverter:
	#comparing the char in $t0 to confer the type of output
	li $s0, 'D'
	beq $t0, $s0, printDec		#branching to decimal output routine
	li $s0, 'd'
	beq $t0, $s0, printDec

	li $s0, 'H'
	beq $t0, $s0, DectoHex		#branching to hex output routine
	li $s0, 'h'
	beq $t0, $s0, DectoHex

	li $s0, 'B'
	beq $t0, $s0, DectoBin		#branching to binary output routine
	li $s0, 'b'
	beq $t0, $s0, DectoBin

	j error				#if $t0 is not equal to any of the number bases, the program goes to "error"

########################################################
# Converters from int to correct output numerical base #
########################################################

DectoHex:
	
	#criando uma variavel contadora que sera utilizada como controle do laco
	li $t0, 8 
	
	la $t6, nro_hexa
	lw $t5, numeroDecimal	
	move $t3, $t6
	
	addi $t3, $t3, 8
	li $t9, '\0'
	sb $t9, 0($t3)
	
	addi $t3, $t3, -1
	move $t7, $t3
	li $t8, 0
	
	while:
		beqz $t0, retorno 
		
		#mascarando com 15 para que a analise possa ocorrer, uma vez que apenas os 4 bits mais significativos serao 1
		and $t4, $t5, 15
		beq $t4, $t8, rotacao
		move $t7, $t3
		
		#rotacionando os bits para que a mascara seja aplicada em outras partes do numero inteiro
		rotacao:
			ror $t5, $t5, 4	

		#comparacoes e manipulacoes de acordo com a tabela ascii	
		ble $t4, 9, soma	
		addi $t4, $t4, 55	
		j sai
	 
	soma: 
		addi $t4, $t4, 48	
	
	sai: 
	sb $t4, 0($t3)	
	addi $t3, $t3, -1	
	addi $t0, $t0, -1	
	j while
		
	retorno:
		j printHex
		 
DectoBin:

	#criando uma variavel contadora que sera utilizada como controle do laco
	li $t0, 32
	
	la $t6, nro_bin
	lw $t5, numeroDecimal	
	move $t3, $t6
	
	addi $t3, $t3, 32
	li $t9, '\0'
	sb $t9, 0($t3)
	
	addi $t3, $t3, -1
	move $t7, $t3
	li $t8, '0'
	
	whi:
		beqz $t0, ret 
		
		#mascarando com 15 para que a analise possa ocorrer, uma vez que apenas os 4 bits mais significativos serao 1
		and $t4, $t5, 1
		addi $t4, $t4, 48
		beq $t4, $t8, rot
		move $t7, $t3

		rot:
		#rotacionando
		ror $t5, $t5, 1		
	 
		sb $t4, 0($t3)	
		addi $t3, $t3, -1	
		addi $t0, $t0, -1	
		j whi
		
	ret:
		j printBin

########################################################
# Routines to print the output number after conversion #
########################################################

printDec:
	#printando uma string
	li $v0, 4 
	la $a0, str_final
	syscall				#printing string str_final

	li $v0, 36
	lw $a0, numeroDecimal
	syscall				#printing the variable numeroDecimal as an unsigned int

	j end				#ends the program

printHex:
	li $v0, 4 
	la $a0, str_final
	syscall				#printing string str_final

	li $v0, 4
	move $a0, $t7			#printing the string that contains the hex number
	syscall

	j end				#ends the program

printBin:
	li $v0, 4 
	la $a0, str_final
	syscall				#printing string str_final

	li $v0, 4
	move $a0, $t7			#printing the string that contains the binary number
	syscall

	j end				#ends the program