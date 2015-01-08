
public class OSMain {

    public static void main(String[] args) {
        String baseOrient ="plocal:/Users/duncan/Desktop/orientdb-community-2.0-rc1/databases/";
        OrientBenchmarkingTests obt = new OrientBenchmarkingTests(baseOrient);

        // uncomment tests as needed
        
        // tx-based, no modification
        //obt.setMassiveInsertIntent(false);
        //obt.testLuceneFulltext();
        //obt.testFulltext();
        //obt.testUnique();
        //obt.testNotUnique();
        //obt.testDictionary();
        
        // tx-based, "massive insertion
        //obt.setMassiveInsertIntent(true);
        //obt.testLuceneFulltext();
        //obt.testFulltext();
        //obt.testUnique();
        //obt.testNotUnique();
    }

}
