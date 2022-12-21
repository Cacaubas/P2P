#/bin/bash

sobe_hosts() { 
	for ((I=0; I<${#HOSTS[@]}; I+=1)) 
	do
		nohup freechains-host --port=${HOSTS[$I]} start /tmp/p2p/${USUARIOS[$resp]} > /dev/null &
 		sleep 5
	done
}

parar_hosts() {
     # Processo interno da simulação responsável por parar os deamons que servem os nós.
	echo "Encerrando os hosts ..."
	
	for ((I=0; I<${#HOSTS[@]}; I+=1))
	do
		freechains-host stop --port=${HOSTS[$I]} 
	done
 }


gera_keys() {
# Gerando as chaves ##
	echo " Gerando chaves publicas e privadas, aguarde ..."
	KEYS=( $(freechains keys pubpvt "Está é a senha forte para o usuário ${USUARIOS[$resp]} " ) )
	PUBKEY[$resp]=${KEYS[0]}
	PRIKEY[$resp]=${KEYS[1]}
	KY_BANCA=( $(freechains keys pubpvt "Está é a senha forte para o usuário ${USUARIOS[0]} " ) )
	clear
}


busca_reps() {
	echo " Verificando reputacao do usuario, aguarde ..."	
	REPUTACAO=$(freechains --host=localhost:${HOSTS[$HOST]} chain '#free_sebo' reps ${PUBKEY[$resp]})
	sleep 3
	echo "${USUARIOS[$resp]} tem reputação $REPUTACAO. --- Tecle ENTER para continuar"    
	read
	clear
}					      

entra_cadeia(){
	freechains --host=localhost:${HOSTS[$resp]} chains join '#free_sebo' ${PUBKEY[$resp]}
        freechains --host=localhost:${HOSTS[$resp]} peer localhost:8330 recv '#free_sebo'
} 

monta_cadeia() {
	CADEIA=($(freechains --host=localhost:${HOSTS[$HOST]} chain '#free_sebo' consensus))
	if [ ${#CADEIA[@]} = 0 ]     
	then  # nada a fazer
		echo "CADEIA VAZIA"     
	        return
       	else  # analisar o conteúdo do post
		for ((I=1; I<${#CADEIA[@]}; I+=1))
		do
			PAYLOAD=($(freechains --host=localhost:${HOSTS[$HOST]} chain '#free_sebo' get payload ${CADEIA[$I]}))
		done  
	fi

}
  
  
recebe_atualizacao()  {

	echo "Recebe atualizacao -->"

	for ((I=0; I<${#HOSTS[@]}; I+=1))  
	do
		if [ ${HOSTS[$I]} = ${HOSTS[$resp]} ]  # esse é o host do usuário atual
		then
			return
		else
			freechains --host=localhost:${HOSTS[$I]} peer localhost:${HOSTS[$resp]} recv '#free_sebo'
		fi
	done

}


envia_atualizacao()  {

	echo "envia atualizacao"
	for ((I=0; I<${#HOSTS[@]}; I+=1))  
	do
		if [ ${HOSTS[$I]} = ${HOSTS[$resp]} ]  # esse é o host do usuário atual
		then
			continue
		else
			freechains --host=localhost:${HOSTS[$I]} peer localhost:${HOSTS[$resp]} send '#free_sebo'
		fi
	done

}


posta_venda() {
        recebe_atualizacao
	freechains --host=localhost:${HOSTS[$resp]} chain '#free_sebo' post inline "${PUBKEY[$resp]}-${KY_BANCA[0]}:Livro: $livro , Preco: $preco, PIX: $pix" --sign=${PRIKEY[$resp]}
        envia_atualizacao

}

admite_proposta_compra() {

	echo " Verificando proposta de compra ..."
	LIVROS=($(freechains chain '#free_sebo' heads blocked))
	if [ ${#LIVROS[@]} = 0 ] 
	then  # nada a fazer
		LIVROS=($(freechains chain '#free_sebo' heads))
		if [ ${#LIVROS[@]} = 0 ]
		then
			echo "Nao existe proposta de compra pendente. Tecle <ENTER> para continuar"
			read
			return
		fi
	fi	
		for I in ${LIVROS[*]}
		do
			PAYLOAD=($(freechains chain '#free_sebo' get payload ${I}))
			if [[ ${PUBKEY[$resp]} = "${PAYLOAD:0:64}" ]] && [[ ${PAYLOAD:130:7} = "Vendido" ]]
			then	
				freechains chain '#free_sebo' get payload ${I}
				echo "Aceita esta compra? (S/N)"
				read opcao
				if [[ $opcao = "S" ]] || [[ $opcao = "s" ]]  
				then
	    				recebe_atualizacao
					freechains chain '#free_sebo' like ${I} --sign=${PRIKEY[$resp]}
					envia_atualizacao
				else 
					if [[ $opcao = "N" ]] || [[ $opcao = "n" ]]
					then
						echo "Realizou o estorno? (S/N)"
						read op_dislike
						if [[ $op_dislike = "S" ]] || [[ $op_dislike = "s" ]]
						then
							recebe_atualizacao
							freechains chain '#free_sebo' dislike ${I} --sign=${PRIKEY[$resp]} --why='${PAYLOAD:0:129}:Estorno:${PAYLOAD:137:200}-PIX: $pagto'
							envia_atualizacao
						else
							recebe_atualizacao
							freechains chain '#free_sebo' dislike ${I} --sign=${PRIKEY[$resp]} --why='${PAYLOAD:0:129}:Cancelo:${PAYLOAD:137:200}-PIX: $pagto'
							envia_atualizacao
						fi														                               
					fi
				fi
			fi
		done

}

proposta_venda(){
	gera_keys
	busca_reps
	declare -a LIVROS # Array auxiliar de todos os livros cadastrados 
	## Verificar se este vendedor tem Proposta de compra pendente
	## Lista os blocos que estao aguardando serem admitidos na cadeia : Compras efetivadas
	if [[ $REPUTACAO > 0 ]]
	then  
	        admite_proposta_compra
	fi
	## Inclui nova proposta de venda
	echo "Deseja incluir Livro? (S/N)"
	read opcao
	if [[ $opcao = "S" ]] || [[ $opcao = "s" ]]  
	then
		clear
		echo "Entre com o nome do livro: "
		read livro
		echo "Entre com o valor: "
		read preco
		echo "Entre com dados da conta PIX:"
		read pix
		echo " Confirme os dados antes de gravar:"  
		echo "Livro: " $livro
		echo "Preco: " $preco
		echo "Pix :" $pix

		echo "Quer gravar? (S/N)"
		read opcao
		if [ $opcao = "S" ] || [ $opcao = "s" ]  
		then  
			posta_venda
		else 
			exit
		fi
	else
		exit
	fi
}

lista_livros() {
	sistema=""
	rm -f /tmp/livro.menu
	touch /tmp/livro.menu
	echo "#/bin/bash" >> /tmp/livro.menu
	echo 'sistema=$(dialog --menu " Escolha o livro " 0 0 0 \' >> /tmp/livro.menu 
	for I in ${CADEIA[*]} 
    	do   
		L=${I:1:1}
		if [[ $L = "_" ]]
		then 
			L=${I:0:1}
		else
			L=${I:0:2}
		fi
		LIVRO=$(freechains chain '#free_sebo' get payload ${I})
		if [[ $LIVRO = "" ]] 
		then
			continue
		else
			echo ${I:0:5} '"' ${LIVRO:130:300} '" \'	>> /tmp/livro.menu
		fi
	done 
	echo ' --stdout)' >> /tmp/livro.menu 
	echo 'echo $sistema' >> /tmp/livro.menu
	chmod ugo+x /tmp/livro.menu
	resultado=$(/tmp/livro.menu)
}

proposta_compra() {

	## Gera as chaves publicas e privadas
	gera_keys
	## Busca reputacao
	busca_reps
	## Lendo a cadeia #free_sebo ##
	echo " Buscando lista de livros, aguarde ..."
	echo " "
	echo " "
	CADEIA=($(freechains --host=localhost:${HOSTS[$HOST]} chain '#free_sebo' consensus))
	if [ ${#CADEIA[@]} = 0 ]     
	then  # nada a fazer
		clear
		echo "CADEIA VAZIA"     
		return
	else  
		lista_livros
                codigo=$resultado
		for I in ${CADEIA[*]}
    		do   
			PAYLOAD=$(freechains chain '#free_sebo' get payload ${I})
			J=${I:0:5}
			if [[ "$codigo" = "$J" ]] 
			then	
				pagto=$(dialog --inputbox "Digite comprovante do PIX" 0 0 --stdout)
				clear
				recebe_atualizacao
				freechains --host=localhost:${HOSTS[$resp]} chain '#free_sebo' post inline "${PAYLOAD:0:129}:Vendido $J:${PAYLOAD:137:200}-PIX: $pagto" --sign=${PRIKEY[$resp]}
        			envia_atualizacao
			fi	
		done  
	fi
}


admite_proposta_venda() {
	## Lista os blocos que estao aguardando serem admitidos na cadeia : Compras efetivadas
	BLOCKEDS=($(freechains chain '#free_sebo' heads blocked))
	if [ ${#BLOCKEDS[@]} = 0 ]
	then  # nada a fazer
		echo "Nao temos proposta de vendas pendentes para liberacao"
		echo "tecle ENTER para sair"
	        read	
		return
	else
		for I in ${BLOCKEDS[*]}
		do
			PROPOSTA=$(freechains chain '#free_sebo' get payload ${I})
			if [[ ${PROPOSTA:130:5} = "Livro" ]] 
			then 
				echo "$PROPOSTA"
				echo "Deseja validar proposta de venda? (S/N)"
				read op_venda
				if [[ $op_venda = "S" ]] || [[ $op_venda = "s" ]]  
				then
					freechains chain '#free_sebo' like ${I} --sign=${PRIKEY[$resp]} 
					envia_atualizacao
				else 
					freechains chain '#free_sebo' dislike ${I} --sign=${PRIKEY[$resp]} 
					envia_atualizacao
				fi
			else
				echo "$PROPOSTA"
				echo "Deseja validar proposta de compra pendentes? (S/N)"
                        	read op_valida
			        if [[ $op_valida = "S" ]] || [[ $op_valida = "s" ]]
				then
					freechains chain '#free_sebo' like ${I} --sign=${PRIKEY[$resp]}
					envia_atualizacao
				fi
			fi
		done
	fi
}

banca() {
	gera_keys
	CADEIA=($(freechains --host=localhost:${HOSTS[$HOST]} chain '#free_sebo' consensus))
	if [ ${#CADEIA[@]} = 0 ]
	then  
		# Criar cadeia (FREE_SEBO)
		echo "Inicia criacao do Forum #free_sebo"
		freechains chains join '#free_sebo' ${PUBKEY[0]}
		freechains chain '#free_sebo' post inline "${PUBKEY[$resp]}-${KY_BANCA[0]}:Este espaco foi criado para venda e compra de livros usados." --sign=${PRIKEY[0]}
		freechains chain '#free_sebo' post inline "${PUBKEY[$resp]}-${KY_BANCA[0]}:-Banca: Rio Branco 256 - Centro" --sign=${PRIKEY[0]}
	else  
		# Neste caso a cadeia ja foi criada e a Banca ira admitir Vendedores, verificasse a Reputacao da Banca
		busca_reps
        	if [[ $REPUTACAO < 1 ]]
	     	then  # nada a fazer
   			return
        	else     
			admite_proposta_venda
		fi
 	fi
}



monta_menu() {
SYSTEM=$(dialog --title 'FreeChains - Users' --default-item '0' --menu ''   0 0 0\
		0 ${USUARIOS[0]} \
	        1 ${USUARIOS[1]} \
	        2 ${USUARIOS[2]} \
		3 ${USUARIOS[3]} \
		4 ${USUARIOS[4]} --stdout)      

	resp=$SYSTEM
}

saia() {
	exit
}

##############################o#
##### PROCEDURE PRINCIPAL  #####
################################

declare -a USUARIOS=(Banca Vendedor1 Vendedor2 Comprador1 Comprador2)
declare -a HOSTS=(8330 8331 8332 8333 8334)
declare -a KEYS     # Array auxiliar do processo de geração de chaves
declare -a PUBKEY   # Array com as chaves públicas
declare -a PRIKEY   # Array com as chaves privadas
declare -a HOSTS    # Array com as portas dos hosts
declare -a BLOCKEDS # Array para guarda temporária dos blocos bloqueados
declare -a ASKS     # Array para guarda temporária dos blocos para interação
declare -i EPOCH    # Tempo base da simulação
declare -i TEMPO    # Base temporal para a simulação
declare -i HOST     # Índice do array HOSTS, indica o host a ser utilizado
declare -a CADEIA   # Array com os blocos na cadeia
declare -a PAYLOAD  # Array com os blocos na cadeia
TEMP=/tmp/choice.tmp

sobe_hosts
monta_menu

##echo $resp  ${USUARIOS[$resp]}  ${HOSTS[$resp]}
clear
case $resp in
     0) banca;;
     1) proposta_venda ;;
     2) proposta_venda ;;
     3) proposta_compra;;
     4) proposta_compra;;
     9) saia
esac	
clear
parar_hosts
exit


