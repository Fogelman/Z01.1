/**
 * Curso: Elementos de Sistemas
 * Arquivo: Parser.java
 * Created by Luciano Soares <lpsoares@insper.edu.br>
 * Date: 2/05/2017
 *
 * Adaptado por Rafael Corsi <rafael.corsi@insper.edu.br>
 * Date: 5/2018
 */
package vmtranslator;

import java.io.*;
import java.util.Arrays;
import java.util.Scanner;

/**
 * Encapsula o código de leitura. Carrega as instruções na linguagem de máquina virtual a pilha,
 * analisa, e oferece acesso aos comandos.
 * Além disso, remove todos os espaços em branco e comentários.
 */
public class Parser {

    public String currentCommand = "";  // comando atual
    private String[] arithmetic = {"add","sub","neg","eq","gt","lt","and","or", "not"};
    private BufferedReader fileReader;  // leitor de arquivo
    private Scanner scanner;
    /** Enumerator para os tipos de comandos de Linguagem de Máquina Virtua a Pilha. */
    public static enum CommandType {
        C_ARITHMETIC,      // comandos aritméticos
        C_PUSH,            // comandos de push
        C_POP,             // comandos de pop
        C_LABEL,           // label
        C_GOTO,            // comando goto
        C_IF,              // comando if-goto
        C_FUNCTION,        // declaracao de funcao
        C_RETURN,          // retorno de funcao
        C_CALL             // chamada de funcao
    }

    /**
     * Abre o arquivo de entrada VM e se prepara para analisá-lo.
     * @param file arquivo VM que será feito o parser.
     */
    public Parser(String file) throws FileNotFoundException {
//        this.fileReader = new BufferedReader(new FileReader(file));
        FileInputStream fis = new FileInputStream(file);
        scanner = new Scanner(fis);
    }

    /**
     * Carrega um comando e avança seu apontador interno para o próxima
     * linha do arquivo de entrada. Caso não haja mais linhas no arquivo de
     * entrada o método retorna "Falso", senão retorna "Verdadeiro".
     * @return Verdadeiro se ainda há instruções, Falso se as instruções terminaram.
     */
	public Boolean advance() {
		while(scanner.hasNextLine()) {
			currentCommand = scanner.nextLine();
			String[] instruction = currentCommand.split("//");
			if (instruction.length > 0) {
				if (!instruction[0].isEmpty()) {
					currentCommand = currentCommand.trim();
					return true;
				}
			}
		}
		scanner.close();
		return false;
	}

    /**
     * Retorna o comando "intrução" atual (sem o avanço)
     * @return a instrução atual para ser analilisada
     */
    public String command() {
      return currentCommand;
    }

    /**
     * Retorna o tipo da instrução passada no argumento:
     *  C_PUSH para push, por exemplo push constant 1
     *  C_POP para pop, por exemplo pop constant 2
     * @param  command instrução a ser analisada.
     * @return o tipo da instrução.
     */
    public CommandType commandType(String command) {
    	String[] instruction = command.split(" ");
    	if (instruction[0].equals("push")) {
    		return CommandType.C_PUSH;
    	}
    	else if (instruction[0].equals("pop")) {
    		return CommandType.C_POP;
    	}
    	else if (instruction[0].equals("label")) {
    		return CommandType.C_LABEL;
    	}
    	else if (instruction[0].equals("goto")) {
    		return CommandType.C_GOTO;
    	}
    	else if (instruction[0].equals("if-goto")) {
    		return CommandType.C_IF;
    	}
    	else if (instruction[0].equals("function")) {
    		return CommandType.C_FUNCTION;
    	}
    	else if (instruction[0].equals("return")) {
    		return CommandType.C_RETURN;
    	}
    	else if(instruction[0].equals("call")) {
    		return CommandType.C_CALL;
    	}
    	else if (Arrays.stream(arithmetic).anyMatch(instruction[0]::equals)){
    		return CommandType.C_ARITHMETIC;
    	}
    	else {
    		return null;
    	}

    }


    /**
     * Retorna o primeiro argumento de um comando push ou pop passada no argumento.
     * Se for um comando aritmético, retorna o próprio texto do comando
     * Deve ser chamado somente quando commandType() é diferente de C_RETURN.
     * @param  command instrução a ser analisada.
     * @return somente o símbolo ou o valor número da instrução.
     */
    public String arg1(String command) {
    	String[] instruction = command.split(" ");
    	if (Arrays.stream(arithmetic).anyMatch(instruction[0]::equals)) {
    		return instruction[0];
    	}
    	else {
    		
    		if (instruction.length > 0) {
    			return instruction[1];
    		}
    		else {
    			return null;
    		}
    		
    		
    	}
    	
    	
    }

    /**
     * Retorna o segundo argumento de um comando push ou pop passada no argumento.
     * Deve ser chamado somente quando commandType() é C_PUSH, C_POP, C_FUNCTION, ou C_CALL.
     * @param  command instrução a ser analisada.
     * @return o símbolo da instrução (sem os dois pontos).
     */
    public Integer arg2(String command) {
    	String[] instruction = command.split(" ");
    		
    		if (instruction.length > 1) {
    			return 	Integer.parseInt(instruction[2]);
    		}
    		else {
    			return null;
    		}
    		
    		
    	}
    

    // fecha o arquivo de leitura
    public void close() throws IOException {
		scanner.close();
    }

}
