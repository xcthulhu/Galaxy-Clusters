<TeXmacs|1.0.7.10>

<style|amsart>

<\body>
  <doc-data|<doc-title|Progress Report>|<doc-author-data|<author-name|Matthew
  P. Wampler-Doty>|<author-email|matt@w-d.org>>>

  <\abstract>
    In this report, we detail efforts to produce an automated, large scale
    survey of distant (<math|z\<in\> [.05,.3]>) galaxy clusters imaged by
    XMM, Chandra, and the Hubble Space Telescope, in search of X-Ray tidal
    flares. \ This research is follow up to work first presented in
    <cite|maksym_constraining_2010|maksym_tidal_2010>.
  </abstract>

  <section|Overview>

  There has been considerable attention to X-Ray tidal flare events, in large
  part due to exciting discoveries by the research team behind the SWIFT
  satellite <cite|bloom_possible_2011|metzger_afterglow_2011>. \ In our
  research, we study archival data from Chandra and XMM-Newton, searching for
  signs of relativistic outflows from tidal disruption events in distant,
  previously inactive galactic nuclei. \ Our research builds on previous work
  carried out in <cite|maksym_tidal_2010>; most of our efforts have been
  focused on developing automated processes for carrying out massive data
  analysis. \ The objective of our research is to try to estimate the
  universal rate in which these events occur. \ This research is intended as
  a follow up to <cite|maksym_constraining_2010|maksym_tidal_2010>.

  We detail our efforts in the subsequent sections. \ In
  Ÿ<reference|Agglomeration>, we go over our method for discovering and
  grouping observations for future analysis. \ In
  Ÿ<reference|Data_Retrieval>, we detail our methods of automated data
  retrieval and mention what we have already done. \ In
  Ÿ<reference|analysis>, we discuss progress made so far in automated data
  analysis. \ In Ÿ<reference|future> we outline the road ahead, detailing the
  work left to accomplish.

  The code written primarily utilizes GNU make and Python version 2.6+. \ It
  is provided for free on the web, for the inspection of any interested
  researcher:

  <\with|par-mode|center>
    <hlink|https://github.com/xcthulhu/Galaxy-Clusters|https://github.com/xcthulhu/Galaxy-Clusters>
  </with>

  <section|Observation Agglomeration and Classification><label|Agglomeration>

  <subsection|HEASARC Queries<label|heasarc><label|ACIS>>

  The first step in our analysis the automated retrieval of all of the entire
  catalog of Chandra and XMM legacy observations using the HEASARC database.
  \ We make use of python's <hlink|<with|font-family|tt|urllib>|http://docs.python.org/library/urllib.html>
  and <hlink|<with|font-family|tt|urllib2>|http://docs.python.org/library/urllib2.html>
  to carry out automated queries to a NASA's CGI script for interfacing this
  database<\footnote>
    NASA's CGI script for interfacing with HEASARC, using POST methods, can
    be found here: <hlink|http://heasarc.gsfc.nasa.gov/db-perl/W3Browse/w3query.pl|http://heasarc.gsfc.nasa.gov/db-perl/W3Browse/w3query.pl>
  </footnote>. \ Some additional filtering is necessary afterwords - in
  particular, observation IDs corresponding to planned observations and
  unreleased data are discarded, as well as all observations within
  <math|15<rprime|'>> of the galactic plane, and only Chandra observations
  using the ACIS are considers.

  Once all of the observations have been acquired, we face the following
  difficulty: the labels assigned to objects are not strictly consistent
  between missions. \ It is not feasible to use the tags provided by
  researchers to classify observations of the same object. \ Our solution is
  to use <with|font-shape|italic|hierarchical agglomerative clustering> to
  classify groups of observations geometrically by position in the sky,
  eliminating the need rely on labels.

  <subsection|Fast Complete Linkage Hierarchical Agglomerative
  Clustering<label|fastagglomeration>>

  Hierarchical agglomerative clustering is a technique commonly employed in
  <with|font-shape|italic|computational phylogenetic tree> research in
  evolutionary ecology <cite|press_section_2007>. \ We repurpose one of these
  algorithms for classifying groups of observations by position.

  Abstractly, hierarchical agglomerative clustering algorithms compute a tree
  representing hierarchical relationships between points in some set. In
  agglomerative clustering, each point is grouped with its nearest neighbor
  according to some metric and rule system. \ The system then recurses, only
  now over points and previously computed groups of points, building a new
  stage of the tree. The process ends when all of the points are grouped
  together. A terminal node of the resulting tree represents one the original
  points, while branches represent groups of points. We always use the
  <em|complete linkage> rule in our applications, where groups of points in
  the tree are labeled with a value representing the maximum distance the
  points are apart according to some metric.

  As of December 11, 2011 HEASARC reports that there are 12870 suitable
  archival observations between XMM and Chandra. We have found that given the
  number of observations, agglomerative clustering is intractable without a
  fast algorithm. The algorithm we use<\footnote>
    We use the <with|font-family|tt|fastcluster> python module, available
    here: <hlink|http://math.stanford.edu/~muellner/fastcluster.html|http://math.stanford.edu/~muellner/fastcluster.html>.
    The code implemented runs in <math|<with|math-font|cal|O>(n<rsup|2>)>
    time (where <math|n> is the number of points being clustered). \ Other
    library implementations of agglomerative clustering use algorithms that
    often run in <math|<with|math-font|cal|O>(n<rsup|3>>) time; this includes
    the <with|font-family|tt|scipy> python module and
    <with|font-family|tt|matlab>.
  </footnote> is given in <cite|defays_efficient_1977>.

  After computing the hierarchical agglomeration, we find each group of
  observations separated by at most <math|8<rprime|'>> and output the
  observation IDs of that group to a designated file. \ As of December 11,
  2011 the system computes 5846 groups of observations <math|8<rprime|'>>
  apart.

  Figure <reference|fig1> depicts the all of the groups of observations found
  by the algorithm that have 5 or more entries. The size of each node,
  designating a group of observations, is proportional to the <math|log(n)>,
  where <math|n> is the number of observations in that group.

  <\with|par-mode|center>
    <small-figure|FIXME|Groups of observations in the XMM and Chandra
    archives><label|fig1>
  </with>

  <subsection|NED Queries><label|ned>

  Not every group is suitable for analysis, as we are interested in galaxy
  clusters in particular. \ To find only those groups of observations
  corresponding to a galaxy cluster, we use Cal-tech's NED database as the
  basis of further processing. For each agglomeration of observations, we
  query NED to find all of the galaxy clusters within the vicinity. \ An
  arbitrary observation <math|O> from each group of observations is selected,
  and a query is sent to NED for all galaxy cluster objects in a
  <math|15<rprime|'>> radius of <math|O>. \ Queries are automated using a
  python script using <with|font-family|tt|urllib> and
  <with|font-family|tt|urllib2><\footnote>
    Cal-tech's NED database can be accessed using GET methods and the
    following CGI script: <hlink|http://ned.ipac.caltech.edu/cgi-bin/nph-objsearch|http://ned.ipac.caltech.edu/cgi-bin/nph-objsearch>
  </footnote>, just as in the case of HEASARC as discussed in
  Ÿ<reference|heasarc>.

  After all of the NED queries have been computed, the results are filtered
  such that only galaxy clusters with <math|z>-values in <math|[.05,.3]> are
  kept. \ Any agglomeration which does not have a suitable galaxy cluster in
  its vicinity is discarded.

  Figure <reference|fig2> depicts the results of this further filtering
  carried out on the groups of observations found in
  Ÿ<reference|fastagglomeration>. \ In addition, this figure uses
  transparency to reflect <math|z> values, with the most transparent
  reflecting a <math|z=.05> while the least transparent reflects <math|z=.3>.

  <\with|par-mode|center>
    <small-figure|FIXME|Groups of observations of galaxy
    clusters><label|fig2>
  </with>

  <section|Data Retrieval><label|Data_Retrieval>

  In this section we detail how data is retrieved corresponding to the
  previously grouped observations.

  After each group of suitable observations is found, we retrieve data files
  for each observation in those groups. \ In addition, we also retrieve HST
  data in the vicinity of each group of observations, in the interest of
  finding optical follow-ups to our found sources.

  To date, approximately 615 GB of data have been downloaded as part of our
  survey.

  <subsection|Chandra>

  Each Chandra observation is retrieved using the
  <with|font-family|tt|download_chandra_obsid> script, using the
  CIAO<\footnote>
    CIAO is available from the following website:
    <hlink|http://cxc.harvard.edu/ciao/|http://cxc.harvard.edu/ciao/>
  </footnote> data analysis software for chandra.

  <subsection|XMM>

  A python script was written to automate the acquisition of XMM-Newton data.
  \ Specifically, we automated interaction with the XSA online interface to
  XMM archive data<\footnote>
    The XSA website's CGI script can be found here:
    <hlink|http://xsa.esac.esa.int:8080/aio/jsp/product.jsp|http://xsa.esac.esa.int:8080/aio/jsp/product.jsp>
  </footnote>. \ After querying, the XSA CGI-script returns an HTML page
  containing an FTP address of the prepared data. \ Regular expressions are
  used to parse this webpage to acquire this FTP address. \ The data is then
  retrieved using the UNIX <with|font-family|tt|wget> facility.

  <subsection|Hubble>

  For each group of observations, all of the Hubble observations in the
  vicinity are found by querying the Space Telescope Science
  Institute<\footnote>
    A catalog of archival HST observations can be accessed using GET methods
    and the following CGI script: <hlink|http://archive.stsci.edu/hst/search.php|http://archive.stsci.edu/hst/search.php>
  </footnote>. \ After a catalog of HST observations is found for a given
  group of observations, those HST observations making use of the WFPC,
  WFPC2, WFC3, and ACS instruments are selected. \ This is done because these
  instruments provide the best optical imaging. \ From each entry, a URL is
  retrieved containing the archival data<\footnote>
    Data products are found using the specifications found in
    <hlink|http://www.stsci.edu/instruments/wfpc2/Wfpc2_dhb/wfpc2_ch22.html|http://www.stsci.edu/instruments/wfpc2/Wfpc2_dhb/wfpc2_ch22.html>
    . \ Files are retrieved using GET methods and the following CGI script:
    <hlink|http://www.stsci.edu/instruments/wfpc2/Wfpc2_dhb/wfpc2_ch22.html|http://www.stsci.edu/instruments/wfpc2/Wfpc2_dhb/wfpc2_ch22.html>
  </footnote> using the UNIX command <with|font-family|tt|wget>.

  <section|Data Analysis><label|analysis>

  In this section we detail how the data we have retrieved is analyzed. \ To
  date, we have focused on chandra data analysis. \ Note that as we mentioned
  in Ÿ<reference|ACIS>, we only look at the Chandra ACIS instrument. \ This
  due to the fact that this is the only instrument on Chandra with
  sub-arcsecond precision.

  <subsection|Chandra Reprocessing>

  Due to a number of errors in the preprocessing of the Chandra archival
  data, it is necessary to run a reprocessing script before any further data
  manipulation is performed<\footnote>
    A detailed discussion of the reasons for reprocessing Chandra data files
    can be found here: <hlink|http://cxc.harvard.edu/ciao4.4/threads/createL2/index.html|http://cxc.harvard.edu/ciao4.4/threads/createL2/index.html>
  </footnote>. \ Reprocessing is carried out using the
  <with|font-family|tt|chandra_repro> script from the CIAO software suite.

  <subsection|Chandra Band Extraction>

  After each chandra observation has been reprocessed, we extract particular
  energy bands from the newly produced <with|font-family|tt|evt2.fits> event
  files of (filtered) CCD events. \ This is done using the CIAO tool
  <with|font-family|tt|dmcopy><\footnote>
    The syntax used is <with|font-family|tt|dmcopy
    evt2.fits[energy\<gtr\><math|\<alpha\>>,energy\<less\><math|\<beta\>>]
    result.fits>, which extracts events with energy <math|\<eta\>> (in
    electron-Volts)where <math|\<eta\>\<in\>[\<alpha\>,\<beta\>]>
  </footnote>. \ We perform extraction for each of the following bands found
  in Table <reference|tab1>, defined in <cite|kim_chandra_2007>.

  <big-table|<tabular|<tformat|<cwith|1|1|1|2|cell-bborder|2px>|<cwith|1|6|1|2|cell-lborder|1px>|<cwith|1|6|1|2|cell-rborder|1px>|<cwith|6|6|1|2|cell-bborder|1px>|<cwith|1|1|1|2|cell-tborder|1px>|<table|<row|<cell|Band>|<cell|Energy>>|<row|<cell|Broad
  (B)>|<cell|0.3 -- 8 keV>>|<row|<cell|Soft (S)>|<cell|0.3 -- 2.5
  keV>>|<row|<cell|Harder (H)>|<cell|2.5 -- 8 keV>>|<row|<cell|Soft1
  (S<math|<rsub|1>>)>|<cell|0.3 -- 0.9 keV>>|<row|<cell|Soft2
  (S<math|<rsub|2>>)>|<cell|0.9 -- 2.5 keV>>>>>|<label|tab1>Chandra Energy
  Bands>

  <subsection|Chandra Source Detection>

  After each band is extracted, we use the CIAO facility
  <with|font-family|tt|wavdetect> to detect point sources. \ This method uses
  fast wavelet transforms to correlate Mexican hat wavelets<\footnote>
    A Mexican hat distribution is the second derivative of a Gaussian; in the
    1 dimensional case it follows <math|<frac|2|\<pi\><rsup|1/4> <sqrt|3
    \<sigma\> >><around*|(|1-<frac|t<rsup|2>|\<sigma\><rsup|2>>|)>e<rsup|-<frac|t<rsup|2>|2
    \<sigma\><rsup|2>>>=<frac|\<partial\><rsup|2>|\<partial\>t<rsup|2>>g> .
    \ The higher dimensional Mexican hat wavelet generalizes the 1
    dimensional second derivative to a Laplacian.
  </footnote> at different scales, selected by the user, and associates peaks
  with sources. The waves we correlate have as parameters
  <math|\<sigma\>\<in\><around*|{|1,<sqrt|2>,2,2<sqrt|2>,4,4<sqrt|2>,8|}>>.

  <subsection|Source Agglomeration><label|source_agg>

  After sources are detected for each chandra image, it is necessary to find
  common sources across multiple bands and images. \ We employ fast complete
  linkage agglomerative clustering, as we introduced in
  Ÿ<reference|fastagglomeration>, to achieve this. \ After clustering groups
  no bigger than <math|3<rprime|''>> apart are separated and cataloged.

  <section|Future Work><label|future>

  <subsection|Better Chandra Source Detection>

  Source detection does not make use of recent innovations in the CIAO
  software suite. \ Recent versions of wavdetect use Chandra's point spread
  function (PSF) that was originally found by engineers during ground
  calibration. \ Recently, CIAO can now compute the PSF for each individual
  image using the <with|font-family|tt|mkpsfmap> program. \ The
  observation-specific PSF can be used by <with|font-family|tt|wavdetect> to
  import source detection.

  <subsection|XMM Astrometry Correction><label|astrometry>

  We expect that XMM and Chandra may have some discrepancies between their
  astrometry; it is necessary to introduce adjustments to these images to
  bring them into alignment. \ We hope to use the
  <with|font-family|tt|geotran> matching package from IRAF<\footnote>
    The <with|font-family|tt|geotran> UNIX manual page is available online
    here: <hlink|http://iraf.noao.edu/scripts/irafhelp?geotran|http://iraf.noao.edu/scripts/irafhelp?geotran>
  </footnote>.\ 

  <subsection|XMM Band Extraction and Source Detection>

  Chandra energy levels <math|\<eta\>> may be converted to XMM-Newton energy
  levels <math|\<xi\>> using the following equation<\footnote>
    This equation may be determined by inspecting the equivalent energy
    levels of the two satellites listed on the following website:
    <hlink|http://heasarc.gsfc.nasa.gov/W3Browse/all/ic10xmmcxo.html|http://heasarc.gsfc.nasa.gov/W3Browse/all/ic10xmmcxo.html>
  </footnote>:

  <\equation*>
    \<xi\>\<approx\>0.09 \<eta\><rsup|2>+1.75 \<eta\>-.2
  </equation*>

  This means that the energy levels for the different bands are slightly
  altered from those for Chandra. \ Table <reference|tab2> summarizes these
  differences, rounded to 2 significant figures.

  <big-table|<tabular|<tformat|<cwith|1|1|1|2|cell-bborder|2px>|<cwith|1|6|1|2|cell-lborder|1px>|<cwith|1|6|1|2|cell-rborder|1px>|<cwith|6|6|1|2|cell-bborder|1px>|<cwith|1|1|1|2|cell-tborder|1px>|<cwith|1|6|3|3|cell-rborder|1px>|<cwith|6|6|3|3|cell-bsep|1px>|<cwith|6|6|3|3|cell-bborder|1px>|<cwith|1|1|3|3|cell-bborder|2px>|<cwith|1|1|3|3|cell-tborder|1px>|<table|<row|<cell|Band>|<cell|Chandra
  Energy>|<cell|XMM Energy>>|<row|<cell|Broad (B)>|<cell|0.3 -- 8
  keV>|<cell|<math|0.3> -- <math|8> keV>>|<row|<cell|Soft (S)>|<cell|0.3 --
  2.5 keV>|<cell|<math|0.3> -- 3.6 keV>>|<row|<cell|Harder (H)>|<cell|2.5 --
  8 keV>|<cell|3.6 -- 8 keV>>|<row|<cell|Soft1 (S<math|<rsub|1>>)>|<cell|0.3
  -- 0.9 keV>|<cell|0.3 -- 1.3 keV>>|<row|<cell|Soft2
  (S<math|<rsub|2>>)>|<cell|0.9 -- 2.5 keV>|<cell|1.3 -- 3.6
  keV>>>>>|<label|tab2>XMM vs. Chandra Energy Bands>\ 

  These energy levels are used as parameters for the SAS
  <with|font-family|tt|edetect_chain> script<\footnote>
    The SAS <with|font-family|tt|edetect_chain> script documentation can be
    found here: <hlink|http://xmm.esa.int/sas/8.0.0/doc/edetect_chain/index.html|http://xmm.esa.int/sas/8.0.0/doc/edetect_chain/index.html>
  </footnote>, which plays a similar rôle for XMM as
  <with|font-family|tt|wavdetect> plays for Chandra.

  <subsection|Source Agglomeration>

  \ After computing sources for XMM, it will be necessary to produce an
  agglomeration encompassing both Chandra and XMM detected sources. \ It is
  critical that the astrometry correction described in
  Ÿ<reference|astrometry> be completed prior to this step, otherwise we run
  we run the risk of error being introduced by systematic miscalibration.
  \ We intend to use the same approach described in Ÿ<reference|source_agg>.

  <subsection|XSPEC Flux Analysis>

  After groups of sources are found for each group of observations, we
  compute the flux around each source for each image, using
  <with|font-family|tt|xspec><\footnote>
    The documentation for <with|font-family|tt|xspec> can be found here:
    <hlink|http://heasarc.nasa.gov/xanadu/xspec/XspecManual.pdf|http://heasarc.nasa.gov/xanadu/xspec/XspecManual.pdf>
  </footnote>. \ Before computing fluxes, it is necessary to find an
  background region for each source, and filter out spurious background
  noise. \ To find background regions we will use the python package
  <with|font-family|tt|kapteyn> to find encompassing <math|1<rprime|''>>
  circles around each source. After each circle of background events is
  found, we break the background region up into quadrants, compute the
  average energy and standard deviation for each quadrant, and then throw
  away quadrants that deviate more than <math|3\<sigma\>> from the others. \ 

  Once the background regions and calculated, <with|font-family|tt|xspec>
  will be used to compute the source flux by black-body spectrum fitting.
  \ After fluxes are found for each group of sources, we will attempt to fit
  an exponential decay through time to the group of fluxes. \ Following the
  work presented in <cite|maksym_tidal_2010>, a point source flux decaying
  exponentially through time is construed as evidence of a tidal flare.

  <subsection|Estimate Observed Galaxy Count>

  As described in the introduction, this research is intended to present a
  follow up to <cite|maksym_constraining_2010>. \ We intend to compute an
  estimate or lower bound on the universal frequency of tidal flares. \ We
  hope to use known estimates of galaxy counts around these clusters when
  possible, although it may be necessary to automate estimating the number of
  galaxies.

  <subsection|Hubble Optical Analysis>

  Once candidate flares are found, we would ideally like to identify an
  optical counter-part. \ Given optical counter-parts we could then have
  candidates objects for red-shift estimation, which would corroborate our
  the theory that the tidal flares are originating from sources within the
  galaxy cluster. \ As with the case of Chandra and XMM, it may be necessary
  to perform astrometry corrections.

  <section|Conclusion>

  While a number of hurdles to our research have been overcome, many remain.
  \ Unfortunately, many of the software utilities we use have not been
  optimized for speed, rendering data analysis at the scale we wish to
  operate at difficult. \ Fortunately, our infrastructure uses open source
  and allows for ad hoc parallelism so any number of computers can be
  employed without needing to purchase proprietary software. \ We hope to
  have completed our survey of our 75 candidates soon.

  <\bibliography|bib|plain|bibliography.bib>
    <\bib-list|1>
      <bibitem*|1><label|bib-bloom_possible_2011>Joshua<nbsp>S. Bloom,
      Dimitrios Giannios, Brian<nbsp>D. Metzger, S.<nbsp>Bradley Cenko,
      Daniel<nbsp>A. Perley, Nathaniel<nbsp>R. Butler, Nial<nbsp>R. Tanvir,
      Andrew<nbsp>J. Levan, Paul<nbsp>T. O'<nbsp>Brien, Linda<nbsp>E.
      Strubbe, Fabio De<nbsp>Colle, Enrico Ramirez-Ruiz, William<nbsp>H. Lee,
      Sergei Nayakshin, Eliot Quataert, Andrew<nbsp>R. King, Antonino
      Cucchiara, James Guillochon, Geoffrey<nbsp>C. Bower, Andrew<nbsp>S.
      Fruchter, Adam<nbsp>N. Morgan, and Alexander<nbsp>J. van<nbsp>der
      Horst. <newblock>A possible relativistic jetted outburst from a massive
      black hole fed by a tidally disrupted star.
      <newblock><with|font-shape|italic|Science>, June 2011.

      <bibitem*|2><label|bib-defays_efficient_1977>D.<nbsp>Defays.
      <newblock>An efficient algorithm for a complete link method.
      <newblock><with|font-shape|italic|The Computer Journal>, 20(4):364
      --366, January 1977.

      <bibitem*|3><label|bib-kim_chandra_2007>Minsun Kim, Dong-Woo Kim,
      Belinda<nbsp>J. Wilkes, Paul<nbsp>J. Green, Eunhyeuk Kim, Craig<nbsp>S.
      Anderson, Wayne<nbsp>A. Barkhouse, Nancy<nbsp>R. Evans, Å½eljko
      IveziÄ‡, Margarita Karovska, Vinay<nbsp>L. Kashyap, Myung<nbsp>Gyoon
      Lee, Peter Maksym, Amy<nbsp>E. Mossman, John<nbsp>D. Silverman, and
      Harvey<nbsp>D. Tananbaum. <newblock>Chandra multiwavelength project
      X-Ray point source catalog. <newblock><with|font-shape|italic|The
      Astrophysical Journal Supplement Series>, 169(2):401--429, April 2007.

      <bibitem*|4><label|bib-maksym_constraining_2010>P.<nbsp>Maksym and MP
      Ulmer. <newblock>Constraining the tidal flare rate with rich galaxy
      clusters. <newblock>In <with|font-shape|italic|Bulletin of the American
      Astronomical Society>, volume<nbsp>42, page 665, 2010.

      <bibitem*|5><label|bib-maksym_tidal_2010>W.P. Maksym, MP Ulmer, and
      M.<nbsp>Eracleous. <newblock>A tidal disruption flare in a1689 from an
      archival x-ray survey of galaxy clusters.
      <newblock><with|font-shape|italic|The Astrophysical Journal>, 722:1035,
      2010.

      <bibitem*|6><label|bib-metzger_afterglow_2011>Brian<nbsp>D Metzger,
      Dimitrios Giannios, and Petar Mimica. <newblock>Afterglow model for the
      radio emission from the jetted tidal disruption candidate swift
      j1644+57. <newblock><with|font-shape|italic|arXiv:1110.1111>, October
      2011.

      <bibitem*|7><label|bib-press_section_2007>William<nbsp>H. Press,
      Saul<nbsp>A. Teukolsky, William<nbsp>T. Vetterling, and Brian<nbsp>P.
      Flannery. <newblock>Section 16.4. hierarchical clustering by
      phylogenetic trees. <newblock>In <with|font-shape|italic|Numerical
      Recipes: The Art of Scientific Computing>, pages 868--883. Cambridge
      University Press, 3rd edition, September 2007.\ 
    </bib-list>
  </bibliography>
</body>

<\initial>
  <\collection>
    <associate|language|american>
    <associate|page-type|letter>
    <associate|sfactor|4>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|ACIS|<tuple|2.1|?>>
    <associate|Agglomeration|<tuple|2|1>>
    <associate|Data_Retrieval|<tuple|3|3>>
    <associate|analysis|<tuple|4|4>>
    <associate|astrometry|<tuple|5.2|?>>
    <associate|auto-1|<tuple|1|1>>
    <associate|auto-10|<tuple|3.2|4>>
    <associate|auto-11|<tuple|3.3|4>>
    <associate|auto-12|<tuple|4|4>>
    <associate|auto-13|<tuple|4.1|4>>
    <associate|auto-14|<tuple|4.2|4>>
    <associate|auto-15|<tuple|1|5>>
    <associate|auto-16|<tuple|4.3|5>>
    <associate|auto-17|<tuple|4.4|5>>
    <associate|auto-18|<tuple|5|5>>
    <associate|auto-19|<tuple|5.1|5>>
    <associate|auto-2|<tuple|2|1>>
    <associate|auto-20|<tuple|5.2|5>>
    <associate|auto-21|<tuple|5.3|5>>
    <associate|auto-22|<tuple|2|5>>
    <associate|auto-23|<tuple|5.4|5>>
    <associate|auto-24|<tuple|5.5|5>>
    <associate|auto-25|<tuple|5.6|5>>
    <associate|auto-26|<tuple|5.7|5>>
    <associate|auto-27|<tuple|6|?>>
    <associate|auto-28|<tuple|6|?>>
    <associate|auto-3|<tuple|2.1|1>>
    <associate|auto-4|<tuple|2.2|2>>
    <associate|auto-5|<tuple|1|3>>
    <associate|auto-6|<tuple|2.3|3>>
    <associate|auto-7|<tuple|2|3>>
    <associate|auto-8|<tuple|3|3>>
    <associate|auto-9|<tuple|3.1|3>>
    <associate|bib-bloom_possible_2011|<tuple|1|5>>
    <associate|bib-defays_efficient_1977|<tuple|2|6>>
    <associate|bib-kim_chandra_2007|<tuple|3|6>>
    <associate|bib-maksym_constraining_2010|<tuple|4|6>>
    <associate|bib-maksym_tidal_2010|<tuple|5|6>>
    <associate|bib-metzger_afterglow_2011|<tuple|6|6>>
    <associate|bib-press_section_2007|<tuple|7|6>>
    <associate|fastagglomeration|<tuple|2.2|2>>
    <associate|fig1|<tuple|1|3>>
    <associate|fig2|<tuple|2|3>>
    <associate|footnote-1|<tuple|1|1>>
    <associate|footnote-10|<tuple|10|4>>
    <associate|footnote-11|<tuple|11|4>>
    <associate|footnote-12|<tuple|12|5>>
    <associate|footnote-13|<tuple|13|5>>
    <associate|footnote-14|<tuple|14|?>>
    <associate|footnote-15|<tuple|15|?>>
    <associate|footnote-16|<tuple|16|?>>
    <associate|footnote-2|<tuple|2|2>>
    <associate|footnote-3|<tuple|3|2>>
    <associate|footnote-4|<tuple|4|2>>
    <associate|footnote-5|<tuple|5|3>>
    <associate|footnote-6|<tuple|6|3>>
    <associate|footnote-7|<tuple|7|4>>
    <associate|footnote-8|<tuple|8|4>>
    <associate|footnote-9|<tuple|9|4>>
    <associate|footnr-1|<tuple|1|1>>
    <associate|footnr-10|<tuple|10|4>>
    <associate|footnr-11|<tuple|11|4>>
    <associate|footnr-12|<tuple|12|5>>
    <associate|footnr-13|<tuple|13|5>>
    <associate|footnr-14|<tuple|14|?>>
    <associate|footnr-15|<tuple|15|?>>
    <associate|footnr-16|<tuple|16|?>>
    <associate|footnr-2|<tuple|2|2>>
    <associate|footnr-3|<tuple|3|2>>
    <associate|footnr-4|<tuple|4|2>>
    <associate|footnr-5|<tuple|5|3>>
    <associate|footnr-6|<tuple|6|3>>
    <associate|footnr-7|<tuple|7|4>>
    <associate|footnr-8|<tuple|8|4>>
    <associate|footnr-9|<tuple|9|4>>
    <associate|future|<tuple|5|5>>
    <associate|heasarc|<tuple|2.1|1>>
    <associate|ned|<tuple|2.3|3>>
    <associate|source_agg|<tuple|4.4|?>>
    <associate|tab1|<tuple|1|5>>
    <associate|tab2|<tuple|2|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|bib>
      maksym_constraining_2010

      maksym_tidal_2010

      bloom_possible_2011

      metzger_afterglow_2011

      maksym_tidal_2010

      maksym_constraining_2010

      maksym_tidal_2010

      press_section_2007

      defays_efficient_1977

      kim_chandra_2007

      maksym_tidal_2010

      maksym_constraining_2010
    </associate>
    <\associate|figure>
      <tuple|normal|Groups of observations in the XMM and Chandra
      archives|<pageref|auto-5>>

      <tuple|normal|Groups of observations of galaxy
      clusters|<pageref|auto-7>>
    </associate>
    <\associate|table>
      <tuple|normal|<label|tab1>Chandra Energy Bands|<pageref|auto-15>>

      <tuple|normal|<label|tab2>XMM vs. Chandra Energy
      Bands|<pageref|auto-22>>
    </associate>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1.<space|2spc>Overview>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2.<space|2spc>Observation
      Agglomeration and Classification> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>

      <with|par-left|<quote|1.5fn>|2.1.<space|2spc>HEASARC
      Queries<label|heasarc><label|ACIS> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3>>

      <with|par-left|<quote|1.5fn>|2.2.<space|2spc>Fast Complete Linkage
      Hierarchical Agglomerative Clustering<label|fastagglomeration>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>

      <with|par-left|<quote|1.5fn>|2.3.<space|2spc>NED Queries
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|3.<space|2spc>Data
      Retrieval> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-8><vspace|0.5fn>

      <with|par-left|<quote|1.5fn>|3.1.<space|2spc>Chandra
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-9>>

      <with|par-left|<quote|1.5fn>|3.2.<space|2spc>XMM
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-10>>

      <with|par-left|<quote|1.5fn>|3.3.<space|2spc>Hubble
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-11>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|4.<space|2spc>Data
      Analysis> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-12><vspace|0.5fn>

      <with|par-left|<quote|1.5fn>|4.1.<space|2spc>Chandra Reprocessing
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-13>>

      <with|par-left|<quote|1.5fn>|4.2.<space|2spc>Chandra Band Extraction
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-14>>

      <with|par-left|<quote|1.5fn>|4.3.<space|2spc>Chandra Source Detection
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-16>>

      <with|par-left|<quote|1.5fn>|4.4.<space|2spc>Source Agglomeration
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-17>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|5.<space|2spc>Future
      Work> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-18><vspace|0.5fn>

      <with|par-left|<quote|1.5fn>|5.1.<space|2spc>Better Chandra Source
      Detection <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-19>>

      <with|par-left|<quote|1.5fn>|5.2.<space|2spc>XMM Astrometry Correction
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-20>>

      <with|par-left|<quote|1.5fn>|5.3.<space|2spc>XMM Band Extraction and
      Source Detection <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-21>>

      <with|par-left|<quote|1.5fn>|5.4.<space|2spc>Source Agglomeration
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-23>>

      <with|par-left|<quote|1.5fn>|5.5.<space|2spc>XSPEC Flux Analysis
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-24>>

      <with|par-left|<quote|1.5fn>|5.6.<space|2spc>Estimate Observed Galaxy
      Count <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-25>>

      <with|par-left|<quote|1.5fn>|5.7.<space|2spc>Hubble Optical Analysis
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-26>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|6.<space|2spc>Conclusion>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-27><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|Bibliography>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-28><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>