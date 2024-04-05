<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
    <!ENTITY lacl   "https://w3id.org/atomgraph/linkeddatahub/admin/acl#">
    <!ENTITY lapp   "https://w3id.org/atomgraph/linkeddatahub/apps#">
    <!ENTITY adm    "https://w3id.org/atomgraph/linkeddatahub/admin#">
    <!ENTITY ldh    "https://w3id.org/atomgraph/linkeddatahub#">
    <!ENTITY ac     "https://w3id.org/atomgraph/client#">
    <!ENTITY a      "https://w3id.org/atomgraph/core#">
    <!ENTITY rdf    "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <!ENTITY rdfs   "http://www.w3.org/2000/01/rdf-schema#">
    <!ENTITY owl    "http://www.w3.org/2002/07/owl#">
    <!ENTITY acl    "http://www.w3.org/ns/auth/acl#">
    <!ENTITY cert   "http://www.w3.org/ns/auth/cert#">
    <!ENTITY ldt    "https://www.w3.org/ns/ldt#">
    <!ENTITY dh     "https://www.w3.org/ns/ldt/document-hierarchy#">
    <!ENTITY sh     "http://www.w3.org/ns/shacl#">
    <!ENTITY sp     "http://spinrdf.org/sp#">
    <!ENTITY sioc   "http://rdfs.org/sioc/ns#">
    <!ENTITY foaf   "http://xmlns.com/foaf/0.1/">
    <!ENTITY spin   "http://spinrdf.org/spin#">
]>
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:map="http://www.w3.org/2005/xpath-functions/map"
xmlns:lapp="&lapp;"
xmlns:ldh="&ldh;"
xmlns:ac="&ac;"
xmlns:a="&a;"
xmlns:rdf="&rdf;"
xmlns:rdfs="&rdfs;"
xmlns:acl="&acl;"
xmlns:ldt="&ldt;"
xmlns:sioc="&sioc;"
xmlns:foaf="&foaf;"
xmlns:spin="&spin;"
xmlns:bs2="http://graphity.org/xsl/bootstrap/2.3.2"
exclude-result-prefixes="#all">

    <xsl:import href="../layout.xsl"/>
    <xsl:include href="signup.xsl"/>
    <xsl:include href="request-access.xsl"/>
    <xsl:include href="acl/layout.xsl"/>

    <xsl:param name="default-classes" select="(xs:anyURI('&owl;Ontology'), xs:anyURI('&sh;NodeShape'), xs:anyURI('&sh;PropertyShape'), xs:anyURI('&acl;Authorization'), xs:anyURI('&foaf;Person'), xs:anyURI('&cert;PublicKey'), xs:anyURI('&sioc;UserAccount'), xs:anyURI('&foaf;Group'))" as="xs:anyURI*"/>
    
    <xsl:template match="rdf:RDF[$foaf:Agent]" mode="bs2:Create" priority="1">
        <xsl:param name="classes" as="element()*"/>
        <xsl:param name="create-graph" select="false()" as="xs:boolean"/>
        <xsl:param name="base-uri" select="ldh:base-uri(.)" as="xs:anyURI"/>

        <div class="btn-group pull-left">
            <button type="button" title="{ac:label(key('resources', 'create-instance-title', document('../translations.rdf')))}">
                <xsl:apply-templates select="key('resources', '&ac;ConstructMode', document(ac:document-uri('&ac;')))" mode="ldh:logo">
                    <xsl:with-param name="class" select="'btn btn-primary dropdown-toggle'"/>
                </xsl:apply-templates>
                <xsl:value-of>
                    <xsl:apply-templates select="key('resources', '&ac;ConstructMode', document(ac:document-uri('&ac;')))" mode="ac:label"/>
                </xsl:value-of>
                <xsl:text> </xsl:text>
                <span class="caret"></span>
            </button>

            <ul class="dropdown-menu">
                <xsl:apply-templates select="$classes" mode="bs2:ConstructorListItem">
                    <xsl:with-param name="base-uri" select="$base-uri" tunnel="yes"/>
                    <xsl:with-param name="create-graph" select="$create-graph"/>
                    <xsl:sort select="ac:label(.)"/>
                </xsl:apply-templates>
            </ul>
        </div>
    </xsl:template>
    
    <!-- ADD DATA -->
    
    <xsl:template match="rdf:RDF[$acl:mode = '&acl;Append']" mode="bs2:AddData" priority="1">
        <div class="btn-group pull-left">
            <button type="button" class="btn btn-primary dropdown-toggle" title="{ac:label(key('resources', 'add', document('../translations.rdf')))}">
                <xsl:value-of>
                    <xsl:apply-templates select="key('resources', 'add', document('../translations.rdf'))" mode="ac:label"/>
                </xsl:value-of>
                <xsl:text> </xsl:text>
                <span class="caret"></span>
            </button>
            
            <ul class="dropdown-menu">
                <li>
                    <button type="button" title="{ac:label(key('resources', 'add-data-title', document('../translations.rdf')))}" class="btn btn-add-data">
                        <xsl:value-of>
                            <xsl:apply-templates select="key('resources', 'add-data', document('../translations.rdf'))" mode="ac:label"/>
                        </xsl:value-of>
                    </button>
                </li>
                <li>
                    <button type="button" title="{ac:label(key('resources', 'import-ontology-title', document('../translations.rdf')))}" class="btn btn-add-ontology">
                        <xsl:value-of>
                            <xsl:apply-templates select="key('resources', 'import-ontology', document('../translations.rdf'))" mode="ac:label"/>
                        </xsl:value-of>
                    </button>
                </li>
            </ul>
        </div>
    </xsl:template>
    
    <xsl:template match="*" mode="bs2:AddData"/>
    
    <!-- ROW FORM - we need the overriding templates as well -->

<!--    <xsl:template match="rdf:RDF[$ac:forClass = ('&ldh;CSVImport', '&ldh;RDFImport')][$ac:method = 'GET']" mode="bs2:RowForm" priority="2" use-when="system-property('xsl:product-name') = 'SAXON'">
        <xsl:param name="id" select="concat('form-', generate-id())" as="xs:string?"/>
        <xsl:param name="class" select="'form-horizontal'" as="xs:string?"/>
        <xsl:param name="action" select="ac:build-uri(resolve-uri('importer', $ldt:base), map{ 'forClass': string($ac:forClass), 'mode': '&ac;EditMode' })" as="xs:anyURI"/>
        <xsl:param name="classes" as="element()*"/>

        <xsl:next-match>
            <xsl:with-param name="id" select="$id"/>
            <xsl:with-param name="class" select="$class"/>
            <xsl:with-param name="action" select="$action"/>
            <xsl:with-param name="classes" select="$classes"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="rdf:RDF[$ac:forClass][$ac:method = 'GET']" mode="bs2:RowForm" priority="1" use-when="system-property('xsl:product-name') = 'SAXON'">
        <xsl:param name="id" select="concat('form-', generate-id())" as="xs:string?"/>
        <xsl:param name="class" select="'form-horizontal'" as="xs:string?"/>
        <xsl:param name="base-uri" as="xs:anyURI" tunnel="yes"/>
        <xsl:param name="action" select="ac:build-uri(resolve-uri(ac:uuid() || '/', $base-uri), map{ 'forClass': string($ac:forClass), 'mode': '&ac;EditMode' })" as="xs:anyURI"/>
        <xsl:param name="classes" as="element()*"/>

        <xsl:next-match>
            <xsl:with-param name="id" select="$id"/>
            <xsl:with-param name="class" select="$class"/>
            <xsl:with-param name="action" select="$action"/>
            <xsl:with-param name="classes" select="$classes"/>
        </xsl:next-match>
    </xsl:template>-->
    
    <!-- add "Create" button to the creatable class list below the form. Needs to pass parameters from signup.xsl and request-access.xsl!!! -->
    <xsl:template match="rdf:RDF[$ac:method = 'GET']" mode="bs2:RowForm" use-when="system-property('xsl:product-name') = 'SAXON'">
        <xsl:param name="id" select="concat('form-', generate-id())" as="xs:string?"/>
        <xsl:param name="class" select="'form-horizontal'" as="xs:string?"/>
        <xsl:param name="action" select="ldh:href($ldt:base, ac:absolute-path(ldh:base-uri(.)), map{}, ac:build-uri(ac:absolute-path(ldh:base-uri(.)), map{ '_method': 'PUT', 'mode': for $mode in $ac:mode return string($mode) }))" as="xs:anyURI"/>
        <xsl:param name="enctype" select="'multipart/form-data'" as="xs:string?"/>
        <xsl:param name="create-resource" select="true()" as="xs:boolean"/>
        <!-- TO-DO: generate ontology classes from the OWL vocabulary -->
        <xsl:param name="ontology-classes" select="for $class-uri in ('&ldh;Constructor', '&owl;Class', '&owl;DatatypeProperty', '&owl;ObjectProperty', '&owl;Restriction') return key('resources', $class-uri, document(ac:document-uri($class-uri)))" as="element()*"/>

        <xsl:next-match>
            <xsl:with-param name="id" select="$id"/>
            <xsl:with-param name="class" select="$class"/>
            <xsl:with-param name="action" select="$action"/>
            <xsl:with-param name="enctype" select="$enctype"/>
            <xsl:with-param name="create-resource" select="$create-resource"/>
            <xsl:with-param name="classes" select="$ontology-classes"/>
        </xsl:next-match>
    </xsl:template>
    
    <!-- allow subject editing in admin EditMode -->
    <!-- there are templates (e.g. in signup.xsl and request-access.xsl overriding this so we need to pass the params through -->
    <xsl:template match="*[*][@rdf:about or @rdf:nodeID]" mode="bs2:FormControl">
        <xsl:param name="legend" select="true()" as="xs:boolean"/>
        <xsl:param name="show-subject" select="not(rdf:type/@rdf:resource = ('&dh;Item', '&dh;Container'))" as="xs:boolean" tunnel="yes"/>
        <xsl:param name="required" select="false()" as="xs:boolean"/>

        <xsl:apply-imports>
            <xsl:with-param name="legend" select="$legend"/>
            <xsl:with-param name="show-subject" select="$show-subject" tunnel="yes"/>
            <xsl:with-param name="required" select="$required"/>
        </xsl:apply-imports>
    </xsl:template>
    
    <!-- show "Clear" button for ontologies -->
    <xsl:template match="*[rdf:type/@rdf:resource = '&owl;Ontology'][$foaf:Agent//@rdf:about]" mode="bs2:Actions">
        <form class="pull-right" action="{resolve-uri('clear', $ldt:base)}" method="post">
            <input type="hidden" name="uri" value="{@rdf:about}"/>
            
            <button class="btn btn-primary" type="submit">
                <xsl:value-of>
                    <xsl:apply-templates select="key('resources', 'clear', document('../translations.rdf'))" mode="ac:label"/>
                </xsl:value-of>
            </button>
        </form>

        <xsl:next-match/>
    </xsl:template>
    
</xsl:stylesheet>
