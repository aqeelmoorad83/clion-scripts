<!--
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" indent="yes" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>
<xsl:decimal-format decimal-separator="." grouping-separator=","/>

<xsl:template match="testsuites">
<html>
  <head>
    <title>GTest Results</title>
    <style type="text/css">
      body {
        font-family:arial,helvetica neue,helvetica,sans-serif;
        color:#000000;
        font-size:68%;
      }
      table.details tr th {
        font-weight:bold;
        text-align:left;
        background:#a6caf0;
      }
      table.details tr td {
        background:#eeeee0;
      }
      h1 {
        margin:0px 0px 5px;
        font-size:200%;
      }
      h2 {
        margin-top:1em;
        margin-bottom:0.5em;
        font-size:150%;
      }
      h3 {
        margin-top:2em;
        margin-bottom:0.5em;
        font-size:115%;
      }
      .Failure {
        font-weight:bold; color:red;
      }
      .Skipped {
        color:#777770;
      }
    </style>
  </head>
  <body>
    <!-- Header -->
    <a name="top"/>
    <h1>GTest Results</h1>
    <hr size="1"/>

    <!-- Summary -->
    <xsl:call-template name="summary"/>
    <hr size="1" width="95%" align="left"/>

    <!-- For each testsuite -->
    <xsl:for-each select="testsuite">
      <xsl:sort select="@name"/>
      <h3><a name="{@name}"/><a href="#{@name}"><xsl:value-of select="@name"/></a></h3>
      <table class="details" border="0" cellpadding="5" cellspacing="2" width="95%">
        <xsl:call-template name="testcase.test.header"/>
        <xsl:apply-templates select="./testcase" mode="print.test"/>
      </table>
      <br/>
      <a href="#top">Back to top</a>
    </xsl:for-each>

	 <!-- Some blank space at the bottom so if the last testsuite is small, links to it work properly -->
    <br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
    <br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
    <br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
    <br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
  </body>
</html>
</xsl:template>

<xsl:template name="summary">
  <h2>Summary</h2>
  <xsl:variable name="allTests" select="@tests"/>
  <xsl:variable name="allFailures" select="@failures"/>
  <xsl:variable name="allSkipped" select="@disabled"/>
  <table class="details" border="0" cellpadding="5" cellspacing="2" width="95%">
    <tr valign="top">
      <th>Suite</th>
      <th>Tests</th>
      <th>Failures</th>
      <th>Skipped</th>
      <th>Success rate</th>
      <th>Time</th>
    </tr>
    <tr valign="top">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="$allFailures &gt; 0">Failure</xsl:when>
          <xsl:otherwise>TableRowColor</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <td><b>&lt;All&gt;</b></td>
      <td><xsl:value-of select="$allTests"/></td>
      <td><xsl:value-of select="$allFailures"/></td>
      <td><xsl:value-of select="$allSkipped"/></td>
      <td>
        <xsl:call-template name="display-percent">
          <xsl:with-param name="value" select="($allTests - $allFailures - $allSkipped) div $allTests"/>
        </xsl:call-template>
      </td>
      <td>
        <xsl:call-template name="display-time">
          <xsl:with-param name="value" select="@time"/>
        </xsl:call-template>
      </td>
    </tr>
    <xsl:for-each select="testsuite">
      <xsl:sort select="@name"/>
      <xsl:variable name="suiteTests" select="@tests"/>
      <xsl:variable name="suiteFailures" select="@failures"/>
      <xsl:variable name="suiteSkipped" select="@disabled"/>
      <tr valign="top">
        <xsl:attribute name="class">
          <xsl:choose>
            <xsl:when test="$suiteFailures &gt; 0">Failure</xsl:when>
            <xsl:otherwise>TableRowColor</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <td>
          <a href="#{@name}">
            <xsl:attribute name="class">
              <xsl:choose>
                <xsl:when test="$suiteFailures &gt; 0">Failure</xsl:when>
                <xsl:otherwise>TableRowColor</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="@name"/>
          </a>
        </td>
        <td><xsl:value-of select="$suiteTests"/></td>
        <td><xsl:value-of select="$suiteFailures"/></td>
        <td><xsl:value-of select="$suiteSkipped"/></td>
        <td>
          <xsl:call-template name="display-percent">
            <xsl:with-param name="value" select="($suiteTests - $suiteFailures - $suiteSkipped) div $suiteTests"/>
          </xsl:call-template>
        </td>
        <td>
          <xsl:call-template name="display-time">
            <xsl:with-param name="value" select="@time"/>
          </xsl:call-template>
        </td>
      </tr>
    </xsl:for-each>
  </table>
  <br/>
</xsl:template>

<xsl:template name="testcase.test.header">
  <tr valign="top">
    <th>Name</th>
    <th>Status</th>
    <th width="80%">Message</th>
    <th nowrap="nowrap">Time(s)</th>
  </tr>
</xsl:template>

<xsl:template match="testcase" mode="print.test">
  <tr valign="top">
    <xsl:attribute name="class">
      <xsl:choose>
        <xsl:when test="@status='notrun'">Skipped</xsl:when>
        <xsl:otherwise>TableRowColor</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:choose>
      <xsl:when test="@status='notrun'">
        <td><xsl:value-of select="substring(@name, 10)"/></td>
        <td>Skipped</td>
        <td/>
      </xsl:when>
      <xsl:when test="failure">
        <td><xsl:value-of select="@name"/></td>
        <td class="Failure">Failure</td>
        <td><xsl:apply-templates select="failure"/></td>
      </xsl:when>
      <xsl:otherwise>
        <td><xsl:value-of select="@name"/></td>
        <td>Success</td>
        <td/>
      </xsl:otherwise>
    </xsl:choose>
    <td>
      <xsl:call-template name="display-time">
        <xsl:with-param name="value" select="@time"/>
      </xsl:call-template>
    </td>
  </tr>
</xsl:template>

<xsl:template match="failure">
  <xsl:choose>
    <xsl:when test="not(@message)">N/A</xsl:when>
    <xsl:otherwise><xsl:value-of select="@message"/></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="display-time">
  <xsl:param name="value"/>
  <xsl:value-of select="format-number($value,'0.000')"/>
</xsl:template>

<xsl:template name="display-percent">
  <xsl:param name="value"/>
  <xsl:value-of select="format-number($value,'0.00%')"/>
</xsl:template>

</xsl:stylesheet>
