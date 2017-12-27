import com.sun.org.apache.xpath.internal.operations.Bool;
import org.omg.CORBA.INTERNAL;

import java.io.IOException;
import java.util.*;
import java.lang.String;
import java.io.File;
import java.io.PrintWriter;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class Dijkstra {
    public static void main(String[] args) throws IOException {
        boolean debug = false;
        String[] base = {};
        String[] mat = {};
        ArrayList<String> srcAndDest = new ArrayList<String>();
        ArrayList<String> adjMat = new ArrayList<String>();
        File file = new File(args[0]);
        int matIt = 0;
        int lineIt = 0;

        try {
            int count = countMatrix(file);
            ArrayList<Integer>[] matrix = new ArrayList[count];
            Scanner sc = new Scanner(file);

            while (sc.hasNextLine()) {
                if(lineIt == 0){
                    String pattern = sc.nextLine();
                    base = pattern.split("\\D");
                    for (int j = 0; j < 2; j++) {
                        srcAndDest.add(base[j]);
                    }
                    lineIt++;
                }
                else{
                    String pattern = sc.nextLine();
                    String[] split = pattern.split("\\D");
                    ArrayList thisRow = new ArrayList();
                    for (int j = 0; j < split.length; j++) {
                        //System.out.println(split[j]);
                        int val = Integer.parseInt(split[j]);

                        thisRow.add(val);
                    }
                    matrix[matIt++] = thisRow;
                    lineIt++;
                }
            }
            sc.close();

            if(debug){
                System.out.println("Src and dest");
                spillArray(srcAndDest);

                System.out.println("Matrix");
                for(int i = 0; i < matrix.length; i++){
                 spillArray(matrix[i]);
            } }

            int src = Integer.parseInt(srcAndDest.get(0));
            int dest = Integer.parseInt(srcAndDest.get(1));
            Dijkstra(matrix, src, dest);




        }
        catch (FileNotFoundException e) {
            e.printStackTrace();
        }



    }



    public static int countMatrix(File file){
        int it = 0;
        try {
            Scanner sc = new Scanner(file);
            while (sc.hasNextLine()) {
                String line = sc.nextLine();
                it++;
            }
            sc.close();
        }
        catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        return it-1;
    }

    public static void spillArray(ArrayList e){
        for (int i = 0; i < e.size(); i++){
           // System.out.println(e.get(i));
        }
    }



   public static void Dijkstra(ArrayList<Integer>[] graph, int src, int dest) throws IOException {
       int count = graph[0].size();
       Vertex[] vertices = new Vertex[count];
       Set<Integer> visited = new HashSet<Integer>();
       int counter = 0;
       for(int i = 0; i< vertices.length; i++){
           Vertex v = new Vertex();
           vertices[counter++] = v;
       }


       // Find shortest path for all vertices
       vertices[0].weight = 0;
       int val = src;
       while(val != -1){
           // run it on each vertex (as root)
           val = relax(graph[val], vertices, val);

       }

       spillVertex(vertices, src, dest);
    }

    public static void spillVertex(Vertex[] v, int src, int dest)   throws IOException {
        //System.out.println(v.length);

        for(int i = 0; i< v.length; i++){
            System.out.println("node "+ i + " weight: " + v[i].weight + " via: " + v[i].via);
        }
        ArrayList<Integer> list = new ArrayList<Integer>();

        File myFile = new File("output.txt");
        PrintWriter writer = new PrintWriter(myFile, "UTF-8");
        int hold = Integer.MAX_VALUE;
        writer.print(v[dest].weight + ": ");

        list.add(dest);
        int mydest = dest;
        int timeout = 0;
        while(hold != src && timeout < 100){
            hold = v[mydest].via;
            list.add(hold);
            mydest = hold;

            timeout++;
        }
        while(list.size() != 1){

            writer.print(list.remove(list.size() - 1) + " ");


        }
        writer.print(list.remove(list.size() - 1));
        writer.close();

    }


    public static int relax(ArrayList<Integer> graphRow, Vertex[] vertices, int vertex){
        int minval = Integer.MAX_VALUE;
        int minind = -1;
        for(int i = 0 ; i < graphRow.size(); i++){

            if ((i != vertex && graphRow.get(i) != 2000000)) {
                int vertexe = vertex;
                int edge = graphRow.get(i);
                int vertexWeight = vertices[vertex].weight;
                int currentWeight = vertices[i].weight;

                if(currentWeight == Integer.MAX_VALUE ){
                    Vertex v = new Vertex(graphRow.get(i) , vertex);
                    vertices[i] = v;
                    if(graphRow.get(i) < minval){
                        minval = graphRow.get(i);
                        minind = i;

                    }

                }
                else if(vertexWeight == Integer.MAX_VALUE ){
                    Vertex v = new Vertex(graphRow.get(i) , vertex);
                    vertices[i] = v;
                }
                else if (graphRow.get(i) + vertices[vertex].weight < vertices[i].weight) {
                    Vertex v = new Vertex(graphRow.get(i) + vertices[vertex].weight, vertex);
                    vertices[i] = v;
                    if(graphRow.get(i) + vertices[vertex].weight < minval){
                        minval = graphRow.get(i) + vertices[vertex].weight;
                        minind = i;
                    }
                }

            }
        }
        if (minval == Integer.MAX_VALUE){
            return -1;
        }
        return minind;
    }

}

class Vertex {

    public int weight = Integer.MAX_VALUE;
    public int via = -1;

    public Vertex(int weight, int via) {
        this.weight = weight;
        this.via = via;
    }

    public Vertex(){

    }

}
