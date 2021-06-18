.data 
	.align 0
	
	#definindo os valores que serao lidos do teclado
	#lendo o nro_entrada_D como um int e os outros dois como string
	nro_hexa: .space 10
	nro_bin: .space 34
	nro_dec: .space 12
	
	#strings quer serao impressas ao decorrer do programa
	str_basei: .asciiz "Insira a base do numero entre as opcoes: B, H ou D\n"
	str_nro: .asciiz "Insira um numero de acordo com a base escolhida\n"
	str_basef: .asciiz "Insira a base do numero de saida\n"
    str_final: .asciiz "O numero convertido para a base escolhida eh: "
	str_dec: .asciiz "4294967295"
 
	#string de erro
	str_erro: .asciiz "\nEntrada invalida!\n"

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
	#printando string
	li $v0, 4
	la $a0, str_nro
	syscall

	#lendo o numero hexa como uma string
	li $v0, 8
	la $a0, nro_hexa
	li $a1, 10
	syscall

	j HextoDec


entradaBin:
	#printando uma string
	li $v0, 4
	la $a0, str_nro
	syscall

	#lendo o numero binario como uma string
	li $v0, 8
	la $a0, nro_bin
	li $a1, 34
	syscall

	j BintoDec


entradaDec:

	#printado uma string
	li $v0, 4
	la $a0, str_nro
	syscall

	#lendo um inteiro
	li $v0, 8
	la $a0, nro_dec
	li $a1, 12
	syscall
	
	j StrtoDec

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

	#printando uma string
	li $v0, 4 
	la $a0, str_final
	syscall

	#printando o decimal
	li $v0, 36
	lw $a0, numeroDecimal
	syscall

	j end


printHex:

	#printando uma string
	li $v0, 4 
	la $a0, str_final
	syscall

	#printando a string que contem o numero hexadecimal
	li $v0, 4
	move $a0, $t6
	syscall

	j end


printBin:
	#printando uma string
	li $v0, 4 
	la $a0, str_final
	syscall

	#printando a string binaria
	li $v0, 4
	move $a0, $t6
	syscall

	j end

##############################################################################################################################
# Conversores

HextoDec:
	
	#carregando o endereço da string com o nro hexadecimal para s1
	la $s1, nro_hexa

	#s2 será utilizado para armazenar o tamanho da string
	li $s2, 0
	
	#s4 sera usado para armazenar o tamanho maximo da string
	li $s4, 8

	#s3 e s9 utilizados para identificar o fim da string e desviar a função
	li $s3, '\0'
	li $t9, '\n'

	#s5 guarda o valor das potencias de 16, subindo a cada execução
	li $s5, 1

	#utilizado para multiplicar juntamente com s5
	li $s7, 16

	#utilizado como somador
	li $s6, 0
	

	#t7 vai guardar o valor de cada bit da string
	lb $t7, 0($s1)

	achaTamanho:
	#comparações
		beq $s3, $t7, testeOverflow
		beq $t9, $t7, testeOverflow
		addi $s1, $s1, 1
		addi $s2, $s2, 1
		lb $t7, 0($s1)
		j achaTamanho
	
	testeOverflow:
		bgt $s2, $s4, error
	converterHD:
		sw $s6, numeroDecimal
		beq $s2, $zero, baseSaida
		addi $s1, $s1, -1
		lb $t7, 0($s1)
		sub $t7, $t7, 48
		blt $t7, $zero, error 
		
		#valor utilizado para comparação posteriormente
		li $s4, 9

		#caso t7 seja <= 9 pula para a etapa de multiplicacao
		ble $t7, $s4  multiPot 
		sub $t7, $t7, 7

		#se apos a subtracao o valor continuar sendo <=9, isso indica erro
		ble $t7, $s4, error
		li $s4, 15

		bgt $t7, $s4, error

	#caso entre nesse rotulo, isso significa que o numero eh valido
	multiPot:
		#multiplicando a potencia de 16 com o valor do bit e armazenando em t5
		mul $t5, $s5, $t7

		#s6 guarda o valor do numero decimal
		add $s6, $s6, $t5

		#multiplicando 16 pela potencia atual de 16 e guardando em s5 para salvar a potencia
		mul $s5, $s5, $s7

		#decrementendo a posicao atual
		addi $s2, $s2, -1
		j converterHD

	

BintoDec:

	#carregando o endereco da string com o nro binario para s1
	la $s1, nro_bin

	#s2 sera utilizado para armazenar o tamanho da string
	li $s2, 0

	#s3 e s9 utilizados para identificar o fim da string e desviar a funcao
	li $s3, '\0'
	li $t9, '\n'
	
	#s4 e t4 utilizados para verificar cada bit individualmente e transformar para valor decimal
	li $s4, '0'
	li $t4, '1'
	
	#s5 guarda o valor das potencias de 2, subindo a cada execucao
	li $s5, 1

	#utilizado para multiplicar juntamente com s5
	li $s7, 2

	#utilizado como somador
	li $s6, 0

	#t7 vai guardar o valor de cada bit da string
	lb $t7, 0($s1)
	
	li $t1, 32

	#laco para definir o tamanho da string
	findLength:

		#comparacoes
		beq $s3, $t7, testeOver
		beq $t9, $t7, testeOver
		addi $s1, $s1, 1
		addi $s2, $s2, 1
		lb $t7, 0($s1)
		j findLength
	
	
	testeOver:
		bgt $s2, $t1, error
	#esse laco percorre a string a partir do bit menos significativo, incrementando s6 caso o bit = 1
	#laco responsavel por verificar se o numero eh realmente binario
	converterBD:
		sw $s6, numeroDecimal
		beq $s2, $zero, baseSaida
		addi $s1, $s1, -1
		lb $t7, 0($s1)
		beq $s4, $t7, continue
		bne $t4, $t7, error
		add $s6, $s6, $s5
		continue:
			mul $s5, $s5, $s7
			addi $s2, $s2, -1
			j converterBD


StrtoDec:

	#carregando o endereco da string com o nro binario para s1
	la $s1, nro_dec
	la $t1, str_dec

	#s2 sera utilizado para armazenar o tamanho da string
	li $s2, 0

	#s3 e s9 utilizados para identificar o fim da string e desviar a funcao
	li $s3, '\0'
	li $t9, '\n'
	
	#s5 guarda o valor das potencias de 2, subindo a cada execucao
	li $s5, 1

	#utilizado para multiplicar juntamente com s5
	li $s7, 10

	#utilizado como somador
	li $s6, 0

	#t7 vai guardar o valor de cada bit da string
	lb $t7, 0($s1)
	lb $t8, 0($t1)
	

	#laco para definir o tamanho da string
	achaLength:

		#percorre a string, guarda o tamanho dela em $s2 e posiciona o $t7 na ultima posicao
		beq $s3, $t7, testeO
		beq $t9, $t7, testeO
		addi $s1, $s1, 1
		addi $s2, $s2, 1
		lb $t7, 0($s1)
		j achaLength

	
	testeO:
		bgt $s2, $s7, error
		bne $s2, $s7, converterSD
		sub $s1, $s1, $s2
		lb $t7, 0($s1)
		bgt $t7, $t8, error
		add $s1, $s1, $s2
		lb $t7, 0($s1)


	#esse laco percorre a string a partir do bit menos significativo, incrementando s6 caso o bit = 1
	#laco responsavel por verificar se o numero eh realmente binario
	converterSD:
		sw $s6, numeroDecimal
		beq $s2, $zero, baseSaida
		addi $s1, $s1, -1
		lb $t7, 0($s1)
		addi $t7, $t7, -48
		bge $t7, $s7, error
		mul $t9, $t7, $s5
		add $s6, $s6, $t9
		mul $s5, $s5, $s7
		addi $s2, $s2, -1
		j converterSD



DectoHex:
	
	#criando uma variavel contadora que sera utilizada como controle do laco
	li $t0, 8 
	
	la $t6, nro_hexa
	lw $t5, numeroDecimal	
	move $t3, $t6
	
	addi $t3, $t3, 8
	li $t9, '\0'
	sb $t9, 0($t3)
	
	move $t3, $t6
	
	while:
		beqz $t0, retorno 
		
		#rotacionando para os 4 bits mais significativos para que possam ser analisados, porque os bits serao analisados 4 por 4	
		rol $t5, $t5, 4	
		
		#mascarando com 15 para que a analise possa ocorrer, uma vez que apenas os 4 bits mais significativos serao 1
		and $t4, $t5, 15
		
		#comparacoes e manipulacoes de acordo com a tabela ascii	
		ble $t4, 9, soma	
		addi $t4, $t4, 55	
		j sai
	 
	soma: 
		addi $t4, $t4, 48	
	
	sai: 
	sb $t4, 0($t3)	
	addi $t3, $t3, 1	
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


