import java.util.Iterator;
import java.util.Random;

import com.orientechnologies.common.util.OCallable;
import com.orientechnologies.orient.core.metadata.schema.OClass;
import com.orientechnologies.orient.core.metadata.schema.OSchema;
import com.orientechnologies.orient.core.metadata.schema.OType;
import com.tinkerpop.blueprints.impls.orient.OrientBaseGraph;
import com.tinkerpop.blueprints.impls.orient.OrientGraph;
import com.tinkerpop.blueprints.impls.orient.OrientVertexType;
import com.tinkerpop.blueprints.TransactionalGraph;
import com.tinkerpop.blueprints.Vertex;

public class OrientSandbox {
    private OrientGraph graph;
    private TransactionalGraph tGraph;

    private final String[] WORDS = { "random", "word", "test", "testing", "tester", "the", "these", "abcdef", "defghi" };

    public void connect(String connection) {
        this.graph = new OrientGraph(connection, "admin", "admin");
        this.tGraph = graph;
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
        this.graph.executeOutsideTx(new OCallable<Object, OrientBaseGraph>() {
            public Object call(OrientBaseGraph iArgument) {
                OrientVertexType indexTestClass = null;
                OSchema schema = iArgument.getRawGraph().getMetadata().getSchema();

                if (!schema.existsClass("IndexTestClass")) {
                    indexTestClass = iArgument.createVertexType("IndexTestClass");
                } else {
                    indexTestClass = iArgument.getVertexType("IndexTestClass");
                }

                if (!indexTestClass.existsProperty("testText")) 
                    indexTestClass.createProperty("testText", OType.STRING);

                return null;
            } } );
    }

    public void createFulltextIndex(final String engine) {
        this.graph.executeOutsideTx(new OCallable<Object, OrientBaseGraph>() {
            public Object call(OrientBaseGraph iArgument) {
                OSchema schema = iArgument.getRawGraph().getMetadata().getSchema();
                OClass oClass = schema.getClass("IndexTestClass");

                if (oClass.getIndexedProperties().size() == 0)
                    oClass.createIndex("IndexTestClass.testText", "FULLTEXT", null, null, engine, new String[] {"testText"});

                return null;
            }});
    }

    public void createIndex(final OClass.INDEX_TYPE idxType) {
        this.graph.executeOutsideTx(new OCallable<Object, OrientBaseGraph>() {
            public Object call(OrientBaseGraph iArgument) {
                OrientVertexType indexTestClass = null;

                indexTestClass = iArgument.getVertexType("IndexTestClass");

                if (indexTestClass.getIndexedProperties().size() == 0)
                    indexTestClass.createIndex("testTextIdx", idxType, "testText");

                return null;
            }});	
    }

    public void insertFulltextTest(int numInserts) {
        Random rnd = new Random();
        final int block = 5000;
        final int totalWords = 100;
        int originalNumInserts = numInserts;
        int totalInserts = 0;

        long start = System.currentTimeMillis();

        while (numInserts > 0) {
            try {
                this.graph.begin();

                int numInsertsInTx = 0;

                for (int i = 0; i < numInserts; i++) {
                    String sentence = "";

                    // TODO: Can move this section out if necessary so all records have same sentence.
                    // The random sentence was put here so we can test actually querying the graph.
                    for (int j = 0; j < totalWords; j++) {
                        sentence += this.WORDS[rnd.nextInt(this.WORDS.length - 1)] + " ";
                    }

                    this.graph.addVertex("class:IndexTestClass", "testText", sentence);
                    numInsertsInTx++;

                    if (i == block - 1)
                        break;
                }

                numInserts -= block;

                this.graph.commit();
                totalInserts += numInsertsInTx;
            } catch (Exception e) {
                this.graph.rollback();
            }
        }

        long end = System.currentTimeMillis();

        System.out.println(totalInserts + " of " + originalNumInserts + " nodes inserted; took " + (end-start) + " ms.");
    }

    public void insertTest(int numInserts) {
        final int block = 5000;
        int originalNumInserts = numInserts;
        int totalInserts = 0;
        int key = 0;

        long start = System.currentTimeMillis();

        while (numInserts > 0) {
            try {
                this.graph.begin();

                int numInsertsInTx = 0;

                for (int i = 0; i < numInserts; i++) {
                    this.graph.addVertex("class:IndexTestClass", "testText", key++);
                    numInsertsInTx++;

                    if (i == block - 1)
                        break;
                }

                numInserts -= block;

                this.graph.commit();
                totalInserts += numInsertsInTx;
            } catch (Exception e) {
                this.graph.rollback();
                System.out.println(e.getMessage());
            }
        }

        long end = System.currentTimeMillis();

        System.out.println(totalInserts + " of " + originalNumInserts + " nodes inserted; took " + (end-start) + " ms.");
    }

    public void findNodeBP() {
        long start = System.currentTimeMillis();
        Iterator<Vertex> vs = this.tGraph.getVertices("V.name", "HEY BO DIDDLEY").iterator();
        long end = System.currentTimeMillis();

        System.out.println("findNodeBP took " + (end - start) + "ms");

        Vertex v;

        while (vs.hasNext()) {
            v = vs.next();
            System.out.println("  " + v.getProperty("name"));
        }
    }

    public void shutdown() {
        this.graph.shutdown();
    }
}
