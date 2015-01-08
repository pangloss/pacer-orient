import java.util.Iterator;
import java.util.Random;

import com.orientechnologies.orient.core.intent.OIntentMassiveInsert;
import com.orientechnologies.orient.core.metadata.schema.OClass;
import com.orientechnologies.orient.core.metadata.schema.OSchema;
import com.orientechnologies.orient.core.metadata.schema.OType;
import com.tinkerpop.blueprints.impls.orient.OrientGraphNoTx;
import com.tinkerpop.blueprints.impls.orient.OrientVertex;
import com.tinkerpop.blueprints.impls.orient.OrientVertexType;
import com.tinkerpop.blueprints.Vertex;

public class OrientSandboxNoTx {
    private OrientGraphNoTx graph;

    private final String[] WORDS = { "random", "word", "test", "testing", "tester", "the", "these", "abcdef", "defghi" };

    public void connect(String connection) {
        this.graph = new OrientGraphNoTx(connection, "admin", "admin");
    }
    
    private void setMassiveInsertIntent() {
        this.graph.declareIntent(new OIntentMassiveInsert());
    }
    
    private void clearIntent() {
        this.graph.declareIntent(null);
    }
    
    public void findNodeOrient() {
        long start = System.currentTimeMillis();
        Iterator<Vertex> vs = this.graph.getVertices("V.name", "HEY BO DIDDLEY").iterator();
        long end = System.currentTimeMillis();

        System.out.println("findNodeOrient() took " + (end - start) + "ms");

        Vertex v;

        while (vs.hasNext()) {
            v = vs.next();
            System.out.println("  " + v.getProperty("name"));
        }
    }

    public void createTestVertexType() {		
        OrientVertexType indexTestClass = null;
        OSchema schema = this.graph.getRawGraph().getMetadata().getSchema();

        if (!schema.existsClass("IndexTestClass")) {
            indexTestClass = this.graph.createVertexType("IndexTestClass");
        } else {
            indexTestClass = this.graph.getVertexType("IndexTestClass");
        }

        if (!indexTestClass.existsProperty("testText")) 
             indexTestClass.createProperty("testText", OType.STRING);
    }

    public void createFulltextIndex(final String engine) {
        OSchema schema = this.graph.getRawGraph().getMetadata().getSchema();
        OClass oClass = schema.getClass("IndexTestClass");

        if (oClass.getIndexedProperties().size() == 0)
            oClass.createIndex("IndexTestClass.testText", "FULLTEXT", null, null, engine, new String[] {"testText"});
    }

    public void createIndex(final OClass.INDEX_TYPE idxType) {
        OrientVertexType indexTestClass = null;

        indexTestClass = this.graph.getVertexType("IndexTestClass");

        if (indexTestClass.getIndexedProperties().size() == 0)
            indexTestClass.createIndex("testTextIdx", idxType, "testText");
    }

    public void insertFulltextTest(int numInserts, boolean massiveInsertIntent) {
        Random rnd = new Random();
        final int totalWords = 100;
        int originalNumInserts = numInserts;
        int totalInserts = 0;

        if (massiveInsertIntent)
            this.setMassiveInsertIntent();

        long start = System.currentTimeMillis();

        for (int i = 0; i < numInserts; i++) {
            String sentence = "";

            // TODO: Can move this section out if necessary so all records have same sentence.
            // The random sentence was put here so we can test actually querying the graph.
            for (int j = 0; j < totalWords; j++) {
                sentence += this.WORDS[rnd.nextInt(this.WORDS.length - 1)] + " ";
            }
            
            this.graph.addVertex("class:IndexTestClass", "testText", sentence);
            totalInserts++;
        }

        long end = System.currentTimeMillis();

        this.clearIntent();

        System.out.println(totalInserts + " of " + originalNumInserts + " nodes inserted; took " + (end-start) + " ms.");
    }

    public void insertTest(int numInserts, boolean massiveInsertIntent) {
        int originalNumInserts = numInserts;
        int totalInserts = 0;
        int key = 0;

        if (massiveInsertIntent)
            this.setMassiveInsertIntent();

        long start = System.currentTimeMillis();

        for (int i = 0; i < numInserts; i++) {
            this.graph.addVertex("class:IndexTestClass", "testText", key++);
            totalInserts++;
        }

        long end = System.currentTimeMillis();

        this.clearIntent();

        System.out.println(totalInserts + " of " + originalNumInserts + " nodes inserted; took " + (end-start) + " ms.");
    }

    public void shutdown() {
        this.graph.shutdown();
    }
}
