
public class OSMain {

    public static void main(String[] args) {
        String baseOrient ="plocal:/Users/duncan/Desktop/orientdb-community-2.0-rc1/databases/";
        OrientBenchmarkingTests obt = new OrientBenchmarkingTests(baseOrient);

        //obt.testLuceneFulltext();
        //obt.testUnique();
        //obt.testNotUnique();
        //obt.testDictionary();
        obt.testFulltext();
    }

}
