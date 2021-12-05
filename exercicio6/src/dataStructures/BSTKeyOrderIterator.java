package dataStructures;

public class BSTKeyOrderIterator<K,V> implements BSTIterator{

    private BSTNode<K,V> node;
    private Stack<BSTNode> stack;
    private BSTNode<K,V> nextToReturn;
    private int currentSize;

    public BSTKeyOrderIterator(BSTNode<K,V> root) {
        this.node = root;
        stack = new StackInArray<>();
        this.rewind();
    }

    @Override
    public boolean hasNext() {
        return nextToReturn != null;//node.getLeft().isLeaf();
    }

    @Override
    public BSTNode<K,V> next() {
        BSTNode<K,V> e = stack.pop();
        stack.push(allLeft(node));
        stack.push(stepRight(allLeft(node)));
        return e;
    }

    @Override
    public void rewind() {
        nextToReturn = node;
    }

    private BSTNode<K,V> allLeft(BSTNode<K,V> node){
        BSTNode<K,V> newNode = node;
        while(newNode.getLeft() != null)
            newNode = newNode.getLeft();
        return newNode;
    }

    private BSTNode<K,V> stepRight(BSTNode<K,V> node){
        BSTNode<K,V> newNode = node;
        newNode = newNode.getRight();
        return newNode;
    }
}
