import java.util.ArrayList;
import java.util.Collections;
import java.io.IOException;
import java.util.Arrays;
import java.io.File;
import java.io.PrintWriter;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class Selection {
    public static void main(String[] args) throws IOException{
		  File file = new File(args[0]);
		  String firLine = "placeholder";
		  String[] secLine = {"ye", "be"};
		  int lineit = 1;

		  try {
				Scanner sc = new Scanner(file);

				while (sc.hasNextLine() && lineit < 3) {
					 if(lineit == 1){
						  firLine = sc.nextLine();
						  lineit++;
					 }
					 else if(lineit == 2){
						  String myLine = sc.nextLine();
						  secLine = myLine.split("\\s");
						  lineit++;
					 }
				}
				sc.close();
		  }
		  catch (FileNotFoundException e) {
				e.printStackTrace();
		  }
		  
		  if(lineit != 3){
				System.out.println("Error, exiting");
				System.exit(0);
		  }
		  
		  int[] results = new int[secLine.length];
		  for (int i = 0; i < secLine.length; i++) {
				try {
					 results[i] = Integer.parseInt(secLine[i]);
				} catch (NumberFormatException nfe) {
				};
		  }
		  int index = Integer.parseInt(firLine);
		  
		  ArrayList<Integer> arr = new ArrayList<Integer>();
		  for (int id = 0; id < results.length; id++){
				arr.add(results[id]);
		  }
		  
        int ind = quickSort(arr, 0, arr.size() - 1, index);
		  
		  PrintWriter writer = new PrintWriter("output.txt", "UTF-8");
		  writer.println(ind);
		  writer.close();
    }

    /* low  --> Starting index,  high  --> Ending index */
    public static int quickSort(ArrayList<Integer> arr, int low, int high, int k)
    {
        if (low < high)
        {
            int pi = partition(arr, low, high);

            if(pi == k-1){
                return arr.get(pi);
            }
            else if (pi > k-1){
                return quickSort(arr, low, pi - 1, k);
            }
            else{
                return quickSort(arr, pi + 1, high, k);
            }
        }
        return -1;
    }

    public static int partition (ArrayList<Integer> arr, int low, int high)
    {
        int pivot = arr.get(high);

        int i = low - 1;  // Index of smaller element

        for (int j = low; j < high; j++)
        {
            // If current element is smaller than or
            // equal to pivot
            if (arr.get(j) <= pivot) {

                i++;    // increment index of smaller element
                //System.out.println("i: "+i+" j: "+j);
                Collections.swap(arr, i, j);
                printArray(arr);

            }
        }
        //System.out.println("i+1: "+(i+1)+" high: "+high);
        Collections.swap(arr, i+1, high);
        return (i + 1);
    }

    private static void printArray(ArrayList<Integer> arr) {
        for (int i = 0; i < arr.size(); i++) {
            //System.out.print(arr.get(i)+" ");
        }
        //System.out.println("");
    }




}
