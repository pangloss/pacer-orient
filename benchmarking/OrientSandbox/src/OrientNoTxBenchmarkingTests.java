import com.orientechnologies.orient.core.metadata.schema.OClass;

public class OrientNoTxBenchmarkingTests {
    private OrientSandboxNoTx os;
    private final String baseOrient;
    private boolean declareMassiveInsert;

    public OrientNoTxBenchmarkingTests(String baseOrient) {
        this(baseOrient, false);
    }

    public OrientNoTxBenchmarkingTests(String baseOrient, boolean declareMassiveInsertIntent) {
        os = new OrientSandboxNoTx();
        this.baseOrient = baseOrient;
        
        this.declareMassiveInsert = declareMassiveInsertIntent;            
    }

    public void setMassiveInsertIntent(boolean declareMassiveInsert) {
        this.declareMassiveInsert = declareMassiveInsert;
    }
    
    public void testLuceneFulltext() {
        // LUCENE
        System.out.println("LUCENE");
        os.connect(baseOrient + "NoTxLuceneTestDB");

        os.createTestVertexType();
        os.createFulltextIndex("LUCENE");
        os.insertFulltextTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // SBTREE
        System.out.println("SBTREE");
        os.connect(baseOrient + "NoTxSBTreeLuceneFulltextTestDB");

        os.createTestVertexType();
        os.createFulltextIndex("SBTREE");
        os.insertFulltextTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // NO INDEX
        System.out.println("NO INDEX");
        os.connect(baseOrient + "NoTxNoIndexLuceneFulltextTestDB");

        os.createTestVertexType();
        os.insertFulltextTest(500000, this.declareMassiveInsert);
        os.shutdown();		
    }

    public void testUnique() {
        // SBTREE
        System.out.println("SBTREE");
        os.connect(baseOrient + "NoTxSBTreeUniqueTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.UNIQUE);
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // HASHINDEX
        System.out.println("HASHINDEX");
        os.connect(baseOrient + "NoTxHashUniqueTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.UNIQUE_HASH_INDEX);
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // NO INDEX
        System.out.println("NO INDEX");
        os.connect(baseOrient + "NoTxNoIndexUniqueTestDB");

        os.createTestVertexType();
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();
    }

    public void testNotUnique() {
        // SBTREE
        System.out.println("SBTREE");
        os.connect(baseOrient + "NoTxSBTreeNotUniqueTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.NOTUNIQUE);
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // HASHINDEX
        System.out.println("HASHINDEX");
        os.connect(baseOrient + "NoTxHashNotUniqueTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.NOTUNIQUE_HASH_INDEX);
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // NO INDEX
        System.out.println("NO INDEX");
        os.connect(baseOrient + "NoTxNoIndexNotUniqueTestDB");

        os.createTestVertexType();
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();
    }

    // NOTE: This test shows that DICTIONARY is only available as a manual index for now.
    public void testDictionary() {
        // SBTREE
        System.out.println("SBTREE");
        os.connect(baseOrient + "NoTxSBTreeDictTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.DICTIONARY);
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // HASHINDEX
        System.out.println("HASHINDEX");
        os.connect(baseOrient + "NoTxHashDictTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.DICTIONARY_HASH_INDEX);
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // NO INDEX
        System.out.println("NO INDEX");
        os.connect(baseOrient + "NoTxNoIndexDictTestDB");

        os.createTestVertexType();
        os.insertTest(500000, this.declareMassiveInsert);
        os.shutdown();
    }

    public void testFulltext() {
        // SBTREE
        System.out.println("SBTREE");
        os.connect(baseOrient + "NoTxSBTreeFulltextTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.FULLTEXT);
        os.insertFulltextTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // HASHINDEX
        System.out.println("HASHINDEX");
        os.connect(baseOrient + "NoTxHashFulltextTestDB");

        os.createTestVertexType();
        os.createIndex(OClass.INDEX_TYPE.FULLTEXT_HASH_INDEX);
        os.insertFulltextTest(500000, this.declareMassiveInsert);
        os.shutdown();

        // NO INDEX
        System.out.println("NO INDEX");
        os.connect(baseOrient + "NoTxNoIndexFulltextTestDB");

        os.createTestVertexType();
        os.insertFulltextTest(500000, this.declareMassiveInsert);
        os.shutdown();
    }
}
