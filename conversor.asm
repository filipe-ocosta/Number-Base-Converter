.data 
	.align 0
	
	#definindo os valores que serao lidos do teclado
	#lendo o nro_entrada_D como um int e os outros dois como string
	nro_hexa: .space 17
	nro_bin: .space 33
	 
	
	#strings quer serao impressas ao decorrer do programa
	str_basei: .asciiz "Insira a base do numero entre as opcoes: B, H ou D\n"
	str_nro: .asciiz "Insira um numero de acordo com a base escolhida\n"
	str_basef: .asciiz "Insira a base do numero de saida\n"
    	str_final: .asciiz "\nO numero convertido para a base escolhida eh: "

	#string de erro
	str_erro: .asciiz "\Entrada invalida!\n"

	.align 2

	numeroDecimal: .space 4
	
.text	
main:
	#printando a string base i : "Insira a base do numero entre as opcoes: B, H ou D\n"
	li $v0, 4 
	la $a0, str_basei
	syscall
	
	#lendo o char que refere a base inicial
	li $v0, 12
	syscall
	#movendo para t0 o conteudo de v0
	move $t0, $v0
	#lendo o "\n" que sobra
	li $v0, 12
	syscall
	
	#confere se a base eh hexadecimal
	li $s0, 'H'
	beq $t0, $s0, entradaHex
	li $s0, 'h'
	beq $t0, $s0, entradaHex

	#confere se a base eh binaria
	li $s0, 'B'
	beq $t0, $s0, entradaBin
	li $s0, 'b'
	beq $t0, $s0, entradaBin

	#confere se a base eh decimal
	li $s0, 'D'
	beq $t0, $s0, entradaDec
	li $s0, 'd'
	beq $t0, $s0, entradaDec

error: 						#printa mensagem de erro
	li $v0, 4
	la $a0, str_erro
	syscall

end:						#finaliza o programa
	li $v0, 10
	syscall


entradaHex:
	li $v0, 4
	la $a0, str_nro
	syscall

	li $v0, 8
	la $a0, nro_hexa
	li $a1, 17
	syscall

	j HextoDec


entradaBin:
	li $v0, 4
	la $a0, str_nro
	syscall

	li $v0, 8
	la $a0, nro_bin
	li $a1, 33
	syscall

	j BintoDec


entradaDec:
	li $v0, 4
	la $a0, str_nro
	syscall

	li $v0, 5
	syscall
	
	move $t5, $v0
	
	#para a execuçao normal os dois passos abaixos nao sao necessarios, porem para a execucao passo a passo sao!!
	#li $v0, 12
	#syscall
	

	blt $t5, $zero, error

	sw $t5, numeroDecimal


baseSaida:
	#printar "Insira a base do numero de saida\n"
	li, $v0, 4
	la, $a0, str_basef
	syscall
	
	#lendo o char que refere a base final
	li $v0, 12
	syscall
	
	#movendo para t1 o conteudo de v0
	move $t1, $v0
	
	#lendo o "\n" que sobra
	li $v0, 12
	syscall

		
sentToConverter:
	#confere se a base de saida eh decimal
	li $s0, 'D'
	beq $t1, $s0, printDec
	li $s0, 'd'
	beq $t1, $s0, printDec

	#confere se a base de saida eh hexadecimal
	li $s0, 'H'
	beq $t1, $s0, DectoHex
	li $s0, 'h'
	beq $t1, $s0, DectoHex

	#confere se a base de saida eh binaria
	li $s0, 'B'
	beq $t1, $s0, DectoBin
	li $s0, 'b'
	beq $t1, $s0, DectoBin

	j error

printDec:
	li $v0, 4 
	la $a0, str_final
	syscall

	li $v0, 1
	lw $a0, numeroDecimal
	syscall

	j end


printHex:
	li $v0, 4 
	la $a0, str_final
	syscall

	#li $v0, 1
	#la $a0, $t5
	#syscall

	j end


printBin:
	li $v0, 4 
	la $a0, str_final
	syscall

	li $v0, 4
	move $a0, $t7
	syscall

	j end

#############################################################################################################################3
# Conversores

HextoDec:

BintoDec:


DectoHex:


DectoBin:
	lw $s1, numeroDecimal
	li $t0, 2
			
	li $t6, '\0'

	la $t7, nro_bin
	
	addi $t7, $t7, 32
										
	sb $t6, 0($t7)
				
				
	while: 
		blt $s1, $t0, endWhile

		sub $t7, $t7, 1
						
		#dividindo num/2			
		div $s1, $t0 
					
		#pegando resto
		mfhi $t5
		beq $t5, $zero,addZero
		li $t5, '1'
		j addOne
		addZero:
			li $t5, '0'
		addOne:
			sb $t5, 0($t7)
					
		#pegando resultado da divisao
		mflo $s1
		j while


	endWhile:
		sub $t7, $t7, 1
		beq $s1,$zero, lastBitZero 
		li $t5, '1'
		j lastBitOne
		lastBitZero:
			li $t5, '0'
		lastBitOne:
			sb $t5, 0($t7)
			j printBin
