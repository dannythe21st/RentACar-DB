import java.util.Scanner;

import dataStructures.*;

public class Main {

	private static final String ENQUEUE = "ENQ";
	private static final String DEQUEUE = "DEQ";
	private static final String DEQUEUE_ALL = "DEQ-ALL";
	private static final String INVERT = "INVERT";
	private static final String EXIT = "XS";

	private static final String ENQUEUE_OK = "Enqueue efectuado com sucesso.";
	private static final String DEQUEUE_OK = "Dequeue efectuado com sucesso.";
	private static final String EMPTY_QUEUE = "Fila vazia.";
	private static final String DEQUEUE_ALL_OK = "Dequeue de todos os elementos da fila:";
	private static final String INVERT_OK = "Inversao da fila efectuada com sucesso.";


	private static final String DATA_FILE = "storedqueue.dat";

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		InvertibleQueueInList<Integer> queue = load();
		Scanner in = new Scanner(System.in);
		String cmd = in.next().toUpperCase();
		while (!cmd.equals(EXIT)) {
			switch (cmd) {
			case ENQUEUE :
				enqueue(in, queue);
				break;
			case DEQUEUE :
				dequeue(in, queue);
				break;
			case INVERT:
				invert(in, queue);
				break;
			case DEQUEUE_ALL : 
				dequeueAll(in, queue);
			default: 
				break;
			}
			System.out.println();
			cmd = in.next().toUpperCase();
		}
		save(queue);
	}
	
	private static void enqueue(Scanner in, InvertibleQueueInList<Integer> queue) {
		int element = in.nextInt(); 
		in.nextLine();
		queue.enqueue(element);
		System.out.println(ENQUEUE_OK);
	}

	private static void dequeue(Scanner in, InvertibleQueueInList<Integer> queue) {
		try {
			int element = queue.dequeue();
			System.out.println(element);
			System.out.println(DEQUEUE_OK);
		}
		catch (EmptyQueueException E) {
			System.out.println(EMPTY_QUEUE);
		}
	}

	private static void invert(Scanner in, InvertibleQueueInList<Integer> queue) {
		queue.invert();
		System.out.println(INVERT_OK);
	}

	private static void dequeueAll(Scanner in, InvertibleQueueInList<Integer> queue) {
		if (queue.isEmpty())
			System.out.println(EMPTY_QUEUE);
		else {
			System.out.println(DEQUEUE_ALL_OK);
			while (!queue.isEmpty())
				System.out.println(queue.dequeue());
		}
	}

	private static void save(InvertibleQueueInList<Integer> queue) {
		//COMPLETAR
	}

	private static InvertibleQueueInList<Integer> load() {

		return null;
	}
}
