package dataStructures.Dictionary_Entry;

import dataStructures.*;
import dataStructures.Dictionary;

import javax.lang.model.element.Element;

/**
 * Separate Chaining Hash table implementation
 * @author AED  Team
 * @version 1.0
 * @param <K> Generic Key, must extend comparable
 * @param <V> Generic Value 
 */

public class SepChainHashTable<K extends Comparable<K>, V> 
    extends HashTable<K,V> {
    /**
     * Serial Version UID of the Class.
     */
    static final long serialVersionUID = 0L;

    /**
     * The array of dictionaries.
     */
    protected dataStructures.Dictionary<K, V>[] table;


    /**
     * Constructor of an empty separate chaining hash table,
     * with the specified initial capacity.
     * Each position of the array is initialized to a new ordered list
     * maxSize is initialized to the capacity.
     *
     * @param capacity defines the table capacity.
     */
    @SuppressWarnings("unchecked")
    public SepChainHashTable(int capacity) {
        int arraySize = HashTable.nextPrime((int) (1.1 * capacity));
        // Compiler gives a warning.
        table = (dataStructures.Dictionary<K, V>[]) new Dictionary[arraySize];
        for (int i = 0; i < arraySize; i++)
            //TODO: Original comentado para nao dar erro de compilacao.
            table[i] = new OrderedDoubleList<K,V>();
            //table[i] = null;
        maxSize = capacity;
        currentSize = 0;
    }


    public SepChainHashTable() {
        this(DEFAULT_CAPACITY);
    }

    /**
     * Returns the hash value of the specified key.
     *
     * @param key to be encoded
     * @return hash value of the specified key
     */
    protected int hash(K key) {
        return Math.abs(key.hashCode()) % table.length;
    }

    @Override
    public V find(K key) {
        return table[this.hash(key)].find(key);
    }

    @Override
    public V insert(K key, V value) {
        if (this.isFull()){
            this.rehash();
            return null;
        }
        //TODO: Left as an exercise.
        dataStructures.Dictionary<K, V> d = table[this.hash(key)];
        d.insert(key,value);
        return value;
    }

    @Override
    public V remove(K key) {
        dataStructures.Dictionary<K, V> d = table[this.hash(key)];
        d.remove(key);
        return d.find(key);
    }

    @Override
    public Iterator<Entry<K, V>> iterator() {
        //TODO: Left as an exercise.
        return null;
    }

    private void rehash(){
        resize();
        Iterator<Entry<K,V>> it = this.iterator();
        if (it.hasNext()){
            while (it.hasNext()){
                hash(it.next().getKey());
            }
        }
    }

    private void resize(){
        //size = currentSize*2;
    }
    //APAGAR
    /*private boolean equalKeys(Dictionary d1, Dictionary d2){
        Iterator it1 = d1.iterator();
        Iterator it2 = d2.iterator();
        boolean equal = false;
        if (it1.hasNext() && it2.hasNext()){
            while(it1.hasNext() && it2.hasNext()){
                 Entry <K,V> e = (Entry<K, V>) it1.next();
                 Entry<K,V> e2 = (Entry<K, V>) it2.next();
                 if (e.getKey().compareTo(e2.getKey()) != 0)
                     equal = false;
                 equal = true;
            }
        }
        return equal;
    }*/
}

