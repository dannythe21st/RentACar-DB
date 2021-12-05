package dataStructures;
import java.io.Serializable;

public interface BSTIterator<E> extends Iterator {

    boolean hasNext();

    E next();

    void rewind();
}
