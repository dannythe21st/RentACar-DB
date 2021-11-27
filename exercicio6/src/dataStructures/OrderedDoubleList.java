package dataStructures;

import dataStructures.Dictionary_Entry.*;


public class OrderedDoubleList<K extends Comparable<K>,V> implements OrderedDictionary<K,V>{

    private DoubleList.DoubleListNode<Entry<K,V>> head;
    private DoubleList.DoubleListNode<Entry<K,V>> tail;
    private int currentSize;

    public OrderedDoubleList() {
        this.head = null;
        this.tail = null;
        this.currentSize = 0;
    }

    @Override
    public boolean isEmpty() {
        return this.currentSize == 0;
    }

    @Override
    public int size() {
        return this.currentSize;
    }

    @Override
    public V find(K key) {
        DoubleList.DoubleListNode<Entry<K,V>> node2 = null;
        boolean bool = false;
        DoubleList.DoubleListNode<Entry<K,V>> node = head;
        if (key == head.getElement().getKey()){
            node = head;
        }
        else if (key == tail.getElement().getKey()){
            node = tail;
        }
        else {
            if (node.getElement().getKey() == key && !bool){
                node2 = node.getNext();
                bool = true;
            }
            else
                node.getNext();
        }

        return node2.getElement().getValue();
    }

    @Override
    public V insert(K key, V value) {
        return null;
    }

    @Override
    public V remove(K key) {
        return null;
    }

    @Override
    public Iterator<Entry<K, V>> iterator() {
        return null;
    }

    @Override
    public Entry minEntry() throws EmptyDictionaryException {
        return null;
    }

    @Override
    public Entry maxEntry() throws EmptyDictionaryException {
        return null;
    }
}
