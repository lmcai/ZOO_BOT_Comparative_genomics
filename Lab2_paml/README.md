# Detecting Positive Selection with CODEML (PAML)

## 1. Overview

We will work with PAML [website](https://github.com/abacus-gene/paml) for this lab. The lab focuses on inferring dN and dS rates from sequence alignments and their interpretation.

The walk-through below allows you to perform the analysis **locally on your laptop**. If you have a HiperGator account, you can submit a slurm job to run PAML/CODEML (**see tutorial at the bottom**). If you cannot run it on your computer or HiperGator, you can look at the outputs in the output folders.

## 2. Pre-class preparation: Install PAML, FigTree, and AliView on your computer

We have covered FigTree and AliView previously. For PAML installation, it can be downloaded and installed from precompiled versions here [website](https://github.com/abacus-gene/paml#installation) or if you have conda installed:
```
conda install bioconda::paml
``` 

Make sure you can call `codeml` from your environment. Type the following command:
```
codeml
```
And you should see this:
```
codeml

error when opening file codeml.ctl
tell me the full path-name of the file? 
```

## 3. In-class exercise: Inferring dN, dS rates from sequence alignment with or without a reference tree

PAML is a package for maximum likelihood based evolutionary hypothesis testing. It contains many programs developed by Ziheng Yang's group including `CODEML` (for dN/dS rate), `evolver` for simulating phylogeny and sequences, and `MCMCtree` for divergence time estimation. We will be using `CODEML` to infer substitution rates under various scenarios.


https://academic.oup.com/mbe/article/40/4/msad041/7140562?searchresult=1&login=false

Recall the interpretation of $\omega$:

* $\omega > 1$ → positive (diversifying) selection — nonsynonymous changes are favored;
* $\omega = 1$ → neutral evolution;
* $\omega < 1$ → negative (purifying) selection — nonsynonymous changes are being removed.

Because most codons in most genes are under some functional constraint, an $\omega$ averaged across an entire gene and an entire tree is almost always < 1, even for genes that experience strong positive selection at a handful of sites or along a handful of branches. The models below exist because a single, gene-wide, tree-wide $\omega$ is usually too blunt an instrument to detect that kind of localized selection.

## 2. Example dataset

We will use the myxovirus resistance gene (`Mx`) alignment and tree from the [`positive-selection`](https://github.com/abacus-gene/paml-tutorial/tree/main/positive-selection) tutorial in the `paml-tutorial` GitHub repository, which accompanies Álvarez-Carretero et al. (2023), *"Beginner's guide on the use of PAML to detect positive selection"* (*Mol Biol Evol* 40(4):msad041). The sequences come from ten mammal species plus two birds (duck and chicken) used as an outgroup, originally analysed by Huo et al. (2007).

You will be provided with:

```
Mx_aln.phy       # the codon alignment, PHYLIP format
Mx_unroot.tree   # unrooted gene tree, Newick format
Mx_root.tree     # rooted gene tree, Newick format
```

You do not need to build these yourself — focus on understanding what's inside them.

## 3. The alignment file: PHYLIP format

Open `Mx_aln.phy` in a text editor. The first line is a header:

```
12   1989
```

This tells `CODEML` there are **12 sequences**, each **1989 nucleotides long**. Each subsequent line is a sequence name followed by its aligned sequence:

```
Rhesus_macaque_Mx      ATTGTAAAAGCTGATCCAGCT...
Orangutan_Mx           ATCGCAAAAGCTGATCCAGCT...
...
```

A few things to check before you trust an alignment for codon-model analysis:

- **The alignment length must be a multiple of 3.** `CODEML` reads it as codons (triplets), not individual nucleotides, so the alignment has to preserve the reading frame — it should have been built from a codon-aware aligner (e.g. aligning translated protein sequences, then mapping back to nucleotides), not a naive nucleotide aligner.
- **Gaps (`-`) mark indels**, and stop codons should not appear in the middle of a sequence — both would break the codon model.
- All sequences are padded to the same length (`1989` here) with gaps, even though the un-aligned gene lengths differ (compare `Chicken_Mx` and `Human_Mx` — the bird sequences use a different part of the alignment window).

Set `seqtype = 1` in the control file to tell `CODEML` this is a codon alignment (as opposed to `2` for amino acids or `0` for nucleotides analysed without regard to codon structure).

## 4. The phylogeny: Newick format and branch labels

Look at `Mx_unroot.tree`:

```
12  1
((((((Chimpanzee_Mx,Human_Mx),Orangutan_Mx),Rhesus_macaque_Mx),(((Sheep_Mx,Cow_Mx),Pig_Mx),Dog_Mx)),(Mouse_Mx,Rat_Mx)),Duck_Mx,Chicken_Mx);
```

The header `12  1` means 12 taxa, 1 tree in the file. The tree itself is standard Newick notation — nested parentheses represent nodes, and taxon names must match the sequence names in the alignment **exactly**.

### Rooted vs. unrooted

Compare this to `Mx_root.tree`, where duck and chicken are grouped together as a single clade rather than left as a trifurcation at the base:

```
(...,(Duck_Mx,Chicken_Mx));
```

For most analyses we deliberately use the **unrooted** tree. The reason is identifiability: the two branch lengths leading away from the root of a rooted tree cannot be estimated separately from each other — only their sum is identifiable — so rooting the tree adds a parameter that the data cannot actually inform. Using an unrooted tree removes that redundant parameter. The one situation where you *need* the rooted tree is when your hypothesis is specifically about the branch leading to a clade that would otherwise be split across the root's two arms (see the "bird clade" example below).

### Labelling branches for hypothesis testing

Branch and branch-site models require you to tell `CODEML` which branches you hypothesize experienced a different selective regime — the **foreground** branch(es) — versus the rest of the tree, the **background**. This is done by adding a `#1` tag directly after the taxon or clade in the tree file. For example, to test whether the chicken lineage alone has a distinct $\omega$:

```
(...,Duck_Mx,Chicken_Mx #1);
```

To test the duck and chicken lineages simultaneously:

```
(...,Duck_Mx #1,Chicken_Mx #1);
```

To test the entire bird clade — the branch leading to the duck+chicken ancestor *as well as* the two terminal branches — you tag the ancestral node too, which requires the rooted tree so that clade's stem branch actually exists as a single edge:

```
(...,(Duck_Mx #1,Chicken_Mx #1) #1);
```

Each `#1` you add corresponds to one additional $\omega$ class that `CODEML` will estimate for that group of branches, on top of the background $\omega$ for everything else.

## 5. What the four model classes assume

All of these are fit with the same program, `CODEML`, but they distribute the assumption of where $\omega$ can vary very differently. Two control-file variables do the real work: `model` (variation across **branches**) and `NSsites` (variation across **sites**).

| Model family | Varies across | `model` | `NSsites` | Question it answers |
|---|---|---|---|---|
| Homogeneous (M0) | nothing — one $\omega$ for the whole tree and gene | `0` | `0` | Is the gene, on average, under selection? |
| Site models | codon sites | `0` | `0 1 2 7 8` | Do a subset of *sites* show $\omega > 1$, regardless of lineage? |
| Branch models | branches (lineages) | `2` | `0` | Do specific *lineages* show a different $\omega$ than the rest of the tree? |
| Branch-site models | sites *within* specific branches | `2` | `2` | Do specific *sites*, but only along specific *foreground lineages*, show $\omega > 1$? |

### Homogeneous model (M0)

The simplest model: every site in the alignment and every branch in the tree shares the same $\omega$. It's rarely biologically realistic (it's implausible that literally every codon and every lineage is under identical selective pressure), but it is essential as a baseline: every other model is tested for whether it explains the data significantly better than this one.

### Site models

Site models let $\omega$ vary among codons by drawing it from a statistical distribution across site classes, but they still assume every branch in the tree shares that same distribution (no lineage-specific effects). Running `NSsites = 0 1 2 7 8` fits five models in a single `CODEML` call:

- **M0** — one $\omega$ for all sites (the homogeneous model, included here as the universal null).
- **M1a (NearlyNeutral)** — two site classes: a proportion of sites with $0 < \omega_0 < 1$, and the remainder fixed at $\omega = 1$. No site class is allowed to exceed 1, so this model *cannot* detect positive selection by construction.
- **M2a (PositiveSelection)** — adds a third site class to M1a where $\omega_2$ is estimated freely and can exceed 1. Comparing M1a vs. M2a is the classic test for whether any sites are under positive selection.
- **M7 (beta)** — $\omega$ across sites follows a beta distribution bounded between 0 and 1 (approximated with 10 discrete site classes), so again no site can have $\omega > 1$.
- **M8 (beta&$\omega$)** — M7 plus one additional free site class that can have $\omega > 1$. Comparing M7 vs. M8 is a second, independent test for positive selection at specific sites, useful when the M1a/M2a comparison gives an ambiguous result.

### Branch models

Branch models fix a single $\omega$ per site class but let that value differ among groups of branches, defined by the `#1` tags you place in the tree file (Section 4). `model = 2` tells `CODEML` to look for those tags and estimate a separate $\omega$ for each labelled group, versus one shared $\omega$ for all unlabelled ("background") branches. This tests whether a *specific lineage* — for example, a branch following a dietary shift, a gene duplication, or a host jump — has an elevated $\omega$ relative to the rest of the tree, but it still assumes that whole lineage's average $\omega$ is representative (it can't isolate individual sites within that branch).

### Branch-site models

Branch-site model A is the most flexible of the four: it allows $\omega$ to vary across sites *and* restricts the possibility of $\omega>1$ to specific, user-labelled foreground branches. Concretely, it has four site classes:

- class 0: $\omega_0 < 1$ on both background and foreground branches (purifying, everywhere);
- class 1: $\omega = 1$ on both background and foreground branches (neutral, everywhere);
- class 2a: $\omega_0$ on background branches, but a freely estimated $\omega_2$ (possibly $>1$) on foreground branches;
- class 2b: $\omega = 1$ on background branches, but that same free $\omega_2$ on foreground branches.

In other words, it asks: *are there codons that were under purifying or neutral selection across most of the tree, but shifted to positive selection specifically along the branch(es) I've tagged?* This is the model used to test things like "did this gene experience an episode of adaptive evolution specifically in the bird lineage." It's set with `model = 2` and `NSsites = 2`.

Because branch-site model A is not nested against M0 or M1a/M2a in a simple way, it has its own purpose-built null model: the same model with $\omega$ for classes 2a/2b **fixed at 1** instead of estimated (`fix_omega = 1`, `omega = 1`). This null still allows the background/foreground split to exist, it just forbids the foreground $\omega$ from exceeding 1 — so the alternative and null differ by exactly one parameter, which is what a likelihood ratio test requires (Section 7).

## 6. Building the control file

`CODEML` reads all of its options from a single control file (conventionally named `codeml.ctl` or similar), rather than from command-line flags. A template looks like this:

```
      seqfile = ALN            * Path to the alignment file
     treefile = TREE           * Path to the tree file
      outfile = OUT            * Path to the output file

        noisy = 3              * How much rubbish on the screen
      verbose = 1              * More or less detailed report

      seqtype = 1              * Data type
        ndata = NDAT           * Number of data sets or loci
        icode = 0              * Genetic code
    cleandata = 0              * Remove sites with ambiguity data?

        model = CODMOD         * Models for ω varying across lineages
      NSsites = NSSIT          * Models for ω varying across sites
    CodonFreq = CODFREQ        * Codon frequencies
      estFreq = ESTFREQ        * Use observed freqs or estimate freqs by ML
        clock = CLOCK          * Clock model
    fix_omega = FIXOME         * Estimate or fix omega
        omega = INITOME        * Initial or fixed omega
```

Key parameters to understand (not just fill in):

- **`seqtype = 1`** — codon-based analysis; required for all dN/dS work.
- **`model`** — controls variation across *branches*: `0` = one $\omega$ for the whole tree, `1` = a free ratio on every single branch (very parameter-rich, rarely used), `2` = several ratios defined by the `#1` tags in your tree file.
- **`NSsites`** — controls variation across *sites*; you can list several values (e.g. `0 1 2 7 8`) to fit multiple site models in one run.
- **`CodonFreq`** — how codon equilibrium frequencies are calculated. Common choices are `0` (equal, 1/61 each), `1` (F1x4, from average nucleotide frequencies), `2` (F3x4, from nucleotide frequencies at each codon position), or `3` (F61, one free frequency per codon). The tutorial's template instead uses `CodonFreq = 7`, which specifies the FMutSel mutation-selection model of Yang & Nielsen (2008); paired with `estFreq = 0`, frequencies are taken from the observed data rather than estimated by maximum likelihood.
- **`fix_omega` / `omega`** — whether $\omega$ is estimated (`fix_omega = 0`, with `omega` giving the starting value for the optimizer, e.g. `0.5`) or fixed at a specific value (`fix_omega = 1`, with `omega` giving that fixed value — this is exactly how you build a branch-site null model with $\omega$ pinned at 1).
- **`clock = 0`** — no molecular clock assumed; branch lengths are free to vary, which is standard for dN/dS estimation (as opposed to divergence-time estimation with `MCMCtree`).

### Settings for each model

| Setting | Homogeneous (M0) | Site models | Branch model | Branch-site model A | Branch-site null |
|---|---|---|---|---|---|
| `treefile` | unrooted | unrooted | unrooted (or rooted for a clade-stem hypothesis) | same as branch model | same as branch model |
| `model` | `0` | `0` | `2` | `2` | `2` |
| `NSsites` | `0` | `0 1 2 7 8` | `0` | `2` | `2` |
| `fix_omega` | `0` | `0` | `0` | `0` | `1` |
| `omega` | `0.5` (start) | `0.5` (start) | `0.5` (start) | `0.5` (start) | `1` (fixed) |

Everything else (`CodonFreq = 7`, `estFreq = 0`, `clock = 0`, `ndata = 1`) stays the same across all five.

## 7. Running CODEML

Once the control file is ready and sits in the same directory as (or points via relative path to) your alignment and tree files, run:

```
codeml your_control_file.ctl
```

`CODEML` writes its results to the file named in `outfile`. For multi-model runs (e.g. the five site models at once), the output file contains one block per model, each reporting the log-likelihood (`lnL`), the number of free parameters (`np`), and the maximum-likelihood estimates of $\omega$ and any other model parameters.

## 8. Likelihood ratio tests (LRT)

Every comparison in this lab follows the same logic: a **null model** (fewer free parameters, a special/restricted case) versus an **alternative model** (more free parameters, which contains the null as a special case — i.e. the models are *nested*). You cannot LRT-compare models that aren't nested in this way.

The test statistic is twice the difference in log-likelihoods:

$$2\Delta\ell = 2(\ell_{alt} - \ell_{null})$$

Under the null hypothesis, this statistic is asymptotically $\chi^2$-distributed with degrees of freedom equal to the difference in the number of free parameters between the two models. You then get a p-value from the $\chi^2$ distribution (e.g. in R: `pchisq(2*deltaL, df = k, lower.tail = FALSE)`), and reject the simpler (null) model in favor of the more complex one if that p-value is below your significance threshold (typically 0.05).

Standard nested comparisons in this protocol:

| Null | Alternative | df | Tests for |
|---|---|---|---|
| M0 | M1a | 1 | Does allowing two site classes fit better than one $\omega$ for everything? (usually rejected easily; mostly a sanity check) |
| M1a | M2a | 2 | Positive selection at specific sites (adds a free, possibly $>1$, site class) |
| M7 | M8 | 2 | Positive selection at specific sites (adds a free, possibly $>1$, site class on top of a beta distribution) |
| M0 | Branch model (foreground vs. background $\omega$) | 1 | Does the tagged lineage have a different average $\omega$ than the rest of the tree? |
| Branch-site null ($\omega_{fg}$ fixed = 1) | Branch-site model A ($\omega_{fg}$ free) | 1 | Positive selection at specific sites, restricted to the tagged foreground branch(es) |

Worked example from the M1a vs. M2a / M7 vs. M8 comparisons on this dataset (from the tutorial's `Find_bestmodel.R`):

```r
# M0 vs M1a
diff_M0vsM1a <- 2 * (lnL_M1a - lnL_M0)          # 559.26
pchisq(diff_M0vsM1a, df = 1, lower.tail = FALSE) # p = 1.2e-123 -> M1a strongly preferred

# M1a vs M2a
diff_M1avsM2a <- 2 * (lnL_M2a - lnL_M1a)         # 0
pchisq(diff_M1avsM2a, df = 2, lower.tail = FALSE) # p = 1 -> no evidence for positive selection here

# M7 vs M8
diff_M7vsM8 <- 2 * (lnL_M8 - lnL_M7)             # 12.54
pchisq(diff_M7vsM8, df = 2, lower.tail = FALSE)   # p = 0.0019 -> M8 significantly better; positive selection detected
```

Note the disagreement between the two positive-selection tests here: M1a vs. M2a finds nothing, while M7 vs. M8 does. This happens because M7/M8's beta-distributed null (M7) fits the bulk of nearly-neutral sites more flexibly than M1a's two-class null, making M8's extra site class easier to justify statistically. When the two tests disagree, it's common practice to treat the result as tentative evidence for positive selection rather than a clear-cut answer, and to look at which sites are implicated (via the Bayes Empirical Bayes site posterior probabilities `CODEML` reports alongside M2a and M8) before drawing conclusions.

For the branch and branch-site comparisons, apply the same `2Δℓ` and `pchisq(..., df = 1)` logic to the relevant pair of `lnL` values pulled from each model's output file.

######################################################
## 9. Running on HiperGator

If you have a HiperGator account, the same control files and commands above can be submitted as a SLURM job rather than run interactively — please do not run `codeml` directly on a login node.

1. Log on to HiperGator and move to your scratch directory:
   ```
   cd /blue/bot4935/<user>
   ```
2. Upload your control file(s), alignment, and tree file(s), along with a submission script (e.g. `codeml.sh`) that loads the PAML module and calls `codeml your_control_file.ctl`:
   ```
   #!/bin/sh
   #SBATCH --account=bot4935
   #SBATCH --qos=bot4935
   #SBATCH --job-name=CODEML
   #SBATCH --cpus-per-task=1
   #SBATCH --mem-per-cpu=4gb
   #SBATCH -t 12:00:00
   #SBATCH -o CODEML.%j.out
   #SBATCH --mail-type=END,FAIL
   #SBATCH --mail-user=<email>@ufl.edu

   pwd; hostname; date
   echo Working directory is $SLURM_SUBMIT_DIR
   cd $SLURM_SUBMIT_DIR

   module load paml

   codeml your_control_file.ctl
   ```
3. Submit and monitor the job:
   ```
   sbatch codeml.sh
   squeue -u <user>
   ```

Resources: [UFIT quick start](https://docs.rc.ufl.edu/quickstart/introduction/) · [HiPerGator User Training](https://go.ufl.edu/hpg-training) · [UFIT support](https://support.rc.ufl.edu/)

## References

- Álvarez-Carretero S, Kapli P, Yang Z. 2023. Beginner's guide on the use of PAML to detect positive selection. *Mol Biol Evol* 40(4):msad041.
- Yang Z. 2007. PAML 4: Phylogenetic analysis by maximum likelihood. *Mol Biol Evol* 24(8):1586–1591.
- Data and code adapted from the [`paml-tutorial`](https://github.com/abacus-gene/paml-tutorial) repository (`positive-selection` directory).
