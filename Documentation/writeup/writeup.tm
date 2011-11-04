<TeXmacs|1.0.7.10>

<style|generic>

<\body>
  <doc-data|<doc-title|Detecting Tidal X-Ray Flares in Galaxy
  Clusters>|<doc-author-data|<author-name|Aditya Goil, Karthic Hariharan,
  Shaunping Liu, Steve Rangle, & Matthew P. Wampler-Doty>>>

  The purpose of this project is to detect tidal X-Ray flares, thought to be
  caused by accreting super massive holes at the center of galaxies.

  <with|font-shape|italic|The goal of this research is to estimate the
  universal frequency of tidal X-Ray flares for a given non-active galactic
  nucleus.>

  This project entails the several activities. Each activity has one or more
  members that have committed themselves to that activity.

  <\enumerate-numeric>
    <item><with|font-series|bold|Data Acquisition>: Aditya Goil & Matthew P.
    Wampler-Doty

    There are three data sets that we draw from: the CHANDRA archive, the
    XMM-Newton archive, and the Hubble Space Telescope archive. Each archive
    provides image data taken from the respective satellite in the form of
    "Flexible Image Transport System" or FITS format.

    The principle line of investigation is to research CHANDRA and XMM
    observations. This is done as follows:

    <\enumerate-alpha>
      <item>All of the satellite observations are grouped together by ``great
      arch distance'' using complete-linkage hierarchical
      agglomeration<\footnote>
        <hlink|http://en.wikipedia.org/wiki/Complete_linkage_clustering|http://en.wikipedia.org/wiki/Complete_linkage_clustering>
      </footnote>. \ Groups of clusters <math|\<sim\>>3 arcminutes in extent
      are produced. \ Observations within <math|\<sim\>15> arcminutes of the
      galactic plane are discarded - this is known as the ``Zone of
      Avoidance''.

      <item>For each group of observations, we lookup galaxy clusters in the
      vicinity in the NED database<\footnote>
        <hlink|http://ned.ipac.caltech.edu/|http://ned.ipac.caltech.edu/>
      </footnote>

      <item>For each observation, sources are detected. \ Sources are then
      grouped together by extent once again using complete linkage
      clustering.

      <item>For each detected group of sources, we fit a Plank blackbody
      model<\footnote>
        <hlink|http://en.wikipedia.org/wiki/Planck%27s_law|http://en.wikipedia.org/wiki/Planck%27s_law>http://en.wikipedia.org/wiki/Active_galactic_nucleus
      </footnote> to compute the flux. \ X-Ray flares are observed to exhibit
      exponentially decaying flux, so this is the signature that we search
      for through the data.

      <item>We also acquire Hubble Space Telescope data, when available, to
      see if there is a optical counterpart to sources we detect.
    </enumerate-alpha>

    A difficulty with Hubble data demands <with|font-shape|italic|image
    stitching>, which presents itself as a second action item

    <item><with|font-series|bold|Image Stitching Hubble Data using Spherical
    Regression> - Karthic Hariharan, \ Shaunping Liu & Matthew P.
    Wampler-Doty

    Systematic error in Hubble Space Telescope telemetry requires correction
    in practice. \ To accomplish this, we use a technique known in the
    aerospace industry as ``spherical regression,'' which is a form of image
    stitching.

    Briefly, the algorithm implemented is a form of
    <with|font-shape|italic|Newton-Ralphson Relaxation> where each step the
    problem is linearized, a linear regression is computed and then used as a
    refinement to compute a final, true spherical regression. \ Prior to
    regression it is also necessary to solve a correspondence problem for
    images.

    <item><strong|Image Segmentation & Model Fitting> - Aditya Goil, Steve
    Rangle & Matthew P. Wampler-Doty

    In order to estimate the universal frequency of tidal X-Ray flares, it is
    necessary to estimate <with|font-shape|italic|how many galaxies> we are
    observing in the course of this research. \ This demands we solve an
    image processing problem.

    Namely, we are interested in <with|font-shape|italic|segmentation> of
    Chandra/XMM/HST images to find candidates for galaxy clusters. \ Once we
    have segmented the images, we fit a <with|font-shape|italic|King's
    Spread> or <with|font-shape|italic|<math|\<beta\>>-model> to the detected
    regions. These are profiles of the observed luminosity in galaxy
    clusters; from these distributions we can then infer the total number of
    galaxies within the cluster.
  </enumerate-numeric>

  To recap: we are interested in detecting X-Ray flares from non-active
  galactic nuclei. \ We are interested in doing optical follow up research
  with the Hubble Space Telescope. \ Finally, we are interested in estimating
  the total number of galaxies observed in the course of the research.\ 
</body>

<\references>
  <\collection>
    <associate|footnote-1|<tuple|1|1>>
    <associate|footnote-2|<tuple|2|1>>
    <associate|footnote-3|<tuple|3|1>>
    <associate|footnr-1|<tuple|1|1>>
    <associate|footnr-2|<tuple|2|1>>
    <associate|footnr-3|<tuple|3|1>>
  </collection>
</references>