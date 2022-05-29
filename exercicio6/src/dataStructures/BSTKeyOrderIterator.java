package dataStructures;

public class BSTKeyOrderIterator<K,V> implements BSTIterator{

    private BSTNode<K,V> node;
    private Stack<BSTNode> stack;
    private BSTNode<K,V> nextToReturn;

    public BSTKeyOrderIterator(BSTNode<K,V> root) {
        this.node = root;
        this.nextToReturn = node;
        stack = new StackInArray<>();
        this.rewind();
    }

    @Override
    public boolean hasNext() { return nextToReturn != null; }

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
        BSTNode<K,V> newNode = nextToReturn;
        while(!newNode.isLeaf()){
            newNode = allLeft(nextToReturn);
            if (newNode.getRight() != null){
                stack.pop();
                newNode = stepRight(nextToReturn);
            }
        }
        return newNode;
    }

    private BSTNode<K,V> allLeft(BSTNode<K,V> node){
        BSTNode<K,V> newNode = nextToReturn;
        while(newNode.getLeft() != null){
            newNode = newNode.getLeft();
            stack.push(newNode);
        }
        return newNode;
    }

    private BSTNode<K,V> stepRight(BSTNode<K,V> node){
        BSTNode<K,V> newNode = node;
        newNode = newNode.getRight();
        stack.push(newNode);
        return newNode;
    }

}
