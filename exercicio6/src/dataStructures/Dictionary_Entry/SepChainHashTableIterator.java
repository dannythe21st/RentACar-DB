package dataStructures.Dictionary_Entry;

import dataStructures.*;

public class SepChainHashTableIterator<K extends Comparable<K>, V> implements Iterator {

    private OrderedDoubleList<K,V> nextToReturn;

    public SepChainHashTableIterator() {

    }

    @Override
    public boolean hasNext() {
        return nextToReturn != null;
    }

    @Override
    public Object next() throws NoSuchElementException {
        if (!hasNext())
            throw new NoSuchElementException();
        else{

            return null;
        }
    }

    @Override
    public void rewind() {

    }
}
