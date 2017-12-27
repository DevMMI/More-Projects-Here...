import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Map;
import java.util.HashMap;
import java.io.PrintWriter;
import java.util.Set;

public class HuffmanCode {
    private static char defaultChar = '}';
    private static boolean debug = false;
    public static void main(String[] args) throws IOException{
		  String arg = args[0];
        String contents = new String(Files.readAllBytes(Paths.get(arg)));
        //System.out.println(contents);
        Map<Character, Integer> map = new HashMap<Character, Integer>();


        for (int i = 0; i < contents.length(); i++){
            char c = contents.charAt(i);
				if(c != '\n'){
         	   if(map.containsKey(c)){
         	       map.put(c, map.get(c) + 1);
         	   }
				  else{
            	    map.put(c, 1);
          	  }
				}
        }

        if(debug) {
            System.out.println("\n\nMap");
            Set mykeys = map.keySet();
            for (Object key : mykeys) {
                char myKey = (Character) key;
                int val = (Integer) map.get(myKey);
                //System.out.println("key: "+myKey+" val: "+val);
            }
        }

        Character smallest = smallestKey(map);
        int smallestValue = map.get(smallest);
        map.remove(smallest);
        Character secondSmallest = smallestKey(map);
        int secondSmallestValue = map.get(secondSmallest);
        map.remove(secondSmallest);
        ValueNode smallestNode = new ValueNode(smallest, smallestValue);
        ValueNode secondSmallestNode = new ValueNode(secondSmallest, secondSmallestValue);
        NumNode firstNumNode = new NumNode(smallestNode, secondSmallestNode);

        Node top = buildTree(map, firstNumNode);

        PrintWriter writer = new PrintWriter("output.txt", "UTF-8");
        outputHuffman(writer, top, 0);
        //spillTree(top);
        writer.close();

    }

    public static void spillTree(Node top){
        NumNode topNode = (NumNode) top;

        if(topNode.getLeftChild().getType().equals("value")){
            ValueNode left = (ValueNode)topNode.getLeftChild();
            ValueNode right = (ValueNode)topNode.getRightChild();
            System.out.println("key: " + right.getValue() + " value: " + right.getIntValue());
            System.out.println("key: " + left.getValue() + " value: " + left.getIntValue());
            return;
        }

        ValueNode right = (ValueNode)topNode.getRightChild();
        System.out.println("key: " + right.getValue() + " value: " + right.getIntValue());
        spillTree(topNode.getLeftChild());

    }

    public static void outputHuffman(PrintWriter file, Node top, int edgesRidden){
        //writer.println("The first line");

        NumNode topNode = (NumNode) top;

        if(topNode.getLeftChild().getType().equals("value")){
            ValueNode left = (ValueNode)topNode.getLeftChild();
            file.print(left.getValue());
            file.print(':');
            surfEdges(file, edgesRidden);
            file.print(1);
            file.print("\n");

            ValueNode right = (ValueNode)topNode.getRightChild();
            file.print(right.getValue());
            file.print(':');
            surfEdges(file, edgesRidden);
            file.print(0);
            file.print("\n");
            return;
        }

        ValueNode right = (ValueNode)topNode.getRightChild();
        file.print(right.getValue());
        file.print(':');
        surfEdges(file, edgesRidden);
        file.print(0);
        file.print("\n");
        outputHuffman(file, topNode.getLeftChild(), edgesRidden + 1);
    }

    public static void surfEdges(PrintWriter file, int edgesRidden){
        for(int i = 0; i < edgesRidden; i++){
            file.print(1);
        }
    }

    public static Node buildTree(Map<Character, Integer> map, Node highestNumNode){
        char smallest = smallestKey(map);
        if(smallest == defaultChar){
            //System.out.println("Completed");
            return highestNumNode;
        }
        int smallestValue = map.get(smallest);
        map.remove(smallest);

        NumNode myNumNode = (NumNode) highestNumNode;
        int numNodeVal = myNumNode.getValue();
        ValueNode newNode = new ValueNode(smallest, smallestValue);
        NumNode newNumNode = new NumNode(highestNumNode, newNode);

        Node finalNode = buildTree(map, newNumNode);
        return finalNode;
    }

    public static Character smallestKey(Map<Character, Integer> map){
        Character smallest = defaultChar; // placeholder character
        Set keys = map.keySet();
        for(Object key: keys){
            char myKey = (Character) key;
            int val = (Integer) map.get(myKey);

            if(smallest == '}'){
                smallest = myKey;
            }
            else{
                if(val < map.get(smallest)){
                    smallest = myKey;
                }
            }
        }

        //System.out.println(smallest);
        return smallest;
    }
}


class Node{
    private String type = "value";

    public String getType(){
        return type;
    }
}
class NumNode extends Node{
    private int value;
    private Node leftChild = new EmptyNode();
    private Node rightChild = new EmptyNode();
    private String type = "num";

    // initializers
    public NumNode(Node left, Node right){
        leftChild = left;
        rightChild = right;
    }
    public NumNode(){}

    // Queries
    public boolean hasLeftChild(){
        if (this.leftChild.getType().equals("empty")){
            return false;
        }
        else{
            return true;
        }
    }

    public boolean hasRightChild(){
        if (this.rightChild.getType().equals("empty")){
            return false;
        }
        else{
            return true;
        }
    }

    // Setters
    public void setLeftChild(Node child){
        leftChild = child;
    }
    public void setRightChild(Node child){
        rightChild = child;
    }

    // Getters
    public Node getLeftChild(){
        return leftChild;
    }

    public Node getRightChild(){
        return rightChild;
    }
    public String getType(){
        return type;
    }
    public int getValue(){
        return value;
    }
}

class ValueNode extends Node{
    private String type = "value";
    private Character value;
    private int intValue;

    public ValueNode(Character val, int intVal){
        value = val;
        intValue = intVal;
    }

    public String getType(){
        return type;
    }
    public int getIntValue(){
        return intValue;
    }
    public Character getValue(){
        return value;
    }
}

class EmptyNode extends Node{
    private String type = "empty";

    public EmptyNode(){}
    public String getType(){
        return type;
    }
}
