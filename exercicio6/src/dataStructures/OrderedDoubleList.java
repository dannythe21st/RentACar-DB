package dataStructures;

import dataStructures.Dictionary_Entry.*;
import dataStructures.DoubleList;

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
        /*while(!node.getElement().getKey().equals(key) && node != tail.getNext())
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
        }*/
        /*while(node.getElement().getKey().compareTo(key) < 0)
            node = node.getNext();
        if (node.equals(head)){
            DoubleList.DoubleListNode newNode = new DoubleList.DoubleListNode(e, null, node.getNext());
            node.getNext().setPrevious(newNode);
            head = newNode;
        }
        else if (head.)
        if (node != null && node.getElement().getKey().compareTo(key) == 0){ //existe um elemento com a key
            Entry e = new EntryClass(key,value);
            if (node.getElement().getKey().compareTo(head.getElement().getKey()) == 0){
                DoubleList.DoubleListNode newNode = new DoubleList.DoubleListNode(e, null, node.getNext());
                node.getNext().setPrevious(newNode);
                head = newNode;
            }
            else if (node.getElement().getKey().compareTo(tail.getElement().getKey()) == 0){
                DoubleList.DoubleListNode newNode = new DoubleList.DoubleListNode(e, node.getPrevious(), null);
                node.getNext().setPrevious(newNode);
                tail = newNode;
            }
            else{
                DoubleList.DoubleListNode newNode = new DoubleList.DoubleListNode(e, node.getPrevious(), node.getNext());
                node.getPrevious().setNext(newNode);
                node.getNext().setPrevious(newNode);
            }
            return node.getElement().getValue();
        }
        else { //inserir elemento novo
            Entry e = new EntryClass(key,value);
            DoubleList.DoubleListNode prev = node.getPrevious();
            DoubleList.DoubleListNode next = node;
            DoubleList.DoubleListNode newNode = new DoubleList.DoubleListNode<Entry<K,V>>(e, prev, next);
            node.setPrevious(newNode);
            return null;
        }*/
        DoubleList.DoubleListNode<Entry<K,V>> node = head;
        Entry e = new EntryClass(key, value);
        while(node.getElement().getKey().compareTo(key) < 0)
            node = node.getNext();
        if (node.getElement().getKey().compareTo(key) == 0){
            if (node == head){
                head = new DoubleList.DoubleListNode<>(e, null, head.getNext());
            }
            else if (node == tail){
                tail = new DoubleList.DoubleListNode<>(e, tail.getPrevious(), null);
            }
            else{
                DoubleList.DoubleListNode<Entry<K,V>> prev = node.getPrevious();
                DoubleList.DoubleListNode<Entry<K,V>> next = node.getNext();
                DoubleList.DoubleListNode<Entry<K,V>> newNode = new DoubleList.DoubleListNode<>(e, prev, next);
                prev.setNext(newNode);
                next.setPrevious(newNode);
                node = null;
            }
            return node.getElement().getValue();
        }
        else{
            DoubleList.DoubleListNode<Entry<K,V>> prev = node.getPrevious();
            DoubleList.DoubleListNode<Entry<K,V>> newNode = new DoubleList.DoubleListNode<>(e, prev, node);
            prev.setNext(newNode);
            node.setPrevious(newNode);
            return null;
        }
    }

    @Override
    public V remove(K key) {
        DoubleList.DoubleListNode<Entry<K,V>> node = head;
        while(node.getElement().getKey().compareTo(key) < 0)
            node = node.getNext();
        if (node.getElement().getKey().compareTo(key) > 0)
            return null;
        else{ //elemento encontrado
            DoubleList.DoubleListNode<Entry<K,V>> prev = node.getPrevious();
            DoubleList.DoubleListNode<Entry<K,V>> next = node.getNext();
            prev.setNext(next);
            next.setPrevious(prev);
            return node.getElement().getValue();
        }
    }

    @Override
    public Iterator<Entry<K, V>> iterator() {
        return new DoubleListIterator<>(head,tail);
    }

    @Override
    public Entry minEntry() throws EmptyDictionaryException {
        return head.getElement();
    }

    @Override
    public Entry maxEntry() throws EmptyDictionaryException {
        return tail.getElement();
    }


    private V coise(K key, V value){
        int i = 0;
        DoubleList.DoubleListNode<Entry<K,V>> node = head;
        Entry e = new EntryClass(key, value);
        while(node.getElement().getKey().compareTo(key) < 0)
            node = node.getNext();
        if (node.getElement().getKey().compareTo(key) == 0){
            if (node == head){
                head = new DoubleList.DoubleListNode<>(e, null, head.getNext());
            }
            else if (node == tail){
                tail = new DoubleList.DoubleListNode<>(e, tail.getPrevious(), null);
            }
            else{
                DoubleList.DoubleListNode<Entry<K,V>> prev = node.getPrevious();
                DoubleList.DoubleListNode<Entry<K,V>> next = node.getNext();
                DoubleList.DoubleListNode<Entry<K,V>> newNode = new DoubleList.DoubleListNode<>(e, prev, next);
                prev.setNext(newNode);
                next.setPrevious(newNode);
            }
            return node.getElement().getValue();
        }
        else{

            DoubleList.DoubleListNode<Entry<K,V>> prev = node.getPrevious();
            DoubleList.DoubleListNode<Entry<K,V>> newNode = new DoubleList.DoubleListNode<>(e, prev, node);
            prev.setNext(newNode);
            node.setPrevious(newNode);
            return null;
        }
    }
}
