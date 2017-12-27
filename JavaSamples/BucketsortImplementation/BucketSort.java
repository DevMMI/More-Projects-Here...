import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.io.File;
import java.util.Arrays;
// Working, needs input and output and print walkthrough
public class BucketSort {
	 
	 public static void main(String[] args) throws IOException {
		  String file = new String(args[0]);
		  String contents = new String(Files.readAllBytes(Paths.get(file)));
		  //System.out.println(contents);
		  String[] result = contents.split("\\s");
		  ArrayList<String> s = new ArrayList<String>(Arrays.asList(result));
		  bucketSort(s, 0);
		  
		  PrintWriter writer = new PrintWriter("output.txt", "UTF-8");
		  for(int i = 0; i < s.size() - 1; i++){
				//System.out.println(s.get(i));
				writer.print(s.get(i) + " ");
		  }
		  writer.print(s.get(s.size()-1));
		  
		  writer.close();
	 }
	 
	 public static void spillBucket(ArrayList<String> arr){
		  System.out.println("\nSpilling bucket");
		  int size = arr.size();
		  for(int i = 0; i < size; i++){
				System.out.print(arr.get(i) + " ");
		  }
		  System.out.println(" ");
	 }
	 
	 public static void bucketSort(ArrayList<String> arr, int letterIndToSortBy){
		  Map<Character, ArrayList<String>> buckets = new HashMap<Character, ArrayList<String>>();
		  int bucketsCount = 26;
		  int ind = 0;
		  
		  // Initialize buckets
		  char abc = 'a';
		  for (int i = 0; i <= bucketsCount; i++, abc++){
				buckets.put(abc, new ArrayList<String>());
		  }
		  
		  // Add strings to proper buckets
		  for (int i = 0; i < arr.size(); i++) {
				String arrVal = arr.get(i);
				String lowerCase = arrVal.toLowerCase();
				char letter;
				if(lowerCase.length() == 1){
					 letter = lowerCase.charAt(0);
				}
				else if(lowerCase.length() == 0){ letter = 1;}
				else{
					 letter = lowerCase.charAt(letterIndToSortBy);
				}
				
				if(!(letter < 65 || letter > 90) || !(letter < 97 || letter > 122)){
					 buckets.get(letter).add(arrVal);
				}
				
				
				//System.out.println("char :"+ letter+ " word: "+lowerCase);
		  }
		  
		  // Sort each bucket
		  for(char i = 'a'; i <= 'z'; i++){
				ArrayList<String> bucket = buckets.get(i);
				//spillBucket(bucket);
				if(bucket.size() > 10){
					 bucketSort(bucket, letterIndToSortBy + 1 );
				}else{
					 int size = bucket.size();
					 for (int sortInd = 1; sortInd < bucket.size(); sortInd++){
						  String target = bucket.get(sortInd);
						  bucket.remove(sortInd);
						  int t = -1;
						  for(t = sortInd - 1; t>=0 && (bucket.get(t).compareToIgnoreCase(target) > 0); ){
								// Shift retrieved value over one
								String value = bucket.get(t);
								bucket.add(t+1, value);
								bucket.remove(t);
								t-=1;
						  }
						  
						  bucket.add(t+1, target);
					 }
					 
					 
					 
					 
				}
				for (int j = 0; j < bucket.size(); j++) {
					 arr.set(ind++, bucket.get(j));
				}
				
		  }
		  
	 }
	 
}

