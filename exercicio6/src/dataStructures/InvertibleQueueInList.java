package dataStructures;

public class InvertibleQueueInList<E> implements Queue<E> {

    private boolean order;
    protected List<E> list;


    public InvertibleQueueInList(){
        list = new DoubleList<>();
        order = true;
    }

    @Override
    public boolean isEmpty() {
        return list.isEmpty();
    }

    @Override
    public int size() {
        return list.size();
    }

    @Override
    public void enqueue(E element) {
        if (order)
            list.addLast(element);
        else
            list.addFirst(element);
    }

    @Override
    public E dequeue() throws EmptyQueueException {
        if (list.isEmpty())
            throw new EmptyQueueException();
        if (order)
            return list.removeFirst();
        else
            return list.removeLast();
    }

    public void invert(){
        if(order)
            order = false; //do fim para o inicio
        else
            order = true; //do inicio para o fim
    }
}
