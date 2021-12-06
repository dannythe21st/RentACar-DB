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
        stack.push(runBranch(nextToReturn));
        return e;
    }

    @Override
    public void rewind() {
        this.nextToReturn = node;
    }

    private BSTNode<K,V> runBranch(BSTNode<K,V> node){
        BSTNode<K,V> newNode = node;
        while(!newNode.isLeaf()){
            newNode = allLeft(node);
            if (newNode.getRight() != null)
                newNode = stepRight(node);
        }
        return newNode;
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
