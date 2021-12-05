package dataStructures;

import javax.lang.model.element.Element;

public class BSTKeyOrderIterator<K,V> implements BSTIterator{

    private BSTNode<K,V> node;
    private Stack<BSTNode> stack;
    private int currentSize;

    public BSTKeyOrderIterator(BSTNode<K,V> root) {
        this.node = root;
        stack = new StackInArray<>();
        currentSize = 0;
    }

    @Override
    public boolean hasNext() {
        return node.getLeft().isLeaf();
    }

    @Override
    public BSTNode<K,V> next() {
        BSTNode<K,V> e = stack.pop();
        stack.push(node));
        return e;
    }

    @Override
    public void rewind() {

    }

    private BSTNode<K,V> allLeft(BSTNode<K,V> node){
        BSTNode<K,V> newNode = ;
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
