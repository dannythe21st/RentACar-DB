package dataStructures.Dictionary_Entry;

import dataStructures.Iterator;
import dataStructures.NoSuchElementException;

public class SepChainHashTableIterator implements Iterator {

    public SepChainHashTableIterator() {

    }

    @Override
    public boolean hasNext() {
        return false;
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
