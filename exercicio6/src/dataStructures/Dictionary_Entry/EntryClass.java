package dataStructures.Dictionary_Entry;

public class EntryClass<K,V> implements Entry {

    private K key;
    private V value;

    public EntryClass(K key,V value) {
        this.key = key;
        this.value = value;
    }

    @Override
    public K getKey() {
        return this.key;
    }

    @Override
    public V getValue() {
        return this.value;
    }

    public void setKey(K key){ this.key = key; }

    public void setValue(V value){ this.value = value; }

    /** DoubleListNode<Entry<K, V>> head;
     * DoubleListNode<Entry<K, V>> tail;
     * private int currentSize;
     *
     * public OrderedDoubleList()
     *      DEMO CONSTRUTOR
     *      head = null;
     *      tail = null;
     *      currentSize = 0
     *
     *      EXEMPLO FUNCIONAMENTO
     *      head.getElement retorna value
     *      .getKey retorna key
     *      .comparteTo para comparaar keys
     */
}
