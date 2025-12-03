=============================================================================
           QUEM QUER SER MILIONÁRIO - Jogo em Prolog
=============================================================================

AUTORES: [Seu Nome]
CURSO: Lógica e Inteligência Artificial
UNIVERSIDADE: Universidade do Minho
DATA: Dezembro 2025

=============================================================================
DESCRIÇÃO
=============================================================================

Jogo interativo inspirado no programa televisivo "Quem Quer Ser Milionário",
implementado em Prolog com aplicação de conceitos de programação lógica:

- Programação orientada ao padrão
- Recursividade
- Manipulação de listas e estruturas compostas
- Inferência lógica (Modus Ponens, Modus Tollens, Modus Mistaken)
- Interface textual criativa com ASCII art

=============================================================================
ARQUIVOS DO PROJETO
=============================================================================

milionario.pl   - Código completo do jogo (motor, interface, ajudas, lógica)
perguntas.pl    - Base de conhecimento com 20.923 perguntas
README.txt      - Este arquivo (instruções de uso)

=============================================================================
REQUISITOS
=============================================================================

- SWI-Prolog 8.0 ou superior
- Terminal com suporte a códigos ANSI (para cores)
- Sistema operacional: Linux, macOS ou Windows

=============================================================================
COMO EXECUTAR
=============================================================================

1. Abra o terminal na pasta do projeto

2. Inicie o SWI-Prolog:
   $ swipl

3. Carregue o jogo:
   ?- [milionario].

4. Inicie o jogo:
   ?- jogar.

=============================================================================
COMO JOGAR
=============================================================================

OBJETIVO:
Responda 15 perguntas corretamente para ganhar €1.000.000!

REGRAS:
- Cada pergunta tem 4 opções (A, B, C, D)
- Você pode usar 3 ajudas (uma vez cada):
  * 50/50: Elimina duas respostas incorretas
  * Ajuda do Público: Mostra distribuição percentual de votos
  * Telefone: Consulta um amigo
- Existem 2 patamares de segurança:
  * €1.000 (pergunta 5)
  * €32.000 (pergunta 10)
- Se errar, você leva o valor do último patamar alcançado
- Você pode desistir a qualquer momento e levar o dinheiro acumulado

COMANDOS:
- A, B, C, D: Responder
- H: Usar ajuda
- Q: Desistir (quit)

=============================================================================
CARACTERÍSTICAS TÉCNICAS
=============================================================================

RECURSIVIDADE:
- Loop principal do jogo implementado recursivamente (loop_jogo/3)
- Processamento de escolhas com recursão de cauda
- Seleção de perguntas usando findall/3 e nth0/3

LÓGICA:
- Modus Ponens: Se acertou → progride (aplicar_modus_ponens/0)
- Modus Tollens: Se não progrediu → errou (aplicar_modus_tollens/0)
- Modus Mistaken: Demonstração de falácia lógica (demonstrar_modus_mistaken/0)

ESTRUTURAS DE DADOS:
- Perguntas: pergunta(ID, Nivel, Valor, Texto, [Opcoes], Resposta)
- Listas para gerenciar ajudas disponíveis
- Patamares de segurança com findall/3 e max_list/2

INTERFACE:
- ASCII art para logo e molduras
- Barras de progresso visuais
- Cores ANSI para feedback
- Animações simples (pausas, efeitos)

AJUDAS LÓGICAS:
- 50/50: Usa random_permutation/2 para eliminar 2 incorretas
- Público: Gera distribuição com random/3 e viés para resposta correta
- Telefone: Simula incerteza com probabilidade (70-95% de confiança)

=============================================================================
BASE DE PERGUNTAS
=============================================================================

Total: 20.923 perguntas
Distribuição por nível:
- Nível 1 (€100-500):      4.965 perguntas (Fácil)
- Nível 2 (€1.000-2.000):  4.476 perguntas (Médio)
- Nível 3 (€4.000-8.000):  5.769 perguntas (Médio-Difícil)
- Nível 4 (€16.000-32.000): 4.542 perguntas (Difícil)
- Nível 5 (€64.000-125.000): 913 perguntas (Muito Difícil)
- Nível 6 (€250.000+):       258 perguntas (Milionário)

=============================================================================
EXEMPLOS DE USO
=============================================================================

# Iniciar o jogo
?- jogar.

# Demonstrar regras lógicas
?- demonstrar_logica.

# Ver uma pergunta específica
?- pergunta(1, Nivel, Valor, Texto, Opcoes, Resposta).

# Contar perguntas de um nível
?- findall(1, pergunta(_, 1, _, _, _, _), L), length(L, Count).

=============================================================================
ESTRUTURA DO CÓDIGO
=============================================================================

O arquivo milionario.pl está organizado em seções:

1. CONFIGURAÇÕES DO JOGO
   - Valores monetários por nível (valor_nivel/2)
   - Patamares de segurança (patamar_seguranca/2)
   - Predicados dinâmicos para lógica

2. INTERFACE
   - limpar_tela/0, mostrar_logo/0
   - mostrar_cabecalho/3, mostrar_pergunta/2
   - mostrar_vitoria/1, mostrar_barra_percentual/1

3. SISTEMA DE AJUDAS
   - usar_ajuda/5 (menu de seleção)
   - aplicar_50_50/2
   - aplicar_ajuda_publico/1
   - aplicar_telefone/1

4. REGRAS DE INFERÊNCIA LÓGICA
   - Modus Ponens: implica/2, verdadeiro/1, conclusao/1
   - Modus Tollens: falso/1, conclusao/1
   - Modus Mistaken: conclusao_incorreta/1
   - demonstrar_logica/0

5. MOTOR PRINCIPAL
   - jogar/0 (predicado principal)
   - loop_jogo/3 (loop recursivo)
   - processar_escolha/9
   - verificar_resposta/6
   - selecionar_pergunta/5

=============================================================================
RESOLUÇÃO DE PROBLEMAS
=============================================================================

ERRO: "Undefined procedure"
SOLUÇÃO: Certifique-se de que perguntas.pl está na mesma pasta

ERRO: Caracteres estranhos na tela
SOLUÇÃO: Seu terminal pode não suportar códigos ANSI. Use um terminal
         moderno ou desative as cores no código.

ERRO: "random/3 not defined"
SOLUÇÃO: O SWI-Prolog moderno já inclui random. Se necessário, adicione:
         :- use_module(library(random)).

ERRO: Perguntas com caracteres estranhos
SOLUÇÃO: As aspas já foram escapadas no arquivo perguntas.pl

=============================================================================
CONCEITOS DE PROLOG DEMONSTRADOS
=============================================================================

1. RECURSIVIDADE
   - loop_jogo/3: recursão de cauda para loop principal
   - mostrar_barras/1: recursão para desenhar barras visuais

2. MANIPULAÇÃO DE LISTAS
   - findall/3: buscar todas as perguntas de um nível
   - member/2: verificar se elemento está na lista
   - select/3: remover elemento da lista
   - random_permutation/2: embaralhar lista
   - nth0/3: acessar elemento por índice

3. INFERÊNCIA LÓGICA
   - Regras de implicação (implica/2)
   - Verificação de verdade (verdadeiro/1, falso/1)
   - Conclusões válidas e inválidas

4. PREDICADOS DINÂMICOS
   - assertz/1: adicionar factos temporários
   - retractall/1: remover factos

5. ENTRADA/SAÍDA
   - write/1, writeln/1, format/2
   - read_line_to_string/2
   - Códigos ANSI para formatação

=============================================================================
REGRAS DE INFERÊNCIA EXPLICADAS
=============================================================================

MODUS PONENS (Válido):
  Premissa 1: Se P então Q (resposta_certa → progresso)
  Premissa 2: P é verdadeiro (jogador acertou)
  Conclusão:  Q é verdadeiro (jogador progride)
  
  Aplicação: Quando o jogador acerta, ele avança para próxima pergunta.

MODUS TOLLENS (Válido):
  Premissa 1: Se P então Q (resposta_certa → progresso)
  Premissa 2: Q é falso (jogador não progrediu)
  Conclusão:  P é falso (resposta não estava correta)
  
  Aplicação: Se o jogador não avançou, então errou a resposta.

MODUS MISTAKEN (Falácia - Afirmação do Consequente):
  Premissa 1: Se P então Q (resposta_certa → progresso)
  Premissa 2: Q é verdadeiro (jogador progrediu)
  Conclusão INVÁLIDA: P é verdadeiro (resposta estava correta)
  
  ERRO: O jogador pode ter progredido usando ajudas ou por sorte,
        não necessariamente porque sabia a resposta!

=============================================================================
EXPANSÕES FUTURAS (OPCIONAL)
=============================================================================

- Sistema de ranking com persistência de dados
- Modo de treino (sem perder ao errar)
- Modo competitivo (dois jogadores)
- Perguntas temáticas (ciência, história, etc.)
- Tradução para português das perguntas
- Estatísticas de desempenho

=============================================================================
LICENÇA
=============================================================================

Este projeto foi desenvolvido para fins educacionais como parte da
disciplina de Lógica e Inteligência Artificial da Universidade do Minho.

=============================================================================
CONTACTO
=============================================================================

Para questões ou sugestões, contacte:
[Seu email]

=============================================================================
