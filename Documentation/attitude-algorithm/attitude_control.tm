<TeXmacs|1.0.7.2>

<style|generic>

<\body>
  <section|Obtaining an Estimate of the Spherical Regression<label|estimate>>

  To begin, we review the method of spherical regression proposed in (FIXME:
  cite rivest1), which was independently invented and implemented in the
  <with|font-shape|italic|High Energy Transient Explorer 2> (HETE2) flight
  computer.

  Let <math|<with|math-font|cal|S>\<assign\>{\<langle\><with|mode|text|<math|<wide|v|\<vect\>>>><rsub|0>,<wide|u|\<vect\>><rsub|0>\<rangle\>,\<langle\><with|mode|text|<math|<wide|v|\<vect\>>>><rsub|1>,<wide|u|\<vect\>><rsub|1>\<rangle\>,\<ldots\>}>
  be a finite set of pairs of corresponding vectors on a unit sphere.

  We motivate our analysis by first looking at just
  <math|<wide|v|\<vect\>><rsub|0>> and <math|<wide|u|\<vect\>><rsub|0>>, and
  a rotation <math|R> transforming one into another. \ This is given by the
  following relationship the following relationship:

  <\equation*>
    R \<cdot\><wide|v|\<vect\>><rsub|0>=<wide|u|\<vect\>><rsub|0>
  </equation*>

  Now suppose that <math|R> is the result of a constant rotation with
  <em|pseudo-vector> <math|<wide|\<omega\>|\<vect\>>>.

  Define:

  <\equation*>
    <with|math-font-series|bold|T>(\<langle\>x,y,z\<rangle\>)\<assign\><matrix|<tformat|<table|<row|<cell|0>|<cell|-z>|<cell|y>>|<row|<cell|z>|<cell|0>|<cell|-x>>|<row|<cell|-y>|<cell|x>|<cell|0>>>>>
  </equation*>

  Then we have

  <\equation>
    R =EXP(<with|math-font-series|bold|T>(<wide|\<omega\>|\<vect\>>))<label|exp-tensor>
  </equation>

  Where <math|EXP(X)> is matrix exponentiation operation, defined as an
  infinite series. Equation (<reference|exp-tensor>) shows that in principle
  it is sufficient to compute <math|<wide|\<omega\>|\<vect\>>> in order to
  establish <math|R>, provided that we can calculate its matrix exponential.

  We next note that the instantaneous change
  <math|<wide|<wide|v|\<vect\>>|\<dot\>>> is given by

  <\eqnarray>
    <tformat|<table|<row|<cell|<wide|<wide|v|\<vect\>>|\<dot\>><rsub|0>>|<cell|=>|<cell|<wide|\<omega\>|\<vect\>>
    \<times\><wide|v|\<vect\>><rsub|0>>>|<row|<cell|>|<cell|=>|<cell|-<with|math-font-series|bold|T>(<wide|v|\<vect\>><rsub|0>)\<cdot\><wide|\<omega\>|\<vect\>>>>>>
  </eqnarray>

  Where <with|mode|math|<wide|\<omega\>|\<vect\>>> is the angular velocity,
  taken as a vector. \ The first order approximation
  <with|mode|math|<wide|<wide|v|\<vect\>>|\<dot\>><rsub|0>\<approx\><wide|v|\<vect\>><rsub|0>-<wide|u|\<vect\>><rsub|0>>,
  gives

  <\equation*>
    -<with|math-font-series|bold|T>(<wide|v|\<vect\>><rsub|0>)\<cdot\><wide|\<omega\>|\<vect\>>
    \<approx\> <wide|v|\<vect\>><rsub|0>-<wide|u|\<vect\>><rsub|0>
  </equation*>

  We may now solve for <math|<wide|\<omega\>|\<vect\>>>, although it is
  under-determined. \ In order to overcome under-determination, we extend our
  analysis to the over-determined problem to finding a
  <math|<wide|\<omega\>|\<vect\>>> that transforms all of the pairs of points
  <math|\<langle\><wide|v|\<vect\>><rsub|i>,<wide|u|\<vect\>><rsub|i>\<rangle\>>
  in our finite set <math|<with|math-font|cal|S>>. \ The resulting system of
  equation may be easily represented in matrix form as follows:

  <\equation*>
    <below|<wide*|<matrix|<tformat|<table|<row|<cell|-<with|math-font-series|bold|T>(<wide|v|\<vect\>><rsub|0>)>>|<row|<cell|-<with|math-font-series|bold|T>(<wide|v|\<vect\>><rsub|1>)>>|<row|<cell|\<vdots\>>>|<row|<cell|-<with|math-font-series|bold|T>(<wide|v|\<vect\>><rsub|n>)>>>>>|\<wide-underbrace\>>|M<rsub|<with|math-font|cal|S>>>\<cdot\><wide|\<omega\>|\<vect\>>\<approx\><below|<wide*|<matrix|<tformat|<table|<row|<cell|(<wide|u|\<vect\>><rsub|0>-<wide|v|\<vect\>><rsub|0>)<rsup|\<top\>>>>|<row|<cell|(<wide|u|\<vect\>><rsub|1>-<wide|v|\<vect\>><rsub|1>)<rsup|\<top\>>>>|<row|<cell|\<vdots\>>>|<row|<cell|(<wide|u|\<vect\>><rsub|n>-<wide|v|\<vect\>><rsub|n>)<rsup|\<top\>>>>>>>|\<wide-underbrace\>>|b<rsub|<with|math-font|cal|S>>>
  </equation*>

  Here <math|M> is the leading matrix, composed of stacks of tensors and
  <math|b> is the resulting vector, composed of many vector differences
  placed end to end. \ The <em|least-squares fit> \ <math|<wide|\<omega\>|^>>
  is the solution to to the equation:

  <\equation>
    M<rsup|\<top\>>M\<cdot\><with|mode|text|<math|<wide|\<omega\>|^>>><rsub|<with|math-font|cal|S>>=M<rsup|\<top\>>\<cdot\>b<label|regression>
  </equation>

  Theoretically, we could now obtain <math|<wide|R|^>\<assign\>EXP(<with|math-font-series|bold|T>(<wide|\<omega\>|^><rsub|<with|math-font|cal|S>>))>,
  a first-order approximation of the spherical regression for
  <math|<with|math-font|cal|S>>. While matrix exponentiation neither has a
  general closed form, nor known general numerical approximations (FIXME -
  cite: 19 dubious ways to compute a matrix exponential), for the special
  case of <math|3\<times\>3> skew semetric matrices have a closed form
  expressible using a large number of transcendental functions (FIXME: cite
  Brockett, R. W. ``Robotic Manipulators and the Product of Exponentials
  Formula.''). \ To overcome this, one may use the first order approximation
  <math|EXP(<with|math-font-series|bold|T>(<wide|\<omega\>|\<vect\>><rsub|<with|math-font|cal|S>>))\<approx\>I+<with|math-font-series|bold|T>(<wide|\<omega\>|\<vect\>><rsub|<with|math-font|cal|S>>)>,
  where <math|I> is the <math|3\<times\>3> identity matrix. \ While computing
  <math|I+<with|math-font-series|bold|T>(<wide|\<omega\>|\<vect\>><rsub|<with|math-font|cal|S>>)>
  is trivial, it does not yield a proper rotation matrix; it is necessary to
  run the <em|Graham-Schmidt> algorithm over the result to produce an
  ortho-normal matrix; let <math|<overline|M>> represent the result of
  running Graham-Schmidt over a Matrix <math|M>.

  These observations give rise to an iterative algorithm for computing
  spherical regression, akin to the textbook Newton-Raphson method. \ Each
  iteration finds an refined <math|R> that is closer to the ideal spherical
  regeression. \ Let <math|R \<uparrow\><with|math-font|cal|X>\<assign\>{\<langle\>R\<cdot\><wide|v|\<vect\>>,<wide|u|\<vect\>>\<rangle\><space|1spc>\|<space|1spc>\<langle\><wide|v|\<vect\>>,<wide|u|\<vect\>>\<rangle\>\<in\><with|math-font|cal|X>}>,
  denote the update of <math|<with|math-font|cal|X>> by rotation. \ Then our
  <math|R> expresses the recurrence:

  <\eqnarray*>
    <tformat|<table|<row|<cell|R<rsub|0>>|<cell|\<assign\>>|<cell|I<eq-number><label|recur1>>>|<row|<cell|R<rsub|n+1>>|<cell|\<assign\>>|<cell|<overline|(I+<with|math-font-series|bold|T>(<wide|\<omega\>|^><rsub|R<rsub|n>\<uparrow\><with|math-font|cal|S>>))\<cdot\>R<rsub|n>><eq-number><label|recur2>>>>>
  </eqnarray*>

  One may stop by setting some threshold <math|\<varepsilon\>> and testing
  for <math|\|R<rsub|n>-R<rsub|n-1>\|\<less\>\<varepsilon\>>.

  This algorithm in of itself is simple, although it suffers from two
  difficiencies. \ The first is that rotation matrices may not always be
  desirable. The second is that in certain cases the algorithm may converge
  very slowly, such in the case that <math|<with|math-font|cal|S>> represents
  a <math|\<approx\>180<rsup|\<circ\>>> rotation.

  We address the first of these problems is Ÿ<reference|quaternionsec>, which
  recasts the algorithm presented above using quaternions (generally regardes
  as a more numerically stable representation of rotation). \ We then
  illustrate a refined algorithm for computing an <em|initial guess>, which
  in practice overcomes the issue of slow convergence.

  <section|Quaternions<label|quaternionsec>>

  Hamilton (FIXME: cite Hamilton) was the first to observe that for every
  rotation <math|R>, there is a unique quaternion <math|q> such that:

  <\equation*>
    R\<cdot\><wide|v|\<vect\>>=q\<ast\><wide|v|\<vect\>>\<ast\>q<rsup|-1>
  </equation*>

  for all 3-vectors <math|<wide|v|\<vect\>>>. \ Here <math|\<ast\>> is taken
  to be quaternion multiplication, and a 3-vector
  <math|<wide|v|\<vect\>>=\<langle\>x,y,z\<rangle\>> is represented by the
  quaternion <math|<with|math-font-series|bold|i>x+<with|math-font-series|bold|j>y+<with|math-font-series|bold|k>z>.
  \ The notion of a <with|font-shape|italic|pseudo-vector>
  <math|<wide|\<omega\>|\<vect\>>> is shared by both representations, and
  obeys the following relationship:

  <\equation*>
    EXP(<with|math-font-series|bold|T>(<wide|\<omega\>|\<vect\>>))\<cdot\><wide|v|\<vect\>>=e<rsup|<wide|\<omega\>|\<vect\>>/2>\<ast\><wide|v|\<vect\>>\<ast\>e<rsup|-<wide|\<omega\>|\<vect\>>/2>
  </equation*>

  Here <math|e<rsup|q>> is quaternion exponentiation, given by:\ 

  <\equation*>
    e<rsup|q>=e<rsup|\<Re\>(q)> <left|(>cos
    \<\|\|\>\<Im\>(q)\<\|\|\>+<frac|\<Im\>(q)|\<\|\|\>\<Im\>(q)\<\|\|\>> sin
    \<\|\|\>\<Im\>(q)\<\|\|\><right|)>
  </equation*>

  where <math|\<Re\>(q)> is the real component of <math|q> and
  <with|mode|math|\<Im\>(q)> is the imaginary component. \ We note that in
  the special case of <math|q=a+<with|math-font-series|bold|i>b>, this is
  exactly Euler's equation.

  As in the case of matrix exponentiation, we have the first order
  approximation that:

  <\equation*>
    e<rsup|<wide|\<omega\>|\<vect\>>/2>\<approx\>1+<wide|\<omega\>|\<vect\>>/2
  </equation*>

  Let <math|q\<Uparrow\><with|math-font|cal|S>\<assign\>{\<langle\>q\<ast\><wide|v|\<vect\>>\<ast\>q<rsup|-1>,<wide|u|\<vect\>>\<rangle\><space|1spc>\|<space|1spc>\<langle\><wide|v|\<vect\>>,<wide|u|\<vect\>>\<rangle\>\<in\><with|math-font|cal|S>}>.
  \ The following recurrence corresponds to (<reference|recur1>) and
  (<reference|recur2>):

  <\eqnarray*>
    <tformat|<table|<row|<cell|q<rsub|0>>|<cell|\<assign\>>|<cell|1<eq-number><label|quatregress>>>|<row|<cell|q<rsub|n+1>>|<cell|\<assign\>>|<cell|<frac|(1+<frac|<wide|\<omega\>|\<vect\>><rsub|q<rsub|n>\<Uparrow\><with|math-font|cal|S>>|2>)\<ast\>q<rsub|n>|<left|\|\|>(1+<frac|<wide|\<omega\>|\<vect\>><rsub|q<rsub|n>\<Uparrow\><with|math-font|cal|S>>|2>)\<ast\>q<rsub|n><right|\|\|>><eq-number>>>>>
  </eqnarray*>

  As before, one may set a threshold <math|\<varepsilon\>> and end iteration
  where <math|\<\|\|\>q<rsub|n>-q<rsub|n-1>\<\|\|\>\<less\>\<varepsilon\>>.

  <section|Iterative Refinement & Making an Initial Estimate>

  In each of the previous two sections, we used <em|unity> as the starting
  point for our iterative algorithm, as reflected in equations
  (<reference|recur1>) and (<reference|quatregress>). This may be slow
  converging when <math|<with|math-font|cal|S>> represents a
  <math|180<rsup|\<circ\>>> rotation. \ In this section we propose an initial
  guess to over-come this potential slow convergence.

  We begin by picking two pairs <math|\<langle\>v<rsub|0>,u<rsub|0>\<rangle\>>
  and <math|\<langle\>v<rsub|1>,u<rsub|1>\<rangle\>> from
  <math|<with|math-font|cal|S>> at random. \ Assume that <math|v<rsub|0>> and
  <math|v<rsub|1>> are distinct and not anti-podal, and similarly for
  <math|u<rsub|0>> and <math|u<rsub|1>>. \ First, we transform
  <math|v<rsub|1>> and <math|u<rsub|1>> into normal vectors that are
  orthogonal to <math|v<rsub|0>> and <math|u<rsub|0>>, respectively:

  <\eqnarray*>
    <tformat|<table|<row|<cell|v<rsub|1><rsup|\<bot\>>>|<cell|\<assign\>>|<cell|<frac|v<rsub|1>-(v<rsub|0>\<cdot\>v<rsub|1>)
    v<rsub|0>|\<\|\|\>v<rsub|1>-(v<rsub|0>\<cdot\>v<rsub|1>)
    v<rsub|0>\<\|\|\>>>>|<row|<cell|u<rsub|1><rsup|\<bot\>>>|<cell|\<assign\>>|<cell|<frac|u<rsub|1>-(u<rsub|1>\<cdot\>u<rsub|0>)
    u<rsub|0>|\<\|\|\>u<rsub|1>-(u<rsub|1>\<cdot\>u<rsub|0>)
    u<rsub|0>\<\|\|\>>>>>>
  </eqnarray*>

  \ We may now obtain two rotation matrices: the first rotates the plane
  formed between <math|v<rsub|0>> and <math|v<rsub|1>> to the
  <with|font-shape|italic|xy>-plane, and the second rotates the plane between
  <math|u<rsub|0>> and <math|u<rsub|1>> similarly:

  <\eqnarray*>
    <tformat|<table|<row|<cell|R<rsub|v>>|<cell|\<assign\>>|<cell|<matrix|<tformat|<table|<row|<cell|v<rsub|0>>>|<row|<cell|v<rsub|1><rsup|\<bot\>>>>|<row|<cell|v<rsub|0>\<times\>v<rsub|1><rsup|\<bot\>>>>>>>>>|<row|<cell|R<rsub|u>>|<cell|\<assign\>>|<cell|<matrix|<tformat|<table|<row|<cell|u<rsub|0>>>|<row|<cell|u<rsub|1><rsup|\<bot\>>>>|<row|<cell|u<rsub|0>\<times\>u<rsub|1><rsup|\<bot\>>>>>>>>>>>
  </eqnarray*>

  Note that the transpose of a rotation matrix is its inverse. \ This yields
  <math|R<rsup|\<top\>><rsub|u>\<cdot\>R<rsub|v>> as an initial estimate at a
  transformation of the reference points <math|v> to the observed points
  <math|u>. \ The standard means of transforming a rotation matrix into a
  quaternion yields a suitable initial estimate for use in our iterative
  refinement algorithm<\footnote>
    Note that while transforming a rotation matrix into a quaternion
    generally introduces <em|error>, we are not concerned with this in this
    context since we do not care about the precision of the initial guess.
  </footnote>.
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
    <associate|auto-1|<tuple|1|1>>
    <associate|auto-2|<tuple|2|2>>
    <associate|auto-3|<tuple|3|3>>
    <associate|estimate|<tuple|1|1>>
    <associate|exp-tensor|<tuple|1|1>>
    <associate|footnote-1|<tuple|1|3>>
    <associate|footnr-1|<tuple|1|3>>
    <associate|quaternionsec|<tuple|2|2>>
    <associate|quatregress|<tuple|5|3>>
    <associate|recur1|<tuple|3|2>>
    <associate|recur2|<tuple|4|2>>
    <associate|regression|<tuple|2|1>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|Obtaining
      an Estimate of the Spherical Regression<label|estimate>>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|Quaternions<label|quaternionsec>>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|Iterative
      Refinement & Making an Initial Estimate>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>