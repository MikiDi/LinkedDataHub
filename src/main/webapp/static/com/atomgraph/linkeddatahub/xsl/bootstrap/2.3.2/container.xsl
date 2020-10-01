<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
    <!ENTITY apl    "https://w3id.org/atomgraph/linkeddatahub/domain#">
    <!ENTITY ac     "https://w3id.org/atomgraph/client#">
    <!ENTITY rdf    "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <!ENTITY xsd    "http://www.w3.org/2001/XMLSchema#">
    <!ENTITY geo    "http://www.w3.org/2003/01/geo/wgs84_pos#">
    <!ENTITY srx    "http://www.w3.org/2005/sparql-results#">
    <!ENTITY ldt    "https://www.w3.org/ns/ldt#">
    <!ENTITY dh     "https://www.w3.org/ns/ldt/document-hierarchy/domain#">
    <!ENTITY sd     "http://www.w3.org/ns/sparql-service-description#">
    <!ENTITY dct    "http://purl.org/dc/terms/">
    <!ENTITY foaf   "http://xmlns.com/foaf/0.1/">
    <!ENTITY sioc   "http://rdfs.org/sioc/ns#">
    <!ENTITY sp     "http://spinrdf.org/sp#">
    <!ENTITY spin   "http://spinrdf.org/spin#">
    <!ENTITY void   "http://rdfs.org/ns/void#">
]>
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
xmlns:prop="http://saxonica.com/ns/html-property"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:json="http://www.w3.org/2005/xpath-functions"
xmlns:array="http://www.w3.org/2005/xpath-functions/array"
xmlns:ac="&ac;"
xmlns:apl="&apl;"
xmlns:rdf="&rdf;"
xmlns:srx="&srx;"
xmlns:ldt="&ldt;"
xmlns:dh="&dh;"
xmlns:sd="&sd;"
xmlns:foaf="&foaf;"
xmlns:sp="&sp;"
xmlns:geo="&geo;"
xmlns:void="&void;"
xmlns:bs2="http://graphity.org/xsl/bootstrap/2.3.2"
xmlns:saxon="http://saxon.sf.net/"
extension-element-prefixes="ixsl"
exclude-result-prefixes="#all"
>

    <!-- PARALLAX -->
    
    <xsl:template name="bs2:Parallax">
        <xsl:param name="results" as="document-node()"/>
        
        <!-- only show if the result contains object resources -->
        <xsl:if test="$results/rdf:RDF/*/*[@rdf:resource or @rdf:nodeID]">
            <div class="sidebar-nav parallax-nav">
                <h2 class="nav-header btn">Navigation</h2>

                <ul class="well well-small nav nav-list">
                    <xsl:for-each-group select="$results/rdf:RDF/*/*[@rdf:resource or @rdf:nodeID]" group-by="concat(namespace-uri(), local-name())">
                        <xsl:sort select="current-grouping-key()"/>

                        <li>
                            <a>
                                <input name="ou" type="hidden" value="{current-grouping-key()}"/>
                                <xsl:value-of select="ac:property-label(current-group()[1])"/>
                            </a>
                        </li>
                    </xsl:for-each-group>
                </ul>
            </div>
        </xsl:if>
    </xsl:template>
    
    <!-- FILTERS -->

    <xsl:template name="bs2:FilterIn">
        <div class="sidebar-nav faceted-nav">
            <h2 class="nav-header btn">Types</h2>

            <ul class="well well-small nav nav-list">
                <li>
                    <label class="checkbox">
                        <input type="checkbox" name="Type" value="{resolve-uri('ns/default#Container', $ldt:base)}"> <!-- {@rdf:about | @rdf:nodeID} -->
<!--                                    <xsl:if test="$filter/*/@rdf:resource = @rdf:about">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>-->
                        </input>
                        <span title="Container">Container</span>
                    </label>
                </li>
                <li>
                    <label class="checkbox">
                        <input type="checkbox" name="Type" value="{resolve-uri('ns/default#Item', $ldt:base)}"> <!-- {@rdf:about | @rdf:nodeID} -->
<!--                                    <xsl:if test="$filter/*/@rdf:resource = @rdf:about">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>-->
                        </input>
                        <span title="Item">Item</span>
                    </label>
                </li>
            </ul>
        </div>
    </xsl:template>

    <!-- PAGER -->

    <xsl:template name="bs2:PagerList">
        <xsl:param name="limit" as="xs:integer?"/>
        <xsl:param name="offset" as="xs:integer?"/>
        <xsl:param name="order-by" as="xs:string?"/>
        <xsl:param name="desc" as="xs:boolean?"/>
        <xsl:param name="result-count" as="xs:integer?"/>
        <xsl:param name="show" select="($offset - $limit) &gt;= 0 or $result-count &gt;= $limit" as="xs:boolean"/>

        <!-- do not show pagination if the children document count is less than the page limit -->
        <xsl:if test="$show">
            <ul class="pager">
                <li class="previous">
                    <xsl:choose>
                        <xsl:when test="($offset - $limit) &gt;= 0">
                            <a class="active">
                                <!-- only set hyperlink on server-side - client-side will use event listener to avoid page refresh -->
                                <xsl:variable name="href" select="xs:anyURI(concat($ac:uri, '?limit=', $limit, '&amp;offset=', $offset - $limit, if ($order-by) then concat('&amp;order-by=', $order-by) else (), if ($desc) then concat('&amp;desc=', $desc) else ()))" as="xs:anyURI" use-when="system-property('xsl:product-name') = 'SAXON'"/>
                                <xsl:attribute name="href" select="$href" use-when="system-property('xsl:product-name') = 'SAXON'"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class">previous disabled</xsl:attribute>
                            <a></a>
                        </xsl:otherwise>
                    </xsl:choose>
                </li>
                <li class="next">
                    <xsl:choose>
                        <xsl:when test="$result-count &gt;= $limit">
                            <a class="active">
                                <!-- only set hyperlink on server-side - client-side will use event listener to avoid page refresh -->
                                <xsl:variable name="href" select="xs:anyURI(concat($ac:uri, '?limit=', $limit, '&amp;offset=', $offset + $limit, if ($order-by) then concat('&amp;order-by=', $order-by) else (), if ($desc) then concat('&amp;desc=', $desc) else ()))" as="xs:anyURI" use-when="system-property('xsl:product-name') = 'SAXON'"/>
                                <xsl:attribute name="href" select="$href" use-when="system-property('xsl:product-name') = 'SAXON'"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class">next disabled</xsl:attribute>
                            <a></a>
                        </xsl:otherwise>
                    </xsl:choose>
                </li>
            </ul>
        </xsl:if>
    </xsl:template>

    <!-- BLOCK LIST MODE -->

    <xsl:template match="rdf:RDF" mode="bs2:BlockList" use-when="system-property('xsl:product-name') eq 'Saxon-JS'">
        <xsl:variable name="result-count" select="count(rdf:Description)" as="xs:integer"/>

        <xsl:call-template name="bs2:PagerList">
            <xsl:with-param name="limit" select="xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.limit'))"/>
            <xsl:with-param name="offset" select="xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.offset'))"/>
            <xsl:with-param name="order-by" select="ixsl:get(ixsl:window(), 'LinkedDataHub.order-by')"/>
            <xsl:with-param name="desc" select="ixsl:get(ixsl:window(), 'LinkedDataHub.desc')"/>
            <xsl:with-param name="result-count" select="$result-count"/>
        </xsl:call-template>

        <xsl:next-match/>

        <xsl:call-template name="bs2:PagerList">
            <xsl:with-param name="limit" select="xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.limit'))"/>
            <xsl:with-param name="offset" select="xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.offset'))"/>
            <xsl:with-param name="order-by" select="ixsl:get(ixsl:window(), 'LinkedDataHub.order-by')"/>
            <xsl:with-param name="desc" select="ixsl:get(ixsl:window(), 'LinkedDataHub.desc')"/>
            <xsl:with-param name="result-count" select="$result-count"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[key('resources', foaf:primaryTopic/@rdf:resource)]" mode="bs2:BlockList" priority="1">
        <xsl:param name="id" as="xs:string?"/>
        <xsl:param name="class" select="'well'" as="xs:string?"/>

        <div>
            <xsl:if test="$id">
                <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="$class">
                <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
            </xsl:if>

            <xsl:apply-templates select="." mode="bs2:Actions"/>

            <xsl:apply-templates select="." mode="bs2:TypeList"/>

            <xsl:apply-templates select="." mode="apl:logo">
                <xsl:with-param name="class" select="'well'"/>
            </xsl:apply-templates>

            <xsl:apply-templates select="." mode="bs2:Timestamp"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="." mode="xhtml:Anchor"/>

            <xsl:apply-templates select="key('resources', foaf:primaryTopic/@rdf:resource)" mode="bs2:Header">
                <xsl:with-param name="class" select="'well well-small'"/>
            </xsl:apply-templates>
        </div>
    </xsl:template>

    <xsl:template match="*[key('resources', foaf:isPrimaryTopicOf/@rdf:resource)]" mode="bs2:BlockList" priority="1"/>

    <xsl:template match="*[*][@rdf:*[local-name() = ('about', 'nodeID')]]" mode="bs2:BlockList" priority="0.8">
        <xsl:apply-templates select="." mode="bs2:Header"/>
    </xsl:template>

    <!-- GRID MODE -->

    <xsl:template match="rdf:RDF" mode="bs2:Grid" use-when="system-property('xsl:product-name') eq 'Saxon-JS'">
        <xsl:variable name="result-count" select="count(rdf:Description)" as="xs:integer"/>

        <xsl:call-template name="bs2:PagerList">
            <xsl:with-param name="limit" select="xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.limit'))"/>
            <xsl:with-param name="offset" select="xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.offset'))"/>
            <xsl:with-param name="order-by" select="ixsl:get(ixsl:window(), 'LinkedDataHub.order-by')"/>
            <xsl:with-param name="desc" select="ixsl:get(ixsl:window(), 'LinkedDataHub.desc')"/>
            <xsl:with-param name="result-count" select="$result-count"/>
        </xsl:call-template>

        <xsl:next-match/>

        <xsl:call-template name="bs2:PagerList">
            <xsl:with-param name="limit" select="xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.limit'))"/>
            <xsl:with-param name="offset" select="xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.offset'))"/>
            <xsl:with-param name="order-by" select="ixsl:get(ixsl:window(), 'LinkedDataHub.order-by')"/>
            <xsl:with-param name="desc" select="ixsl:get(ixsl:window(), 'LinkedDataHub.desc')"/>
            <xsl:with-param name="result-count" select="$result-count"/>
        </xsl:call-template>
    </xsl:template>

    <!-- TABLE MODE -->

    <xsl:template match="rdf:RDF" mode="xhtml:Table" use-when="system-property('xsl:product-name') eq 'Saxon-JS'">
        <xsl:variable name="result-count" select="count(rdf:Description)" as="xs:integer"/>

        <xsl:call-template name="bs2:PagerList">
            <xsl:with-param name="limit" select="xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.limit'))"/>
            <xsl:with-param name="offset" select="xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.offset'))"/>
            <xsl:with-param name="order-by" select="ixsl:get(ixsl:window(), 'LinkedDataHub.order-by')"/>
            <xsl:with-param name="desc" select="ixsl:get(ixsl:window(), 'LinkedDataHub.desc')"/>
            <xsl:with-param name="result-count" select="$result-count"/>
        </xsl:call-template>

        <xsl:next-match/>

        <xsl:call-template name="bs2:PagerList">
            <xsl:with-param name="limit" select="xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.limit'))"/>
            <xsl:with-param name="offset" select="xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.offset'))"/>
            <xsl:with-param name="order-by" select="ixsl:get(ixsl:window(), 'LinkedDataHub.order-by')"/>
            <xsl:with-param name="desc" select="ixsl:get(ixsl:window(), 'LinkedDataHub.desc')"/>
            <xsl:with-param name="result-count" select="$result-count"/>
        </xsl:call-template>
    </xsl:template>

    <!-- GRAPH MODE -->

    <xsl:template match="rdf:RDF" mode="bs2:Graph">
        <xsl:apply-templates select="." mode="ac:SVG">
            <xsl:with-param name="width" select="'100%'"/>
            <xsl:with-param name="step-count" select="5"/>
            <xsl:with-param name="spring-length" select="100" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- do not show system named graph resources with provenance metadata as SVG nodes, also hide links to them -->
    <xsl:template match="*[starts-with(@rdf:about, resolve-uri('graphs/', xs:string($ldt:base)))] | void:inDataset[starts-with(@rdf:resource, resolve-uri('graphs/', xs:string($ldt:base)))] | @rdf:resource[starts-with(., resolve-uri('graphs/', xs:string($ldt:base)))]" mode="ac:SVG" priority="1"/>

    <!-- MAP MODE -->

    <!-- TO-DO: improve match pattern -->
    <xsl:template match="rdf:RDF[resolve-uri('geo/', $ldt:base) = $ac:uri]" mode="bs2:Map" priority="1">
        <xsl:next-match>
            <xsl:with-param name="container-uri" select="()"/>
        </xsl:next-match>
    </xsl:template>

    <xsl:template match="rdf:RDF" mode="bs2:Map">
        <xsl:param name="canvas-id" select="'map-canvas'" as="xs:string"/>

        <div id="{$canvas-id}"></div>
    </xsl:template>

    <xsl:function name="ac:create-map">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="lat" as="xs:float"/>
        <xsl:param name="lng" as="xs:float"/>
        <xsl:param name="zoom" as="xs:integer"/>

        <xsl:variable name="js-statement" as="element()">
            <root statement="new google.maps.Map(document.getElementById('{$id}'), {{ center: new google.maps.LatLng({$lat}, {$lng}), zoom: {$zoom} }})"/>
        </xsl:variable>
        <xsl:sequence select="ixsl:eval(string($js-statement/@statement))"/>
    </xsl:function>

    <xsl:template name="create-google-map">
        <xsl:param name="map"/>

        <ixsl:set-property name="map" select="$map" object="ixsl:get(ixsl:window(), 'LinkedDataHub')"/>
    </xsl:template>

    <xsl:function name="ac:create-geo-object">
        <xsl:param name="uri" as="xs:anyURI"/>
        <xsl:param name="endpoint" as="xs:anyURI"/>
        <xsl:param name="select-string" as="xs:string"/>
        <xsl:param name="item-var-name" as="xs:string"/>

        <!-- set ?this value -->
        <xsl:variable name="select-string" select="replace($select-string, '\?this', concat('&lt;', $uri, '&gt;'))" as="xs:string"/>
        <xsl:variable name="js-statement" as="element()">
            <!-- TO-DO: move Geo under AtomGraph namespace -->
            <!-- use template literals because the query is multi-line https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals -->
            <root statement="new SPARQLMap.Geo(window.LinkedDataHub.map, new URL('{$endpoint}'), `{$select-string}`, '{$item-var-name}')"/>
        </xsl:variable>
        <xsl:sequence select="ixsl:eval(string($js-statement/@statement))"/>
    </xsl:function>

    <xsl:template name="create-geo-object">
        <xsl:param name="geo"/>

        <ixsl:set-property name="geo" select="$geo" object="ixsl:get(ixsl:window(), 'LinkedDataHub')"/>
    </xsl:template>

    <xsl:template name="add-geo-listener">
        <xsl:variable name="js-statement" as="element()">
            <root statement="window.LinkedDataHub.map.addListener('idle', function() {{ window.LinkedDataHub.geo.loadMarkers(window.LinkedDataHub.geo.addMarkers); }})"/> <!-- use template literal because the query string is multi-line -->
        </xsl:variable>
        <xsl:sequence select="ixsl:eval(string($js-statement/@statement))"/>
    </xsl:template>

    <!-- CHART MODE -->

    <!-- graph chart (for RDF/XML results) -->

    <xsl:template match="rdf:RDF" mode="bs2:Chart" use-when="system-property('xsl:product-name') eq 'Saxon-JS'">
        <xsl:param name="chart-type" select="xs:anyURI('&ac;Table')" as="xs:anyURI?"/>
        <xsl:param name="category" as="xs:string?"/>
        <xsl:param name="series" select="distinct-values(*/*/concat(namespace-uri(), local-name()))" as="xs:string*"/>
        <!-- <xsl:param name="endpoint" as="xs:anyURI"/> -->
        <xsl:param name="canvas-id" select="'chart-canvas'" as="xs:string"/>

        <xsl:apply-templates select="." mode="bs2:ChartForm">
            <xsl:with-param name="chart-type" select="$chart-type"/>
            <xsl:with-param name="category" select="$category"/>
            <xsl:with-param name="series" select="$series"/>
        </xsl:apply-templates>

        <div id="{$canvas-id}"></div>
    </xsl:template>

    <xsl:template match="rdf:RDF" mode="bs2:ChartForm" use-when="system-property('xsl:product-name') eq 'Saxon-JS'" priority="-1">
        <xsl:param name="method" select="'post'" as="xs:string"/>
        <xsl:param name="doc-type" select="resolve-uri('ns#ChartItem', $ldt:base)" as="xs:anyURI"/>
        <xsl:param name="type" select="resolve-uri('ns/default#GraphChart', $ldt:base)" as="xs:anyURI"/>
        <xsl:param name="action" select="resolve-uri(concat('charts/?forClass=', encode-for-uri(resolve-uri($type, $ldt:base))), $ldt:base)" as="xs:anyURI"/>
        <xsl:param name="id" as="xs:string?"/>
        <xsl:param name="class" select="'form-inline'" as="xs:string?"/>
        <xsl:param name="button-class" select="'btn'" as="xs:string?"/>
        <xsl:param name="accept-charset" select="'UTF-8'" as="xs:string?"/>
        <xsl:param name="enctype" as="xs:string?"/>
        <!-- table is the default chart type -->
        <xsl:param name="chart-type" select="if (ixsl:query-params()?chart-type) then xs:anyURI(ixsl:query-params()?chart-type) else xs:anyURI('&ac;Table')" as="xs:anyURI?"/>
        <xsl:param name="category" select="ixsl:query-params()?category" as="xs:string?"/>
        <xsl:param name="series" select="ixsl:query-params()?series" as="xs:string*"/>
        <xsl:param name="chart-type-id" select="'chart-type'" as="xs:string"/>
        <xsl:param name="category-id" select="'category'" as="xs:string"/>
        <xsl:param name="series-id" select="'series'" as="xs:string"/>
        <xsl:param name="width" as="xs:string?"/>
        <xsl:param name="height" select="'480'" as="xs:string?"/>
        <xsl:param name="uri" as="xs:anyURI?"/>
        <!-- <xsl:param name="mode" as="xs:anyURI*"/> -->
        <xsl:param name="service" select="xs:anyURI(ixsl:query-params()?service)" as="xs:anyURI?"/>
        <xsl:param name="query" as="xs:string?"/>
        <xsl:param name="show-controls" select="true()" as="xs:boolean"/>
        <xsl:param name="show-save" select="ixsl:contains(ixsl:window(), 'LinkedDataHub.select-uri')" as="xs:boolean"/>

        <xsl:if test="$show-controls">
            <form method="{$method}" action="{$action}">
                <xsl:if test="$id">
                    <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="$class">
                    <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="$accept-charset">
                    <xsl:attribute name="accept-charset"><xsl:value-of select="$accept-charset"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="$enctype">
                    <xsl:attribute name="enctype"><xsl:value-of select="$enctype"/></xsl:attribute>
                </xsl:if>

                <fieldset>
                    <xsl:if test="$show-save">
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'rdf'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'sb'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'chart'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&rdf;type'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ou'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="$type"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&spin;query'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ou'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="ixsl:get(ixsl:window(), 'LinkedDataHub.select-uri')"/> <!-- SELECT URI -->
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&foaf;isPrimaryTopicOf'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ob'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'this'"/>
                        </xsl:call-template>

                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&apl;service'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ou'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="resolve-uri('sparql', $ldt:base)"/>
                        </xsl:call-template>
                    </xsl:if>

<!--                    <div class="row-fluid">
                        <div class="span12">
                            <xsl:call-template name="xhtml:Input">
                                <xsl:with-param name="name" select="'pu'"/>
                                <xsl:with-param name="type" select="'hidden'"/>
                                <xsl:with-param name="value" select="'&apl;endpoint'"/>
                            </xsl:call-template>

                            <label for="endpoint-uri">Endpoint</label>
                            <xsl:text> </xsl:text>
                                <select id="endpoint-uri" name="ou" class="input-xxlarge">
                                    <option value="{resolve-uri('sparql', $ldt:base)}">[SPARQL endpoint]</option>

                                    <xsl:for-each select="document(resolve-uri('services/', $ldt:base))//*[sd:endpoint/@rdf:resource]" use-when="system-property('xsl:product-name') = 'SAXON'">
                                        <xsl:sort select="ac:label(.)"/>

                                        <xsl:apply-templates select="." mode="xhtml:Option">
                                            <xsl:with-param name="value" select="sd:endpoint/@rdf:resource"/>
                                            <xsl:with-param name="selected" select="sd:endpoint/@rdf:resource = $endpoint"/>
                                        </xsl:apply-templates>
                                    </xsl:for-each>
                                    <xsl:if test="true()"  use-when="system-property('xsl:product-name') eq 'Saxon-JS'">
                                        <xsl:variable name="query" select="'DESCRIBE ?service { GRAPH ?g { ?service &lt;&sd;endpoint&gt; ?endpoint } }'"/>
                                        <ixsl:schedule-action http-request="map{ 'method': 'GET', 'href': resolve-uri(concat('sparql?query=', encode-for-uri($query)), $ldt:base), 'headers': map{ 'Accept': 'application/rdf+xml' } }">
                                            <xsl:call-template name="onchartModeServiceLoad"/>
                                        </ixsl:schedule-action>
                                    </xsl:if>
                            </select>
                        </div>
                    </div>-->
                    <div class="row-fluid">
                        <div class="span4">
                            <xsl:if test="$show-save">
                                <xsl:call-template name="xhtml:Input">
                                    <xsl:with-param name="name" select="'pu'"/>
                                    <xsl:with-param name="type" select="'hidden'"/>
                                    <xsl:with-param name="value" select="'&apl;chartType'"/>
                                </xsl:call-template>
                            </xsl:if>

                            <label for="{$chart-type-id}">
                                <xsl:apply-templates select="key('resources', '&apl;chartType', document('&apl;'))" mode="ac:label" use-when="system-property('xsl:product-name') = 'SAXON'"/>
                                <xsl:value-of use-when="system-property('xsl:product-name') eq 'Saxon-JS'">Chart type</xsl:value-of>
                            </label>
                            <br/>
                            <!-- TO-DO: replace with xsl:apply-templates on ac:Chart subclasses as in imports/apl.xsl -->
                            <select id="{$chart-type-id}" name="ou" class="input-medium">
                                <option value="&ac;Table">
                                    <xsl:if test="$chart-type = '&ac;Table'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>

                                    <xsl:text>Table</xsl:text>
                                </option>
                                <option value="&ac;ScatterChart">
                                    <xsl:if test="$chart-type = '&ac;ScatterChart'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>

                                    <xsl:text>Scatter chart</xsl:text>
                                </option>
                                <option value="&ac;LineChart">
                                    <xsl:if test="$chart-type = '&ac;LineChart'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>

                                    <xsl:text>Line chart</xsl:text>
                                </option>
                                <option value="&ac;BarChart">
                                    <xsl:if test="$chart-type = '&ac;BarChart'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>

                                    <xsl:text>Bar chart</xsl:text>
                                </option>
                                <option value="&ac;Timeline">
                                    <xsl:if test="$chart-type = '&ac;Timeline'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>

                                    <xsl:text>Timeline</xsl:text>
                                </option>
                            </select>
                        </div>
                        <div class="span4">
                            <xsl:if test="$show-save">
                                <xsl:call-template name="xhtml:Input">
                                    <xsl:with-param name="name" select="'pu'"/>
                                    <xsl:with-param name="type" select="'hidden'"/>
                                    <xsl:with-param name="value" select="'&apl;categoryProperty'"/>
                                </xsl:call-template>
                            </xsl:if>

                            <label for="{$category-id}">Category</label>
                            <br/>
                            <select id="{$category-id}" name="ou" class="input-large">
                                <option value="">
                                    <!-- URI is the default category -->
                                    <xsl:if test="not($category)">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>

                                    <xsl:text>[URI/ID]</xsl:text>
                                </option>

                                <xsl:for-each-group select="*/*" group-by="concat(namespace-uri(), local-name())">
                                    <xsl:sort select="ac:property-label(.)" order="ascending" lang="{$ldt:lang}" use-when="system-property('xsl:product-name') = 'SAXON'"/>
                                    <xsl:sort select="ac:property-label(.)" order="ascending" use-when="system-property('xsl:product-name') eq 'Saxon-JS'"/>

                                    <option value="{current-grouping-key()}">
                                        <xsl:if test="$category = current-grouping-key()">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>

                                        <xsl:apply-templates select="current-group()[1]" mode="ac:property-label"/>
                                    </option>
                                </xsl:for-each-group>
                            </select>
                        </div>
                        <div class="span4">
                            <xsl:if test="$show-save">
                                <xsl:call-template name="xhtml:Input">
                                    <xsl:with-param name="name" select="'pu'"/>
                                    <xsl:with-param name="type" select="'hidden'"/>
                                    <xsl:with-param name="value" select="'&apl;seriesProperty'"/>
                                </xsl:call-template>
                            </xsl:if>

                            <label for="{$series-id}">Series</label>
                            <br/>
                            <select id="{$series-id}" name="ou" multiple="multiple" class="input-large">
                                <xsl:for-each-group select="*/*" group-by="concat(namespace-uri(), local-name())">
                                    <xsl:sort select="ac:property-label(.)" order="ascending" lang="{$ldt:lang}" use-when="system-property('xsl:product-name') = 'SAXON'"/>
                                    <xsl:sort select="ac:property-label(.)" order="ascending" use-when="system-property('xsl:product-name') eq 'Saxon-JS'"/>

                                    <option value="{current-grouping-key()}">
                                        <xsl:if test="$series = current-grouping-key()">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>

                                        <xsl:apply-templates select="current-group()[1]" mode="ac:property-label"/>
                                    </option>
                                </xsl:for-each-group>
                            </select>
                        </div>
                    </div>
                    <xsl:if test="$show-save">
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&dct;title'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="id" select="'chart-title'"/>
                            <xsl:with-param name="name" select="'ol'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&foaf;isPrimaryTopicOf'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ob'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'this'"/>
                        </xsl:call-template>

                        <!-- ChartItem -->

                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'sb'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'this'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&sioc;has_container'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ou'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="resolve-uri('charts/', $ldt:base)"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&dct;title'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="id" select="'chart-doc-title'"/>
                            <xsl:with-param name="name" select="'ol'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&rdf;type'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ou'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="$doc-type"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&foaf;primaryTopic'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ob'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'chart'"/>
                        </xsl:call-template>
                    </xsl:if>
                </fieldset>
                <xsl:if test="$show-save">
                    <div class="form-actions">
                        <button class="btn btn-primary btn-save-chart" type="submit">
                            <xsl:apply-templates select="key('resources', 'save', document(resolve-uri('static/com/atomgraph/linkeddatahub/xsl/bootstrap/2.3.2/translations.rdf', $ac:contextUri)))" mode="apl:logo">
                                <xsl:with-param name="class" select="'btn btn-primary btn-save-chart'"/>
                            </xsl:apply-templates>
                        </button>
                    </div>
                </xsl:if>
            </form>
        </xsl:if>
    </xsl:template>

    <!-- table chart (for SPARQL XML results) -->

    <xsl:template match="srx:sparql" mode="bs2:Chart" use-when="system-property('xsl:product-name') eq 'Saxon-JS'">
        <xsl:param name="chart-type" select="xs:anyURI('&ac;Table')" as="xs:anyURI?"/>
        <xsl:param name="category" as="xs:string?"/>
        <xsl:param name="series" select="srx:head/srx:variable/@name" as="xs:string*"/>
        <!-- <xsl:param name="endpoint" as="xs:anyURI"/> -->
        <xsl:param name="canvas-id" select="'chart-canvas'" as="xs:string"/>

        <xsl:apply-templates select="." mode="bs2:ChartForm">
            <xsl:with-param name="chart-type" select="$chart-type"/>
            <xsl:with-param name="category" select="$category"/>
            <xsl:with-param name="series" select="$series"/>
        </xsl:apply-templates>

        <div id="{$canvas-id}"></div>
    </xsl:template>

    <xsl:template match="srx:sparql" mode="bs2:ChartForm" use-when="system-property('xsl:product-name') eq 'Saxon-JS'">
        <xsl:param name="method" select="'post'" as="xs:string"/>
        <xsl:param name="doc-type" select="resolve-uri('ns#ChartItem', $ldt:base)" as="xs:anyURI"/>
        <xsl:param name="type" select="resolve-uri('ns/default#ResultSetChart', $ldt:base)" as="xs:anyURI"/>
        <xsl:param name="action" select="resolve-uri(concat('charts/?forClass=', encode-for-uri(resolve-uri($type, $ldt:base))), $ldt:base)" as="xs:anyURI"/>
        <xsl:param name="id" as="xs:string?"/>
        <xsl:param name="class" select="'form-inline'" as="xs:string?"/>
        <xsl:param name="button-class" select="'btn'" as="xs:string?"/>
        <xsl:param name="accept-charset" select="'UTF-8'" as="xs:string?"/>
        <xsl:param name="enctype" as="xs:string?"/>
        <!-- table is the default chart type -->
        <xsl:param name="chart-type" select="if (ixsl:query-params()?chart-type) then xs:anyURI(ixsl:query-params()?chart-type) else xs:anyURI('&ac;Table')" as="xs:anyURI?"/>
        <xsl:param name="category" select="ixsl:query-params()?category" as="xs:string?"/>
        <xsl:param name="series" select="ixsl:query-params()?series" as="xs:string*"/>
        <xsl:param name="chart-type-id" select="'chart-type'" as="xs:string"/>
        <xsl:param name="category-id" select="'category'" as="xs:string"/>
        <xsl:param name="series-id" select="'series'" as="xs:string"/>
        <xsl:param name="width" as="xs:string?"/>
        <xsl:param name="height" select="'480'" as="xs:string?"/>
        <xsl:param name="uri" as="xs:anyURI?"/>
        <xsl:param name="mode" as="xs:anyURI*"/>
        <xsl:param name="service" select="xs:anyURI(ixsl:query-params()?service)" as="xs:anyURI?"/>
        <xsl:param name="query" as="xs:string?"/>
        <xsl:param name="show-controls" select="true()" as="xs:boolean"/>
        <xsl:param name="show-save" select="ixsl:contains(ixsl:window(), 'LinkedDataHub.select-uri')" as="xs:boolean"/>

        <xsl:if test="$show-controls">
            <form method="{$method}" action="{$action}">
                <xsl:if test="$id">
                    <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="$class">
                    <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="$accept-charset">
                    <xsl:attribute name="accept-charset"><xsl:value-of select="$accept-charset"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="$enctype">
                    <xsl:attribute name="enctype"><xsl:value-of select="$enctype"/></xsl:attribute>
                </xsl:if>

                <fieldset>
                    <xsl:if test="$show-save">
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'rdf'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'sb'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'chart'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&rdf;type'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ou'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="$type"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&spin;query'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ou'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="ixsl:get(ixsl:window(), 'LinkedDataHub.select-uri')"/> <!-- SELECT URI -->
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&foaf;isPrimaryTopicOf'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ob'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'this'"/>
                        </xsl:call-template>

                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&apl;service'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ou'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="$service"/>
                        </xsl:call-template>
                    </xsl:if>

<!--                    <div class="row-fluid">
                        <div class="span12">
                            <xsl:call-template name="xhtml:Input">
                                <xsl:with-param name="name" select="'pu'"/>
                                <xsl:with-param name="type" select="'hidden'"/>
                                <xsl:with-param name="value" select="'&apl;endpoint'"/>
                            </xsl:call-template>

                            <label for="endpoint-uri">Endpoint</label>
                            <xsl:text> </xsl:text>
                                <select id="endpoint-uri" name="ou" class="input-xxlarge">
                                    <option value="{resolve-uri('sparql', $ldt:base)}">[SPARQL endpoint]</option>

                                    <xsl:for-each select="document(resolve-uri('services/', $ldt:base))//*[sd:endpoint/@rdf:resource]" use-when="system-property('xsl:product-name') = 'SAXON'">
                                        <xsl:sort select="ac:label(.)"/>

                                        <xsl:apply-templates select="." mode="xhtml:Option">
                                            <xsl:with-param name="value" select="sd:endpoint/@rdf:resource"/>
                                            <xsl:with-param name="selected" select="sd:endpoint/@rdf:resource = $endpoint"/>
                                        </xsl:apply-templates>
                                    </xsl:for-each>
                                    <xsl:if test="true()"  use-when="system-property('xsl:product-name') eq 'Saxon-JS'">
                                        <xsl:variable name="query" select="'DESCRIBE ?service { GRAPH ?g { ?service &lt;&sd;endpoint&gt; ?endpoint } }'"/>
                                        <ixsl:schedule-action http-request="map{ 'method': 'GET', 'href': resolve-uri(concat('sparql?query=', encode-for-uri($query)), $ldt:base), 'headers': map{ 'Accept': 'application/rdf+xml' } }">
                                            <xsl:call-template name="onchartModeServiceLoad"/>
                                        </ixsl:schedule-action>
                                    </xsl:if>
                            </select>
                        </div>
                    </div>-->
                    <div class="row-fluid">
                        <div class="span4">
                            <xsl:if test="$show-save">
                                <xsl:call-template name="xhtml:Input">
                                    <xsl:with-param name="name" select="'pu'"/>
                                    <xsl:with-param name="type" select="'hidden'"/>
                                    <xsl:with-param name="value" select="'&apl;chartType'"/>
                                </xsl:call-template>
                            </xsl:if>

                            <label for="{$chart-type-id}">
                                <xsl:apply-templates select="key('resources', '&apl;chartType', document('&apl;'))" mode="ac:label" use-when="system-property('xsl:product-name') = 'SAXON'"/>
                                <xsl:value-of use-when="system-property('xsl:product-name') eq 'Saxon-JS'">Chart type</xsl:value-of>
                            </label>
                            <br/>
                            <select id="{$chart-type-id}" name="ou" class="input-medium">
                                <option value="&ac;Table">
                                    <xsl:if test="$chart-type = '&ac;Table'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>

                                    <xsl:text>Table</xsl:text>
                                </option>
                                <option value="&ac;ScatterChart">
                                    <xsl:if test="$chart-type = '&ac;ScatterChart'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>

                                    <xsl:text>Scatter chart</xsl:text>
                                </option>
                                <option value="&ac;LineChart">
                                    <xsl:if test="$chart-type = '&ac;LineChart'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>

                                    <xsl:text>Line chart</xsl:text>
                                </option>
                                <option value="&ac;BarChart">
                                    <xsl:if test="$chart-type = '&ac;BarChart'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>

                                    <xsl:text>Bar chart</xsl:text>
                                </option>
                                <option value="&ac;Timeline">
                                    <xsl:if test="$chart-type = '&ac;Timeline'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>

                                    <xsl:text>Timeline</xsl:text>
                                </option>
                            </select>
                        </div>
                        <div class="span4">
                            <xsl:call-template name="xhtml:Input">
                                <xsl:with-param name="name" select="'pu'"/>
                                <xsl:with-param name="type" select="'hidden'"/>
                                <xsl:with-param name="value" select="'&apl;categoryVarName'"/>
                            </xsl:call-template>

                            <label for="{$category-id}">Category</label>
                            <br/>
                            <select id="{$category-id}" name="ol" class="input-large">
                                <xsl:for-each select="srx:head/srx:variable">
                                    <!-- leave the original variable order so it can be controlled from query -->

                                    <option value="{@name}">
                                        <xsl:if test="$category = @name">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>

                                        <xsl:value-of select="@name"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                        <div class="span4">
                            <xsl:if test="$show-save">
                                <xsl:call-template name="xhtml:Input">
                                    <xsl:with-param name="name" select="'pu'"/>
                                    <xsl:with-param name="type" select="'hidden'"/>
                                    <xsl:with-param name="value" select="'&apl;seriesVarName'"/>
                                </xsl:call-template>
                            </xsl:if>

                            <label for="{$series-id}">Series</label>
                            <br/>
                            <select id="{$series-id}" name="ol" multiple="multiple" class="input-large">
                                <xsl:for-each select="srx:head/srx:variable">
                                    <!-- leave the original variable order so it can be controlled from query -->

                                    <option value="{@name}">
                                        <xsl:if test="$series = @name">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>

                                        <xsl:value-of select="@name"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                    </div>
                    
                    <xsl:if test="$show-save">
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&dct;title'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="id" select="'chart-title'"/>
                            <xsl:with-param name="name" select="'ol'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&foaf;isPrimaryTopicOf'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ob'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'this'"/>
                        </xsl:call-template>

                        <!-- ChartItem -->

                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'sb'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'this'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&dct;title'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="id" select="'chart-doc-title'"/>
                            <xsl:with-param name="name" select="'ol'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&rdf;type'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ou'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="$doc-type"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'pu'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'&foaf;primaryTopic'"/>
                        </xsl:call-template>
                        <xsl:call-template name="xhtml:Input">
                            <xsl:with-param name="name" select="'ob'"/>
                            <xsl:with-param name="type" select="'hidden'"/>
                            <xsl:with-param name="value" select="'chart'"/>
                        </xsl:call-template>
                    </xsl:if>
                </fieldset>
                <xsl:if test="$show-save">
                    <div class="form-actions">
                        <button class="btn btn-primary btn-save-chart" type="submit">
                            <xsl:apply-templates select="key('resources', 'save', document(resolve-uri('static/com/atomgraph/linkeddatahub/xsl/bootstrap/2.3.2/translations.rdf', $ac:contextUri)))" mode="apl:logo">
                                <xsl:with-param name="class" select="'btn btn-primary btn-save-chart'"/>
                            </xsl:apply-templates>
                        </button>
                    </div>
                </xsl:if>
            </form>
        </xsl:if>
    </xsl:template>

    <!-- EVENT LISTENERS -->

    <!-- facet onchange -->

    <xsl:template match="div[tokenize(@class, ' ') = 'faceted-nav']//input[@type = 'checkbox']" mode="ixsl:onchange">
        <!-- collect the values of all inputs with the same name as this one (in a single facet) -->
        <xsl:variable name="values" select="ancestor::ul//input[@name = current()/@name][ixsl:get(., 'checked') = true()]/ixsl:get(., 'value')" as="xs:string*"/>
        <xsl:variable name="var-name" select="@name" as="xs:string"/>

        <!-- TO-DO: unify? -->
        <xsl:choose>
            <!-- apply FILTER if any values were selected -->
            <xsl:when test="count($values) &gt; 0">
                <!-- sequence of length > 1 will be converted to JS array: https://www.saxonica.com/saxon-js/documentation/index.html#!xdm/conversions -->
                <xsl:variable name="value-uris" select="if (count($values) eq 1) then [ $values ] else array { $values }" as="array(xs:string)"/>
                <xsl:variable name="select-string" select="ixsl:get(ixsl:window(), 'LinkedDataHub.select-query')" as="xs:string"/>
                <xsl:variable name="select-builder" select="ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'SelectBuilder'), 'fromString', [ $select-string ])"/>
                <xsl:variable name="select-json-string" select="ixsl:call(ixsl:get(ixsl:window(), 'JSON'), 'stringify', [ ixsl:call($select-builder, 'build', []) ])" as="xs:string"/>
                <!-- add FILTER IN () if not present, and set IN () values -->
                <xsl:variable name="select-xml" as="element()">
                    <xsl:apply-templates select="json-to-xml($select-json-string)" mode="apl:add-or-append-filter-in">
                        <xsl:with-param name="var-name" select="$var-name" tunnel="yes"/>
                        <xsl:with-param name="values" select="$value-uris" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:variable name="select-json-string" select="xml-to-json($select-xml)" as="xs:string"/>
<xsl:message>
SELECT JSON: <xsl:value-of select="$select-json-string"/>
</xsl:message>
                
                <xsl:variable name="select-json" select="ixsl:call(ixsl:get(ixsl:window(), 'JSON'), 'parse', [ $select-json-string ])"/>
                <xsl:variable name="select-string" select="ixsl:call(ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'SelectBuilder'), 'fromQuery', [ $select-json ]), 'toString', [])" as="xs:string"/>

                <!-- pseudo JS code: SPARQLBuilder.SelectBuilder.fromString(select-builder).wherePattern(SPARQLBuilder.QueryBuilder.filter(SPARQLBuilder.QueryBuilder.in(QueryBuilder.var(varName), [ $value ]))) -->
<!--                <xsl:variable name="select-builder" select="ixsl:call($select-builder, 'wherePattern', [ ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'QueryBuilder'), 'filter', [ ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'QueryBuilder'), 'in', [ ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'QueryBuilder'), 'var', [ $var-name ]), $value-uris ]) ]) ])"/>
                <xsl:variable name="select-string" select="ixsl:call($select-builder, 'toString', [])" as="xs:string"/>-->

                <!-- set ?this variable value -->
                <xsl:variable name="select-string" select="replace($select-string, '\?this', concat('&lt;', $ac:uri, '&gt;'))" as="xs:string"/>
                <!-- wrap SELECT into DESCRIBE and set pagination modifiers -->
                <xsl:variable name="query-string" select="ac:build-describe($select-string, xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.limit')), xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.offset')), ixsl:get(ixsl:window(), 'LinkedDataHub.order-by'), ixsl:get(ixsl:window(), 'LinkedDataHub.desc'))" as="xs:string"/>
                <xsl:variable name="service" select="if (ixsl:contains(ixsl:window(), 'LinkedDataHub.service')) then ixsl:get(ixsl:window(), 'LinkedDataHub.service') else ()" as="element()?"/>
                <xsl:variable name="endpoint" select="xs:anyURI(($service/sd:endpoint/@rdf:resource, (if ($service/dydra:repository/@rdf:resource) then ($service/dydra:repository/@rdf:resource || 'sparql') else ()), $ac:endpoint)[1])" as="xs:anyURI"/>
                <!-- TO-DO: unify dydra: and dydra-urn: ? -->
                <xsl:variable name="results-uri" select="xs:anyURI(if ($service/dydra-urn:accessToken) then ($endpoint || '?auth_token=' || $service/dydra-urn:accessToken || '&amp;query=' || encode-for-uri($query-string)) else ($endpoint || '?query=' || encode-for-uri($query-string)))" as="xs:anyURI"/>

                <!-- set global SELECT query (without modifiers) -->
                <ixsl:set-property name="select-query" select="$select-string" object="ixsl:get(ixsl:window(), 'LinkedDataHub')"/>
                <!-- set global DESCRIBE query -->
                <ixsl:set-property name="describe-query" select="$query-string" object="ixsl:get(ixsl:window(), 'LinkedDataHub')"/>
        
                <ixsl:schedule-action http-request="map{ 'method': 'GET', 'href': $results-uri, 'headers': map{ 'Accept': 'application/rdf+xml' } }">
                    <xsl:call-template name="onContainerResultsLoad">
                        <xsl:with-param name="select-string" select="$select-string"/>
                    </xsl:call-template>
                </ixsl:schedule-action>
            </xsl:when>
            <!-- if not, execute original query -->
            <xsl:otherwise>
                <xsl:variable name="select-string" select="ixsl:get(ixsl:window(), 'LinkedDataHub.select-query')" as="xs:string"/>
                 <!-- set ?this variable value -->
                <xsl:variable name="select-string" select="replace($select-string, '\?this', concat('&lt;', $ac:uri, '&gt;'))" as="xs:string"/>
                <!-- wrap SELECT into DESCRIBE and set pagination modifiers -->
                <xsl:variable name="query-string" select="ac:build-describe($select-string, xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.limit')), xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.offset')), ixsl:get(ixsl:window(), 'LinkedDataHub.order-by'), ixsl:get(ixsl:window(), 'LinkedDataHub.desc'))" as="xs:string"/>
                <xsl:variable name="service" select="if (ixsl:contains(ixsl:window(), 'LinkedDataHub.service')) then ixsl:get(ixsl:window(), 'LinkedDataHub.service') else ()" as="element()?"/>
                <xsl:variable name="endpoint" select="xs:anyURI(($service/sd:endpoint/@rdf:resource, (if ($service/dydra:repository/@rdf:resource) then ($service/dydra:repository/@rdf:resource || 'sparql') else ()), $ac:endpoint)[1])" as="xs:anyURI"/>
                <!-- TO-DO: unify dydra: and dydra-urn: ? -->
                <xsl:variable name="results-uri" select="xs:anyURI(if ($service/dydra-urn:accessToken) then ($endpoint || '?auth_token=' || $service/dydra-urn:accessToken || '&amp;query=' || encode-for-uri($query-string)) else ($endpoint || '?query=' || encode-for-uri($query-string)))" as="xs:anyURI"/>

                <!-- set global SELECT query (without modifiers) -->
                <ixsl:set-property name="select-query" select="$select-string" object="ixsl:get(ixsl:window(), 'LinkedDataHub')"/>
                <!-- set global DESCRIBE query -->
                <ixsl:set-property name="describe-query" select="$query-string" object="ixsl:get(ixsl:window(), 'LinkedDataHub')"/>
        
                <ixsl:schedule-action http-request="map{ 'method': 'GET', 'href': $results-uri, 'headers': map{ 'Accept': 'application/rdf+xml' } }">
                    <xsl:call-template name="onContainerResultsLoad">
                        <xsl:with-param name="select-string" select="$select-string"/>
                    </xsl:call-template>
                </ixsl:schedule-action>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@* | node()" mode="apl:add-or-append-filter-in">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="json:array[@key = 'where']" mode="apl:add-or-append-filter-in" priority="1">
        <xsl:param name="var-name" as="xs:string" tunnel="yes"/>
        <xsl:param name="values" as="array(xs:string)" tunnel="yes"/>
        <xsl:variable name="var-filter" select="json:map[json:string[@key = 'type'] = 'filter'][json:map[@key = 'expression']/json:array[@key = 'args']/json:string eq '?' || $var-name]" as="element()?"/>
        <xsl:variable name="where" as="element()">
            <xsl:choose>
                <xsl:when test="$var-filter">
                    <xsl:copy-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="@* | node()" mode="#current"/>

                        <!-- append FILTER (?var IN ()) to WHERE-->
                        <json:map>
                            <json:string key="type">filter</json:string>
                            <json:map key="expression">
                                <json:string key="type">operation</json:string>
                                <json:string key="operator">in</json:string>
                                <json:array key="args">
                                    <json:string><xsl:text>?</xsl:text><xsl:value-of select="$var-name"/></json:string>
                                    <json:array>
                                        <!-- values -->
                                    </json:array>
                                </json:array>
                            </json:map>
                        </json:map>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- append value to IN() -->
        <xsl:apply-templates select="$where" mode="apl:append-filter-in-value">
            <xsl:with-param name="var-name" select="$var-name" tunnel="yes"/>
            <xsl:with-param name="values" select="$values" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="@* | node()" mode="apl:append-filter-in-value">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="json:map[json:string[@key = 'type'] = 'filter']/json:map[@key = 'expression']/json:array[@key = 'args']/json:array" mode="apl:append-filter-in-value" priority="1">
        <xsl:param name="var-name" as="xs:string" tunnel="yes"/>
        <xsl:param name="values" as="array(xs:string)" tunnel="yes"/>
        
        <xsl:copy>
            <xsl:if test="../json:string eq '?' || $var-name">
                <xsl:for-each select="1 to array:size($values)">
                    <xsl:variable name="pos" select="position()"/>
                    <json:string>
                        <xsl:value-of select="array:get($values, $pos)"/>
                    </json:string>
                </xsl:for-each>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- parallax onclick -->
    
    <xsl:template match="div[tokenize(@class, ' ') = 'parallax-nav']/ul/li/a" mode="ixsl:onclick">
        <xsl:variable name="predicate" select="input/@value" as="xs:anyURI"/>
        <xsl:variable name="select-string" select="ixsl:get(ixsl:window(), 'LinkedDataHub.select-query')" as="xs:string"/>
        <xsl:variable name="select-builder" select="ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'SelectBuilder'), 'fromString', [ $select-string ])"/>
        <xsl:variable name="var-name" select="substring-after(ixsl:get(ixsl:call($select-builder, 'build', []), 'variables')[1], '?')"/>
        <xsl:variable name="uuid" select="ixsl:call(ixsl:window(), 'generateUUID', [])" as="xs:string"/>
        <xsl:variable name="new-var-name" select="'subject' || translate($uuid, '-', '_')" as="xs:string"/>
        <xsl:variable name="triple" select="ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'QueryBuilder'), 'triple', [ ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'QueryBuilder'), 'var', [ $var-name ]), ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'QueryBuilder'), 'uri', [ $predicate ]), ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'QueryBuilder'), 'var', [ $new-var-name ]) ])"/>
        <xsl:variable name="bgp" select="ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'QueryBuilder'), 'bgp', [ [ $triple ] ])"/>
        <!-- pseudo JS code: QueryBuilder.graph(QueryBuilder.var("g" + generateUUID()), [ bgp ]) -->
        <xsl:variable name="graph" select="ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'QueryBuilder'), 'graph', [ ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'QueryBuilder'), 'var', [ 'graph' || translate($uuid, '-', '_') ]), [ $bgp ] ])"/>
        <!-- pseudo JS code: QueryBuilder.union([ bgp, graph ]) -->
        <xsl:variable name="union" select="ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'QueryBuilder'), 'union', [ [ $bgp, $graph ] ])"/>
        <!-- pseudo JS code: SPARQLBuilder.SelectBuilder.fromString(select-builder).where(graph) -->
        <xsl:variable name="select-builder" select="ixsl:call($select-builder, 'wherePattern', [ $union ])"/>
        <!-- pseudo JS code: SelectBuilder.fromString(query).variables([ SelectBuilder.var("whatever") ]).build(); -->
        <xsl:variable name="select-builder" select="ixsl:call($select-builder, 'variables', [ [ ixsl:call(ixsl:get(ixsl:get(ixsl:window(), 'SPARQLBuilder'), 'QueryBuilder'), 'var', [ $new-var-name ]) ] ])"/>
        <xsl:variable name="select-string" select="ixsl:call($select-builder, 'toString', [])" as="xs:string"/>
        <!-- wrap SELECT into DESCRIBE and set pagination modifiers -->
        <xsl:variable name="query-string" select="ac:build-describe($select-string, xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.limit')), xs:integer(ixsl:get(ixsl:window(), 'LinkedDataHub.offset')), ixsl:get(ixsl:window(), 'LinkedDataHub.order-by'), ixsl:get(ixsl:window(), 'LinkedDataHub.desc'))" as="xs:string"/>
        
        <!-- set global SELECT query (without modifiers) -->
        <ixsl:set-property name="select-query" select="$select-string" object="ixsl:get(ixsl:window(), 'LinkedDataHub')"/>
        <!-- set global DESCRIBE query -->
        <ixsl:set-property name="describe-query" select="$query-string" object="ixsl:get(ixsl:window(), 'LinkedDataHub')"/>

        <xsl:variable name="service" select="if (ixsl:contains(ixsl:window(), 'LinkedDataHub.service')) then ixsl:get(ixsl:window(), 'LinkedDataHub.service') else ()" as="element()?"/>
        <xsl:variable name="endpoint" select="xs:anyURI(($service/sd:endpoint/@rdf:resource, (if ($service/dydra:repository/@rdf:resource) then ($service/dydra:repository/@rdf:resource || 'sparql') else ()), $ac:endpoint)[1])" as="xs:anyURI"/>
        <!-- TO-DO: unify dydra: and dydra-urn: ? -->
        <xsl:variable name="results-uri" select="xs:anyURI(if ($service/dydra-urn:accessToken) then ($endpoint || '?auth_token=' || $service/dydra-urn:accessToken || '&amp;query=' || encode-for-uri($query-string)) else ($endpoint || '?query=' || encode-for-uri($query-string)))" as="xs:anyURI"/>

        <ixsl:schedule-action http-request="map{ 'method': 'GET', 'href': $results-uri, 'headers': map{ 'Accept': 'application/rdf+xml' } }">
            <xsl:call-template name="onContainerResultsLoad">
                <xsl:with-param name="select-string" select="$select-string"/>
            </xsl:call-template>
        </ixsl:schedule-action>
    </xsl:template>

</xsl:stylesheet>