q---
title: "Revision del paper de simulacion "
author: "Marco A. Aquino-López"
date: ""
---

JABE-D-21-00167
Evaluation of 210Pb dating models using simulated datasets
Journal of Agricultural, Biological, and Environmental Statistics

Dear Marco Antonio Aquino-López; Nicole K Sanderson; Maarten Blaauw; Joan-Albert Sanchez-Cabeza; Ana Carolina Ruiz-Fernandez; J Andrés Christen,

We thank you for your submission to Journal of Agricultural, Biological, and Environmental Statistics.

First, I am sorry for the prolonged review.  The AE had an unusually difficult time finding reviewers.  Please accept our apologies.   

An Associate Editor and a reviewer have now reported on your manuscript.  While they see merit in your work, we regret that we cannot publish your paper in JABES in its current form.

The Associate Editor and I consider that your work is potentially suitable for JABES, however the reviewers had a difficult time reading the paper because key details were missing or unclear.  Given this uncertainty we cannot guarantee that the paper will ultimately be accepted. However, if you feel that you can respond convincingly to the review comments, you may wish to consider submitting a revised version at your own risk.  In this case, the paper will be treated as a new submission, although you should reference JABE-D-21-00167 in your covering letter.

If you opt to submit a revised version, please check the guidelines for authors on our website.  Ensure that your revised version does not exceed 25 pages and follows the JABES writing and submission style.

Kind regards,
Brian Reich
Editor-in-Chief
Journal of Agricultural, Biological, and Environmental Statistics

Overall 210 Pb dating seems like an interesting and important area of work that has had little statistical development. Unfortunately the current manuscript is lacking in technical details and therefore is difficult to evaluate. 

Section 2 (210 Pb Models) needs to be developed much more thoroughly. The technical terms "supported 210 Pb", "excess 210 Pb", and "supported-excess 210 Pb" need to be defined relative to "measured 210 Pb". These terms need to be used consistently throughout the article. Additional terminology needs to be defined, e.g. flux, inventory, etc. Additional notation needs to be defined, e.g. \bar{t}, \sigma_i, \rho_i, etc. Knowns or measured variables need to be clearly identified from unknowns, i.e. are the following known: P_i^S, \Phi_i, \sigma_i, \rho_i? Models need to be fully mathematically described, e.g. "t(x) is estimated using a piece-wise linear model constrained by prior information...". Priors need to be fully described. Currently there is nothing on priors. 

The claim that Plum is a Bayesian alternative to CRS is misleading since, apparently, CRS isn't even a probabilistic model. Presumably CRS could be modified to define a probabilistic model and then be estimated using maximum likelihood or a Bayesian approach. Similarly the Plum model, could be estimated using a maximum likelihood approach. Thus it isn't clear that gains are made due to the differences in modeling or the method of estimation or both. 


Specific comments:
- Figure 1 is an unnecessary waste of space as it reports 14 total values: counts and relative frequencies in 7 categories. 
- In equation (1), are we talking about excess 210 Pb or measured 210 Pb? 
- ln equation (1) "ln" is not italized while it is italized in (3). 
- In equation (2), do we know dry mass (m_i)? I'm assuming we do, but it is not shown in Table 1.
- What base is log in equation (5)? 



Reviewer #1: This is an important model, codebase, and simulation study that needs to be published. Unfortunately, I cannot fully evaluate the results because the technical description is deficient. It is poorly organized and contains a good number of undefined variables and incorrect uses of notation. I have attempted to provide constructive steps to fix these deficiencies, pointing out each specific mistake and sources of confusion.

The other major thing I suggest fixing has to do with the framing. It is, I think, misleading at best and wrong at worse to call Plum the Bayesian alternative to CRS. This should only be claimed if CRS is the maximum likelihood version of Plum. In fact, if my understanding is correct (but I am hampered in my ability to understand the models due to the deficient technical material), Plum is quite simply a different model than CRS. Given this, rather than "its Bayesian alternative (Plum)" a phrase such as "an alternative, Bayesian model (Plum)" should be used, and it should be made clear throughout that these are two distinct models.

Related to the preceding point, I am not sure that the chosen simulation modeling assumptions are best, though again I cannot be certain because of the deficiencies of the technical description. Consider, for example, the following sentence in the abstract: "Results indicate that the CRS model, used in a non-expert mode, does not capture the true age values, even with a high dating resolution of the sediment record, nor does its accuracy improve as more information is available." This would imply that the CRS model is indeed a bad model, but not because it is non-Bayesian. If one simulates data using the assumptions of the CRS model yet one cannot recover the model then the model is not statistically identifiable, for which there is no fundamental fix. It's just a bad model. If that's the case, one should replace the model with an alternative. Indeed, that's what the authors are doing, I think, but in that case their simulation exercise that adopts the CRS modeling assumptions is broken since we already know the model is broken.

___No previous studies ever used any kind of simulations, and since the CRS model is always reported a model which either was corrected by other dating method such as $^{137}$Cs or was not collaborated with any other dating. 

We are using the simulation using these assumptions to show this precise point to___ 



- p. 2, line 16: typo. "later" -> "layer"


p. 2, line 20: I read this as claiming that the total amount from deposition must be independently measurable to establish the chronology. I don't think that's right, and I don't thing the authors quite mean it. Rather, the deposition must be independently measurable or must be accommodated somehow in how the model does inference.

p. 4, line 26: type. "discussed" -> "discusses". Also, which considerations are discussed?

p. 6, line 20: This is a comma splice. Replace the comma after otherwise with a semicolon.

- p. 6, line 23: What is an "early user"? Perhaps "naive user" instead?

- p. 6, line 40: "regression over" -> "regression with"

- p. 7, line 9: typo: "is not longer" -> "is no longer"

_ p. 7, line 23: Because this article is about comparing the CRS model to the Plum model, I don't think it is sufficient to just refer to the external publication. Rather, I highly suggest describing the CRS model in complete detail in this paper, at the very least in a supplement. On this, I actually do not think the other models (CIC and CF: CS) in fact do need to be described, unless the exact same equations are used for the CRS model (if this is the case, the equations just need to be given, and their relation to the other models noted).

p. 7, line 49: "not-likelihood" I think this is just a typo, but there's some chance that is technical jargon I am not familiar with. I think the authors mean that the CRS model is not a likelihood based approach, so this should instead just be "non-likelihood"?
-------- 

p. 9, line 27: Is this in the github repo listed at the end of section 4.1? If so, mention it here. As I also note below, I can find no directions on the github repo for how to run the code to reproduce the article's results. That is clearly something that should be added to the repo, ideally in the README.

p. 9, line 42. Similar to above, these equations are so central to the results they should be presented and unpacked in full detail in this article.

___DONE___ p. 10, line 4: As promised, I would like to provide construct suggestions for how specifically to improve the document's technical material. This parenthetical reference to Table 4.1 comes too early to be useful. First, explain in detail the three things that distinguish the scenarios, defining terms and concepts precisely. Once that is done, refer the reader to Table 4.1. Unless I am mistaken, the symbol \Phi is nowhere defined.

___DONE___ p. 10, line 19: "Although these concentrations may be interpreted as error-free measurements (see Figure 3)" Why? I don't understand why or what this means.

___Add some details from maarten paper___p. 10, line 20: "following a similar methodology to Blaauw et al. (2018)" As before, these details are sufficiently important that the exact equations should be given in the manuscript with sufficient description and contextualization the reader can understand them. Of course, it is still crucial to cite the original work.

DONE p. 10, line 38: This \hat{x} notation is bad. In particular, \hat{x} as a symbol by itself is ambiguous. Which sediment does it refer to? It might be fixed by always writing it as a function of x and \delta. At best, this is abuse of notation that should be acknowledged. Perhaps it would be best to instead index layers, e.g., C_j. As already noted, \Phi is nowhere defined. Also, this is the first and only use of A^S and it is also nowhere defined.

Done p. 10, line 41. What is \theta a true value of? As it stands, \theta is undefined. Is there a typo here? Should x_{scat}^2 instead be y_{scat}^2? What does scatter mean here?

Done p. 10, line 44: While I understand what the authors intend with respect to the shift, the notation is poor and there are undefined symbols. I deduce that \script{U} represents a uniform density on the interval -x_{shift} to x_{shift}. x_{shift} (lower case) is undefined, though I do understand its role. The equation beginning X_{shift} ~ ... mixes functional and "is distributed as" notation. That is, f_N(\cdot) -- the probability density for a normal distribution -- is not the same thing as \script{N} -- a symbol used to indicate how a particular variable is distributed. At least, I think there is a mix of conventions here for specifying a density function since I am guessing at the meaning of undefined symbols.

Done p. 10, Equation 7: \theta' is undefined. Arguably, so is y. If there are measurements from multiple labs your are probably better of using indexing notation to distinguish them. In the sentence above the equation add be and remove the colon "can defined as:" -> "can be defined as" (or maybe "is defined as").

DONE p. 10, line 55: Comma splice: "laboratories,we" -> "laboratories; we". The unit (or variable?) Bq is not defined. What is \epsilon an uncertainty of?

p. 10, line 56: Is y_{scat} being used for two different things? The authors offer two contradicting values for it. Above, y_{scat}^2 = 10, whereas here y_{scat} = 1.5.

DONE p. 12, line 50: typo: "do improves with more information is available" -> "do improve if more information is available"

DONE p. 15, line 52: Per comments above, "the Bayesian alternative" -> "a Bayesian alternative"

DONE p. 17, line 35: typo: "more, of" -> "more of"

DONE p. 17, line 41: Something has gone wrong in this sentence. Perhaps "better at estimating *for a* certain time period"?

DONE p. 17, line 57: Typo: "recognized" -> "recognize"

DONE p. 18, line 6: "process about" -> "process of"

DONE p. 18, line 23: Need an "and" after the comma: "data are added, the.." -> "data are added, and the..." Also, here data is assumed plural, but is assumed singular elsewhere. Either convention is fine, I think, but I suggest choosing one convention and sticking to it.

p. 21, line 7: Many thanks for providing the code in a freely available github repository. Most authors do not do so. I have a number of suggestions to improve the repo. First and foremost, there are no directions that I can find describing the repo structure or providing steps to install requirements and run the analyses. On a somewhat different note, are you certain that you want to provide your letter to the editor in a public repository that will ultimately be linked to the article? And similarly for the revision history of the manuscript? I actually think these are fine things to do. If you do keep them in the repo, I suggest providing an overview of the directories and files in the repo. Big picture, I have not taken a careful look at the code, but I am amenable to doing so if I remain a reviewer on this article. To do so, though, I would want a clear guide to the repo and the code it contains as a starting point.

__






