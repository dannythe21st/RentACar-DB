package dataStructures;

public class ConcatenableQueueInList<E> extends QueueInList<E> implements ConcatenableQueueInListInterface{

    //private static final serializing

    public void append(ConcatenableQueueInList<E> queue){
        while(queue.size()>0){
            this.enqueue(queue.dequeue());
        }
    }
}
