//import sun.jvm.hotspot.debugger.posix.elf.ELFException;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.Collections;
import java.util.Scanner;
import java.util.ArrayList;


public class MyPriorityQueue {
    private static boolean debug = false;
    private static boolean regular = !debug;

    public static void buildMaxHeap(ArrayList<Element> A){
        int size = A.size();
        int first = size / 2 - 1;
        //System.out.println("A.size " + size + "first : " + first);
        for(int i = first; i >= 0; i--){
            maxHeapify(A, size, i);
        }

    }

    private static ArrayList<Element> maxHeapify(ArrayList<Element> A, int size, int i){
        ArrayList<Element> queue = A;
        int left = Left(i);
        int right = Right(i);
        int largest = i;
        if (left < size && queue.get(left).getPriority() > queue.get(largest).getPriority()){
            largest = left;
        }
        if (right < size && (queue.get(right).getPriority() > queue.get(largest).getPriority())){
            largest = right;
        }
        if (largest != i){
            exchange(i, largest, queue);
            maxHeapify(A, size, largest);
        }
        return queue;
    }

    public static Element maximum(ArrayList<Element> queue){
        Element max = queue.get(0);
        return max;
    }

    public static void insert(ArrayList<Element> queue, Element a){
        queue.add(a);
        int size = queue.size();
        int first = size / 2 - 1;

        for(int i = first; i >= 0; i--){
            maxHeapify(queue, size, i);
        }

    }

    public static Element extractMax(ArrayList<Element> queue) { // removes and returns the element of S with the largest key.
        Element max = queue.get(0);
        queue.set(0, queue.get(queue.size()-1));
        queue.remove(queue.size()-1);
        maxHeapify(queue, queue.size(), 0);
        return max;
    }

    private static void exchange(int i, int largest, ArrayList<Element> queue) {
        Collections.swap(queue, i, largest);
    }

    // maxheapify helper methods
    private static int Left(int i){
        int inew = i; // account for array starting at 0
        int leftInd = inew * 2 + 1 ;
        return leftInd;
    }

    private static int Right(int i){
        int inew = i; // account for array starting at 0
        int rightInd = (inew * 2) + 2;
        return rightInd;
    }

    private static void printArray(ArrayList<Element> arr){
        for(int i = 0; i < arr.size(); i++){
            System.out.println(arr.get(i).getPriority());
        }
    }

    public static void main(String[] args) throws IOException {
		  if(args.length != 1) {
				System.out.println("Usage ./run.sh input.txt");
				System.exit(0);
		  }
		  File file = new File(args[0]);
				
        ArrayList<Element> maxHeap = new ArrayList<Element>();
        try {

            Scanner sc = new Scanner(file);

            while (sc.hasNextLine()) {
                String line = sc.nextLine();
                String[] words= line.split("\\s");

                String name = words[0];
                String priority = words[2];
                int intPriority = Integer.parseInt(priority);

                Element element = new Element(name, intPriority);
                maxHeap.add(element);
            }
            sc.close();
        }
        catch (FileNotFoundException e) {
            e.printStackTrace();
        }

        // regular code
        if(regular) {
            //printArray(maxHeap);
            File myFile = new File("output.txt");
            PrintWriter writer = new PrintWriter(myFile, "UTF-8");
            buildMaxHeap(maxHeap);

            //System.out.println(maxHeap.size());
            while (maxHeap.size() > 1) {
                Element high = new Element();
                high = extractMax(maxHeap);
                //System.out.println(high+""+maxHeap.size());
                writer.print(high.getName() + " ");
            }
            Element high;
            high = extractMax(maxHeap);
            writer.print(high.getName());
            writer.close();
        }

        // debugging code
        if(debug) {
            Element a = new Element("one", 3);
            Element b = new Element("blue", 4);
            Element c = new Element("green", 1);
            Element d = new Element("two", 8);
            Element e = new Element("have", 11);
            Element f = new Element("havenot", 2);
            Element g = new Element("done", 22);
            Element h = new Element("boo", 7);
            Element i = new Element("too", 94);

            ArrayList<Element> arr = new ArrayList<Element>(Arrays.asList(a, b, c, d, e, f, g, h, i));
            buildMaxHeap(arr);
            printArray(arr);
            System.out.println("\n\n");
            Element top = extractMax(arr);
            System.out.println("top = " + top.getPriority());
            top = extractMax(arr);
            System.out.println("top = " + top.getPriority());
            top = extractMax(arr);
            System.out.println("top = " + top.getPriority());
            top = extractMax(arr);
            System.out.println("top = " + top.getPriority());
            top = extractMax(arr);
            System.out.println("top = " + top.getPriority());
            top = extractMax(arr);
            System.out.println("top = " + top.getPriority());
            top = extractMax(arr);
            System.out.println("top = " + top.getPriority());
            printArray(arr);

            Element m = new Element("blam", 10);
            System.out.println("\nnew Element = " + m.getPriority());
            insert(arr, m);
            printArray(arr);
        }
    }


}


class Element{
    private String name;
    private int priority;

    public Element(String name, int priority){
        this.name = name;
        this.priority = priority;
    }

    public Element(){}

    public String getName(){
        return name;
    }
    public int getPriority(){
        return priority;
    }
}
