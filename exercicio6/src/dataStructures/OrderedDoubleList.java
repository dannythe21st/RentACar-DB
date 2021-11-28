package dataStructures;

import dataStructures.Dictionary_Entry.*;

import java.util.Map;


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
        DoubleList.DoubleListNode<Entry<K, V>> node = head;
        if (key == head.getElement().getKey()) {
            return head.getElement().getValue();
        }
        else if (key == tail.getElement().getKey()) {
            return tail.getElement().getValue();
        }
        else {
            int i = 0;
            boolean found = false;
            while(i < currentSize && !found){
                if (key == node.getElement().getKey())
                    found = true;
                node = node.getNext();
                i++;
            }
            if (i == currentSize)
                return null;
            return node.getElement().getValue();
        }
    }

    @Override
    public V insert(K key, V value) {
        DoubleList.DoubleListNode<Entry<K,V>> node = head;
        while(!node.getElement().getValue().equals(key) && node != null)
            node = node.getNext();
        if (node == null){
            EntryClass newEntry = new EntryClass(key,value);
            DoubleList.DoubleListNode newNode = new DoubleList.DoubleListNode<Entry<K,V>>(newEntry,tail,null);
            tail.setNext(newNode);
            tail = newNode;
        }
        else if(node.equals(head)){
            DoubleList.DoubleListNode next = head.getNext();
            EntryClass newEntry = new EntryClass(key,value);
            DoubleList.DoubleListNode newNode = new DoubleList.DoubleListNode(newEntry, null, next);
            next.setPrevious(newNode);
        }
        else if (node.equals(tail)){
            DoubleList.DoubleListNode  previous = head.getNext();
            EntryClass newEntry = new EntryClass(key,value);
            DoubleList.DoubleListNode newNode = new DoubleList.DoubleListNode(newEntry, previous, null);
            previous.setPrevious(newNode);
        }
        else{
            DoubleList.DoubleListNode previous = node.getPrevious();
            DoubleList.DoubleListNode next = node.getNext();
            EntryClass newEntry = new EntryClass(key,value);
            DoubleList.DoubleListNode newNode = new DoubleList.DoubleListNode(newEntry, previous, next);
            next.setPrevious(newNode);
            previous.setNext(newNode);
        }
        return node.getElement().getValue();
    }

    @Override
    public V remove(K key) {
        DoubleList.DoubleListNode<Entry<K,V>> node = head;
        while(!node.getElement().getValue().equals(key) && node != null)
            node = node.getNext();
        if (node == null){
            return null;
        }
        else if (node.equals(head)){
            node.getNext().setPrevious(null);
            head = node.getNext();
        }
        else if (node.equals(tail)){
            node.getPrevious().setNext(null);
            tail = node.getPrevious();
        }
        else{
            DoubleList.DoubleListNode previous = node.getPrevious();
            DoubleList.DoubleListNode next = node.getNext();
            previous.setNext(next);
            next.setPrevious(previous);
        }
        return node.getElement().getValue();
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
