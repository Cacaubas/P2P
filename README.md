# P2P
## Manual da Aplicação de venda de livros usados: Free_sebo
#
<b>I.	Introdução </b>

A cadeia free_sebo é criada com objetivo de prover o livre comércio de livros usados.

Assim que é criada somente o criador possui reputação suficiente para prover o crescimento da mesma, e o faz através do aceite dos Vendedores. 
A partir do momento que o vendedor tem sua proposta de venda aceita, passa a ter reputação para aceite de proposta de compra.
O Comprador, uma vez realizando a proposta de compra do exemplar, precisa efetuar a transferência pix e encaminhar o código ao vendedor. 
O vendedor faz o aceite na cadeia, e caso não aceite, porque nao reconhece o pagamento, ou porque ja tenha vendido e neste caso realiza o estorno.

<b>II.	Funcionamento da aplicação</b>

1.	A primeira etapa é o carregamento dos hosts, delimitados as portas 8330, 8331 , 8332, 8333 e 8334 e associados ao array HOSTS. O carregamento 
é realizado através da chamada de função sobe_hosts() que chama o comando freechains abaixo:
  ~$ > freechains-host --port=${HOSTS[$I]} start /tmp/simul/${USUARIOS[$resp]}

2.	Após carregar os hosts é montado o menu principal com os perfis de usuários, através da função monta_menu()
O menu é montado através de uma instrução Dialog, que carrega a lista de cinco usuários (Banca, Vendedor1, Vendedor2,  Comprador1 
e Comprador2), associados ao array USUARIOS.

3.  Esta aplicação tem três funções que atende aos cinco perfis citados.

  As chamadas as funções banca(), proposta_venda() (Vendedor 1 e 2) e proposta_compra (Comprador 1 e 2), chamam as funções de criação de chaves públicas
  e privadas e verificação de reputação do usuário, através das funções gera_keys() e busca_reps(), respectivamente.

  a.	A opção Banca é responsável pela criação da cadeia free_sebo, e tem inicialmente reputação igual a 30, passa a ser responsável também pelo aceite
  das Propostas de venda de livros, quando o usuário Vendedor ainda não possui reputação. Esta função é realizada através das funções, banca() e
  admite_proposta_venda( ).
  Na função banca(), no momento da criação, o pioneiro posta mensagens de boas-vindas e orientações de uso. Quando a cadeia já está criada esta função
  chama a admite_proposta_venda(), onde verifica os blocos que aguardam admissão a cadeia, e através de likes e dislikes, admite ou recusa o Vendedor.

  b.	A opção Vendedor, através da função proposta_venda(), faz a chamada para preenchimento e validação dos campos relativos a venda do exemplar:
  
  Os campos a serem preenchidos na proposta de venda são:
  -	Nome do livro
  -	Valor de venda
  -	PIX (mecanismo de pagamento)

  Obs .: A informação da Banca é preenchida automaticamente com a chave pública da banca.

  Após o preenchimento destes campos é feita a chamada da função posta_venda(), que guarda no bloco as seguintes informações, no comando freechains:
  A chave pública do vendedor e da banca, o nome do livro, valor de venda e código pix a ser utilizado no deposito.

    ~$ >  freechains --host=localhost:${HOSTS[$resp]} chain '#free_sebo' post inline "${PUBKEY[$resp]}-${KY_BANCA[0]}:Livro: $livro , Preco: $preco, 
    PIX: $pix" --sign=${PRIKEY[$resp]}

  Antes da postagem é realizada a chamada a função recebe_atualizacao() para que este host receba as atualizações dos demais hosts, e após as postagens 
  chama a função envia_atualizacao() para que os demais hosts sejam notificados das atualizações do host do Vendedor.

  Na função proposta_venda() também é realizado o aceite das propostas de compra, através de likes e dislikes. Nesta função são carregadas as propostas 
  para o Vendedor organizadas pela busca dos blocos iniciados pela chave publica do Vendedor.

  c.	A opção Comprador é a que realiza a compra dos livros, através das funções proposta_compra() e lista_livros(). 
  Nesta função foi implementado carregamento de menu atrves de comando shell script Dialog. 
  Nas primeiras compras, este usuário não possui reputação suficiente e suas solicitações depende da reputação do Vendedor ou da banca para serem incluídas e 
  aceitas na cadeia free_sebo. 

  Assim que a função proposta_compra() e chamada ela chama a função lista_livros() que exibe para o comprador a lista de livros disponíveis. 
  
  Na função proposta_compra() são incluídas as informações abaixo conforme indicado no comando freechains:

  ~$ > freechains --host=localhost:${HOSTS[$resp]} chain '#free_sebo' post inline "${PAYLOAD:0:129}:Vendido:${PAYLOAD:137:200}-PIX: $pagto"
  --sign=${PRIKEY[$resp]}

  A variável PAYLOAD é usada para leitura dos dados armazenados nos blocos.
  Antes da postagem é realizada a chamada a função recebe_atualizacao() para que este host receba as atualizações dos demais hosts e após as postagens 
  a chamada a função envia_atualizacao() para que os demais hosts sejam notificados das atualizações do host deste Comprador.

  A cada fechamento de perfil é finalizada a aplicação e derrubado a conexão dos hosts através da função parar_hosts().

<b>III.	Propostas de melhorias </b>

1.	Não foi implementada rotina para inclusão de outras bancas.
2.	Não foi realizado o tratamento dos conteúdos dos blocos para filtrar os livros já comprados, não exibindo na lista para os futuros compradores.
Para minimizar esta falta, o conteúdo dos blocos indica Livro, para exemplares disponiveis e o Vendido e código do pagamento, como indicativo de 
livro comprado.
3. Desenvolvimento de menus para os perfis Vendedor e Banca, conforme feito para Comprador.
4. Desenvolvimento da aplicacao em uma linguagem de programação mais amigável.

<b>IV.	Ferramentas utilizadas</b>

Foi utilizado os comandos via Shell script, com menus Dialog, e editor de linha vi Linux, conforme script <b>free_sebo.sh</b>


