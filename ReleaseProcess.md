# Introduction #

The DTGen release is complicated by the fact that DTGen is used to generate DTGen. The starting point for this circular process is the scripts used to create DTGen in the database. Accordingly, the source for DTGen are these scripts.

The DTGen release process follows "Common Branching Patterns" best practices from "Version Control with Subversion" (http://svnbook.red-bean.com/en/1.7/svn-book.html#svn.branchmerge.commonpatterns).

# SVN Version Information #

SQL\*Developer 3.1.07 Uses SVN/Kit 1.3.2<br>
SVN/Kit 1.3.2 Uses SVN Client 1.6.2<br>
<br>
Note: The latest TortoiseSVN Release uses SVN client 1.7<br>
SVN Client 1.7 is not compatible with SVN Client 1.6<br>
<br>
TortoiseSVN with the last 1.6 SVN client (1.6.17) can be downloaded at<br>
<a href='http://sourceforge.net/projects/tortoisesvn/files/1.6.16/Application/'>http://sourceforge.net/projects/tortoisesvn/files/1.6.16/Application/</a>

Subversion 1.6 compatability information can be found at<br>
<a href='http://subversion.apache.org/docs/release-notes/1.6.html'>http://subversion.apache.org/docs/release-notes/1.6.html</a>

<h1>DTGen Development/Modification</h1>

Since DTGen generates DTGen, the development/modification of DTGen requires a more complicated procedure.  An example procedure can be found at <a href='DTGenModificationProcedure.md'>DTGen Modification Procedure</a>.<br>
<br>
<h1>Pre-Release Procedures</h1>

<h2>Regression Testing</h2>

<blockquote>See TestPlan</blockquote>

<h2>Review and Test Demo</h2>

If a previous version of the demo is installed, remove it with the "drop_demo_users.sql" script in the "trunk/demo" directory.<br>
<br>
Review and test all demonstration scripts in the "trunk/demo" directory.<br>
<br>
<h2>Update Documentation</h2>

Review and update as needed the "README.txt" files.<br>
<br>
Review and update as needed the documents in the "docs" directory<br>
<br>
<h1>Release Procedure</h1>

<pre><code>  * Update "ver" in "generate" package body and compile<br>
  * Login to APEX<br>
     * Applications<br>
     * Run DTGen Application<br>
        * Login to DTGen Application<br>
        * Select Application "DTGEN"<br>
        * GoTo "FILES"<br>
        * "Generate Files"<br>
        * "Assemble Scripts"<br>
        * Download "dtgen_dataload.ctl" to "supp" directory<br>
        * Download "install_db.sql" to "src" directory<br>
        * Logout from DTGen Application<br>
        * Application 900<br>
     * Edit Application Properties<br>
        * Update Version Number<br>
        * Apply Changes<br>
     * Export/Import<br>
     * Export<br>
        * Application: 900 DTGen<br>
        * File Format: UNIX<br>
        * Owner Override: (empty)<br>
        * Build Status Override: Run and Build Application<br>
        * Debugging: Yes<br>
        * AsOf: (empty)<br>
        * Export Supporting Object Definitions:    Yes<br>
        * Export Public Interactive Reports:       Yes<br>
        * Export Private Interactive Reports:      No<br>
        * Export Interactive Report Subscriptions: No<br>
        * Export Developer Comments:               Yes<br>
        * Export Application<br>
        * Download "f900.sql" to "src" directory<br>
     * Logout from APEX<br>
  * Commit changes to Subversion<br>
  * Create a Release "branch" from "trunk" in Subversion<br>
     * Right-Click on ".../svn/trunk" -&gt; TortoiseSVN -&gt; Branch/Tag<br>
     * Set "To URL:" to ".../svn/branches/ReleaseNumber"<br>
     * Select "HEAD Revision in the repository"<br>
     * Set "Log Message" to "DTGen Release ReleaseNumber"<br>
     * Click "OK"<br>
  * Right-Click on ".../svn" -&gt; "SVN Update"<br>
  * Export the Release<br>
     * Create directory ".../Releases/dtgen_ReleaseNumber"<br>
     * Select ".../svn/branches/ReleaseNumber"<br>
     * Right-Click on ".../svn/branches/ReleaseNumber" -&gt; TortoiseSVN -&gt; Export<br>
     * URL of repository: ".../svn/branches/ReleaseNumber"<br>
     * Export Directory: ".../releases/dtgen_ReleaseNumber"<br>
     * "Fully Recursive"<br>
     * UNCHECKED Omit externals<br>
     * eol style: default<br>
     * HEAD revision<br>
     * Click "OK"<br>
  * Remove extra directories (dev and test)<br>
  * ZIP the export<br>
     * Goto the ".../Releases/dtgen_ReleaseNumber" directory<br>
     * Select all directories and files under ".../Releases/dtgen_ReleaseNumber"<br>
     * Rename the ZIP file to "dtgen_ReleaseNumber"<br>
  * Add to repository<br>
     -) Type-Archive<br>
     -) OpSys-Any?<br>
</code></pre>