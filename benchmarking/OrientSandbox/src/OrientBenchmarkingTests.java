import com.orientechnologies.orient.core.metadata.schema.OClass;



public class OrientBenchmarkingTests {
    private OrientSandbox os;
    private final String baseOrient;

    public OrientBenchmarkingTests(String baseOrient) {
        os = new OrientSandbox();
        this.baseOrient = baseOrient;
    }

    public void testLuceneFulltext() {
        // LUCENE
        System.out.println("LUCENE");
        os.connect(baseOrient + "LuceneTestDB");

        os.createTestVertexType();
        os.createFulltextIndex("LUCENE");
        os.insertFulltextTest(500000);
        os.shutdown();

        // SBTREE
        System.out.println("SBTREE");
        os.connect(baseOrient + "FulltextTestDB");

        os.createTestVertexType();
        os.createFulltextIndex("SBTREE");
        os.insertFulltextTest(500000);
        os.shutdown();

        // NO INDEX
        System.out.println("NO INDEX");
        os.connect(baseOrient + "NoIndexFulltextTestDB");

        os.createTestVertexType();
        os.insertFulltextTest(500000);
        os.shutdown();		
    }

    public void testUnique() {
        // SBTREE
        System.out.println("SBTREE");
        os.connect(baseOrient + "SBTreeUniqueTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.UNIQUE);
        os.insertTest(500000);
        os.shutdown();

        // HASHINDEX
        System.out.println("HASHINDEX");
        os.connect(baseOrient + "HashUniqueTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.UNIQUE_HASH_INDEX);
        os.insertTest(500000);
        os.shutdown();

        // NO INDEX
        System.out.println("NO INDEX");
        os.connect(baseOrient + "NoIndexUniqueTestDB");

        os.createTestVertexType();
        os.insertTest(500000);
        os.shutdown();
    }
}
