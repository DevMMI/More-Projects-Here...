import java.util.*;
import java.lang.String;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class Automata {
    static ArrayList<Integer> answer = new ArrayList<Integer>();

    public static void main(String[] args)  throws IOException {
        File file = new File(args[0]);
        String pattern = "placeholder";
        String match = "placeholdertwo";
        int lineit = 1;

        try {
            Scanner sc = new Scanner(file);

            while (sc.hasNextLine() && lineit < 3) {
                if(lineit == 1){
                    pattern = sc.nextLine();
                    lineit++;
                }
                else if(lineit == 2){
                    match = sc.nextLine();
                    lineit++;
                }
            }
            sc.close();
        }
        catch (FileNotFoundException e) {
            e.printStackTrace();
        }


        char[] alpha = "abcdefghijklmnopqrstuvwxyz".toCharArray();
        ArrayList<Character> alphabet = new ArrayList<Character>();
        for(char c : alpha) {
            alphabet.add(c);
        }

        String reverse = new StringBuffer(pattern).reverse().toString();

        Map<Key, Integer> transition = computeTransitionFunction(pattern, alphabet);
        Map<Key, Integer> transitiontwo = computeTransitionFunction(reverse, alphabet);

        //spillMap(trans);
        File myFile = new File("output.txt");
        PrintWriter writer = new PrintWriter(myFile, "UTF-8");

        finiteAutomatonMatcher(match, transition, pattern.length());
        finiteAutomatonMatcher(match, transitiontwo, pattern.length());

        for(int j = 0; j < answer.size(); j++){
            if(j+1 == answer.size()){
                writer.print(answer.get(j));
            }
            else{
                writer.print(answer.get(j)+ " ");
            }
        }
        writer.close();

    }

    public static void finiteAutomatonMatcher(String t, Map<Key, Integer> transition, int patternlength ){
        // forward
        int n = t.length();
        int q = 0;
        for(int i = 0; i < n; i++){
            Key k = new Key(q, t.charAt(i));
            q = transition.get(k);
            if(q == patternlength){
                //System.out.println("pattern occurs with shift "+ (i-patternlength + 1));
                answer.add((i-patternlength + 1));

                //break;
            }
        }


    }

    public static Map<Key, Integer> computeTransitionFunction(String p, ArrayList<Character> alphabet){
        Map<Key, Integer> transition = new HashMap<Key, Integer>();
        int m = p.length();

        for(int q = 0; q <= m; q++){
            for(int i = 0; i < alphabet.size(); i++){
                int k = Math.min(m, q+1);
                String toMatch = new String();
                if( q == 0){
                    toMatch = Character.toString(alphabet.get(i));
                }
                else if( q == 1){
                    toMatch = Character.toString(p.charAt(0)) + Character.toString(alphabet.get(i));
                }
                else{
                    toMatch = p.substring(0, q) + Character.toString(alphabet.get(i));
                }
                int l = toMatch.length();
                if ( k == 1){
                    if(!(p.charAt(0) == toMatch.charAt(l-1))){
                        k = k - 1;
                    }
                }
                else {
                    String pat = p.substring(0, k);
                    String tm = toMatch.substring(l - k, l);
                    while (!p.substring(0, k).equals(toMatch.substring(l - k, l))) {
                        k = k - 1;
                    }
                }
                Key key = new Key(q, alphabet.get(i));
                transition.put(key, k);
            }
        }
        return transition;
    }

    public static void spillMap(Map<Key, Integer> trans){
        Set<Key> set = trans.keySet();
        List<Key> list = new ArrayList<Key>(set);
        for(int i = 0; i < list.size(); i++){
            Key k = list.get(i);
            System.out.println(k.getQ() + ", " + k.getA() + " : " + trans.get(k));
        }
    }

}

class Key {

    private int x;
    private char y;

    public Key(int x, char y) {
        this.x = x;
        this.y = y;
    }

    public int getQ(){
        return this.x;
    }

    public char getA(){
        return this.y;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o){
            return true;
        }

        Key key = (Key) o;
        return x == key.x && y == key.y;
    }

    @Override
    public int hashCode() {
        int result = x;
        result = 11 * result + y;
        return result;
    }


}
