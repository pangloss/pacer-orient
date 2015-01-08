import com.orientechnologies.orient.core.metadata.schema.OClass;



public class OrientBenchmarkingTests {
    private OrientSandbox os;
    private final String baseOrient;
    private boolean declareMassiveInsert;

    public OrientBenchmarkingTests(String baseOrient) {
        this(baseOrient, false);
    }

    public OrientBenchmarkingTests(String baseOrient, boolean declareMassiveInsertIntent) {
        os = new OrientSandbox();
        this.baseOrient = baseOrient;
        
        this.declareMassiveInsert = declareMassiveInsertIntent;            
    }

    public void setMassiveInsertIntent(boolean declareMassiveInsert) {
        this.declareMassiveInsert = declareMassiveInsert;
    }
    
    public void testLuceneFulltext() {
        // LUCENE
        System.out.println("LUCENE");
        os.connect(baseOrient + "LuceneTestDB");

        os.createTestVertexType();
        os.createFulltextIndex("LUCENE");
        os.insertFulltextTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // SBTREE
        System.out.println("SBTREE");
        os.connect(baseOrient + "SBTreeLuceneFulltextTestDB");

        os.createTestVertexType();
        os.createFulltextIndex("SBTREE");
        os.insertFulltextTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // NO INDEX
        System.out.println("NO INDEX");
        os.connect(baseOrient + "NoIndexLuceneFulltextTestDB");

        os.createTestVertexType();
        os.insertFulltextTest(500000, this.declareMassiveInsert);
        os.shutdown();		
    }

    public void testUnique() {
        // SBTREE
        System.out.println("SBTREE");
        os.connect(baseOrient + "SBTreeUniqueTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.UNIQUE);
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // HASHINDEX
        System.out.println("HASHINDEX");
        os.connect(baseOrient + "HashUniqueTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.UNIQUE_HASH_INDEX);
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // NO INDEX
        System.out.println("NO INDEX");
        os.connect(baseOrient + "NoIndexUniqueTestDB");

        os.createTestVertexType();
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();
    }

    public void testNotUnique() {
        // SBTREE
        System.out.println("SBTREE");
        os.connect(baseOrient + "SBTreeNotUniqueTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.NOTUNIQUE);
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // HASHINDEX
        System.out.println("HASHINDEX");
        os.connect(baseOrient + "HashNotUniqueTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.NOTUNIQUE_HASH_INDEX);
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // NO INDEX
        System.out.println("NO INDEX");
        os.connect(baseOrient + "NoIndexNotUniqueTestDB");

        os.createTestVertexType();
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();
    }

    // NOTE: This test shows that DICTIONARY is only available as a manual index for now.
    public void testDictionary() {
        // SBTREE
        System.out.println("SBTREE");
        os.connect(baseOrient + "SBTreeDictTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.DICTIONARY);
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // HASHINDEX
        System.out.println("HASHINDEX");
        os.connect(baseOrient + "HashDictTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.DICTIONARY_HASH_INDEX);
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // NO INDEX
        System.out.println("NO INDEX");
        os.connect(baseOrient + "NoIndexDictTestDB");

        os.createTestVertexType();
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();
    }

    public void testFulltext() {
        // SBTREE
        System.out.println("SBTREE");
        os.connect(baseOrient + "SBTreeFulltextTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.FULLTEXT);
        os.insertFulltextTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // HASHINDEX
        System.out.println("HASHINDEX");
        os.connect(baseOrient + "HashFulltextTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.FULLTEXT_HASH_INDEX);
        os.insertFulltextTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // NO INDEX
        System.out.println("NO INDEX");
        os.connect(baseOrient + "NoIndexFulltextTestDB");

        os.createTestVertexType();
        os.insertFulltextTest(500000, this.declareMassiveInsert);
        os.shutdown();
    }
}
