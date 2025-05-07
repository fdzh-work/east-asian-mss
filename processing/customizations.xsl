<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:bod="http://www.bodleian.ox.ac.uk/bdlss"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei html xs bod"
    version="2.0">
    
    

    <!-- The stylesheet is a library. It doesn't validate and won't produce HTML on its own. It is called by 
         convert2HTML.xsl and previewManuscript.xsl. Any templates added below will override the templates 
         in msdesc2html.xsl in the consolidated-tei-schema repository, allowing customization of manuscript 
         display for each catalogue. -->

    <xsl:template match="msDesc/msIdentifier/altIdentifier[child::idno[not(@subtype)]]">
        <xsl:choose>
            <xsl:when test="idno[not(@subtype)]/@type='SCN'">
                <p>
                    <xsl:text>Summary Catalogue no.: </xsl:text>
                    <xsl:apply-templates/>
                </p>
            </xsl:when>
            <xsl:when test="idno[not(@subtype)]/@type='TM' or idno/@type='TM'">
                <p>
                    <xsl:text>Trismegistos no.: </xsl:text>
                    <xsl:apply-templates/>
                </p>
            </xsl:when>
            <xsl:when test="idno[not(@subtype)]/@type='PR'">
                <p>
                    <xsl:text>Papyrological Reference: </xsl:text>
                    <xsl:apply-templates/>
                </p>
            </xsl:when>
            <xsl:when test="idno[not(@subtype)]/@type='diktyon'">
                <p>
                    <xsl:text>Diktyon no.: </xsl:text>
                    <xsl:apply-templates/>
                </p>
            </xsl:when>
            <xsl:when test="idno[not(@subtype)]/@type='LDAB'">
                <p>
                    <xsl:text>LDAB no.: </xsl:text>
                    <xsl:apply-templates/>
                </p>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="msDesc/msIdentifier/altIdentifier[@type='former' and child::idno[not(@subtype)]]">
        <p>
            <xsl:text>Former shelfmark: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    

    <!-- Append the calendar if it does not appear to have been mentioned in the origDate text -->
    <xsl:template match="origDate[@calendar]">
        <span class="{name()}">
            <xsl:apply-templates/>
            <xsl:choose>
                <xsl:when test="@calendar = ('#Hijri-qamari', 'Hijri-qamari') and not(matches(string-join(.//text(), ''), '[\d\s](H|AH|A\.H|Hijri)'))">
                    <xsl:text> AH</xsl:text>
                </xsl:when>
                <xsl:when test="@calendar = ('#Gregorian', 'Gregorian') and not(matches(string-join(.//text(), ''), '[\d\s](CE|AD|C\.E|A\.D|Gregorian)'))">
                    <xsl:text> CE</xsl:text>
                </xsl:when>
            </xsl:choose>
        </span>
        <xsl:variable name="nextelem" select="following-sibling::*[1]"/>
        <xsl:if test="following-sibling::*[self::origDate] and not(following-sibling::node()[1][self::text()][string-length(normalize-space(.)) gt 0])">
            <!-- Insert a semi-colon between adjacent dates without text between them -->
            <xsl:text>; </xsl:text>
        </xsl:if>
    </xsl:template>
    

    <!-- The next three templates override the default by putting authors, editors and titles on separate lines, because in Fihirst 
         there are often multiple titles in different languages, and versions of the author name in different languages, which gets 
         confusing all on one line. Also added is a customization for BL, to treat their "viaf_123" or "Viaf_123" key values as if 
         they were "person_123" in author and editor elements. -->
    <xsl:template match="msItem/author">
        <xsl:variable name="rolelabel" as="xs:string" select="if(@role) then bod:personRoleLookup(concat('aut ', @role)) else 'Author'"/>
        <div class="tei-author">
            <span class="tei-label">
                <xsl:value-of select="$rolelabel"/>
                <xsl:text>: </xsl:text>
            </span>
            <xsl:variable name="keys" select="tokenize(@key, '\s+')[string-length(.) gt 0]"/>
            <xsl:choose>
                <xsl:when test="some $key in $keys satisfies (starts-with($key, 'person_') or starts-with(lower-case($key), 'viaf_'))">
                    <xsl:variable name="key" select="$keys[starts-with(., 'person_') or starts-with(lower-case(.), 'viaf_')][1]"/>
                    <a class="author">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$website-url"/>
                            <xsl:text>/catalog/</xsl:text>
                            <xsl:value-of select="if (starts-with(lower-case($key), 'viaf_')) then concat('person_', substring-after($key, '_')) else $key"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <xsl:template match="msItem/title">
        <div class="tei-title">
            <span class="tei-label">
                <xsl:copy-of select="bod:standardText('Title:')"/>
                <xsl:text> </xsl:text>
            </span>
            <xsl:variable name="keys" select="tokenize(@key, '\s+')[string-length(.) gt 0]"/>
            <xsl:choose>
                <xsl:when test="some $key in $keys satisfies starts-with($key, 'work_')">
                    <xsl:variable name="key" select="$keys[starts-with(., 'work_')][1]"/>
                    <a>
                        <xsl:if test="not(@type = 'desc')">
                            <xsl:attribute name="class" select="'italic'"/>
                        </xsl:if>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$website-url"/>
                            <xsl:text>/catalog/</xsl:text>
                            <xsl:value-of select="$key"/>
                        </xsl:attribute>
                        <xsl:copy-of select="bod:direction(.)"/>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <span>
                        <xsl:if test="not(@type = 'desc')">
                            <xsl:attribute name="class" select="'italic'"/>
                        </xsl:if>
                        <xsl:copy-of select="bod:direction(.)"/>
                        <xsl:apply-templates/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <xsl:template match="msItem/editor">
        <xsl:variable name="rolelabel" as="xs:string" select="if(@role) then bod:personRoleLookup(@role) else 'Editor'"/>
        <div class="tei-editor">
            <span class="tei-label">
                <xsl:value-of select="$rolelabel"/>
                <xsl:text>: </xsl:text>
            </span>
            <xsl:variable name="keys" select="tokenize(@key, '\s+')[string-length(.) gt 0]"/>
            <xsl:choose>
                <xsl:when test="some $key in $keys satisfies (starts-with($key, 'person_') or starts-with(lower-case($key), 'viaf_'))">
                    <xsl:variable name="key" select="$keys[starts-with(., 'person_') or starts-with(lower-case(.), 'viaf_')][1]"/>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$website-url"/>
                            <xsl:text>/catalog/</xsl:text>
                            <xsl:value-of select="if (starts-with(lower-case($key), 'viaf_')) then concat('person_', substring-after($key, '_')) else $key"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

</xsl:stylesheet>
