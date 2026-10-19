# Organellar genome assembly using GetOrganelle

## I. Overview

We will work with GetOrganelle [website](https://github.com/kinggerm/getorganelle) for this lab. The lab focuses on the assembly and annotation of bacterium-like organellar genomes.

It is highly recommended that you work with **HiperGator** for this lab. It is possible to run the analysis **locally on your laptop** if your laptop has 16 GB RAM (memory).

## II. Pre-class preparation: Install GetOrganelle and Bandage

1. GetOrganelle

On HiperGator, it should be very convenient because it can be loaded with a single line of command:
```
module load getorganelle/1.7.5.0
```
If this is the first time you use this tool, you may need to download its database:
```
get_organelle_config.py --add embplant_pt,embplant_mt
```
This should create a hidden folder on your home directory:
```
ls -a ~
#you should see a .GetOrganelle folder. ls -a will list all files and directory including hidden ones
```

If you want to install GetOrganelle on your laptop, it is easiest to do so via conda:
```
conda install -c bioconda getorganelle
```
Then load the database as described above.

To test if you have successfully installed GetOrganelle, load the help message:
```
get_organelle_from_reads.py -h
```
You should see
```
usage: 
###  Embryophyta plant plastome, 2*(1G raw data, 150 bp) reads
get_organelle_from_reads.py -1 sample_1.fq -2 sample_2.fq -s cp_seed.fasta -o plastome_output  -R 15 -k 21,45,65,85,105 -F embplant_pt
###  Embryophyta plant mitogenome
get_organelle_from_reads.py -1 sample_1.fq -2 sample_2.fq -s mt_seed.fasta -o mitogenome_output  -R 30 -k 21,45,65,85,105 -F embplant_mt

GetOrganelle v1.7.5 get_organelle_from_reads.py assembles organelle genomes from genome skimming data. Find updates in
https://github.com/Kinggerm/GetOrganelle and see README.md for more information.

optional arguments:
  -1 FQ_FILE_1          Input file with forward paired-end reads (*.fq/.gz/.tar.gz).
  -2 FQ_FILE_2          Input file with reverse paired-end reads (*.fq/.gz/.tar.gz).
  -u UNPAIRED_FQ_FILES  Input file(s) with unpaired (single-end) reads.
  -o OUTPUT_BASE        Output directory.
  -s SEED_FILE          Input fasta format file as initial seed. Default:
                        /home/cail/.GetOrganelle/SeedDatabase/*.fasta
  -w WORD_SIZE          Word size (W) for extension. Default: auto-estimated
  -R MAX_ROUNDS         Maximum extension rounds (suggested: >=2). Default: 15 (embplant_pt)
  -F ORGANELLE_TYPE     Target organelle genome type(s): embplant_pt/other_pt/embplant_mt/embplant_nr/animal_mt/fungus
                        _mt/fungus_nr/anonym/embplant_pt,embplant_mt/other_pt,embplant_mt,fungus_mt
  --max-reads MAX_READS
                        Maximum number of reads to be used per file. Default: 1.5E7 (-F
                        embplant_pt/embplant_nr/fungus_mt/fungus_nr); 7.5E7 (-F embplant_mt/other_pt/anonym); 3E8 (-F
                        animal_mt)
  --fast FAST_STRATEGY  ="-R 10 -t 4 -J 5 -M 7 --max-n-words 3E7 --larger-auto-ws --disentangle-time-limit 360"
  -k SPADES_KMER        SPAdes kmer settings. Default: 21,55,85,115
  -t THREADS            Maximum threads to use. Default: 1
  -P PRE_GROUPED        Pre-grouping value. Default: 200000
  -v, --version         show program's version number and exit
  -h                    print brief introduction for frequently-used options.
  --help                print verbose introduction for all options.
```

2. Bandage

Bandage is a GUI program (this means it's interactive) that allows users to interact with the assembly graphs made by de novo assemblers (e.g., GetOrganelle, Velvet, Spades). It helps you understand how computers solve the De Bruijn graph. For some Mac users on IOS 27, it may complain about incompatibility. Debug as best as you can. Hopefully, the pre-compiled version will work for you: https://rrwick.github.io/Bandage/

If you can't get it to work, don't worry. You can follow the walkthrough in class.

3. GeSeq

Geseq (https://chlorobox.mpimp-golm.mpg.de/geseq.html) is a web-based plant organellar genome annotation tool. It does not require installation. Feel free to explore its functions.

## III. In-class exercise: Inferring dN, dS rates from sequence alignment 

PAML is a package for maximum likelihood based evolutionary hypothesis testing. It contains many programs developed by Ziheng Yang's group including `CODEML` (for dN/dS rate), `evolver` for simulating phylogeny and sequences, and `MCMCtree` for divergence time estimation. We will be using `CODEML` to infer substitution rates under various scenarios.

The data we used for today's in-class exercises come from this paper:
[Álvarez-Carretero S, Kapli P, Yang Z. 2023. Beginner's guide on the use of PAML to detect positive selection, Mol Biol Evol, 40(4):msad041.](https://academic.oup.com/mbe/article/40/4/msad041/7140562?searchresult=1&login=false)

Recall the interpretation of $\omega$:

* $\omega > 1$ → positive (Darwinian) selection — nonsynonymous changes are favored;
* $\omega = 1$ → neutral evolution;
* $\omega < 1$ → negative (purifying) selection — nonsynonymous changes are being removed.

Because most codons in most genes are under some functional constraint, an $\omega$ averaged across an entire gene and an entire tree is almost always < 1, even for genes that experience strong positive selection at a handful of sites or along a handful of branches. The models below were used to estimate $\omega$ for all sites in all branches, for all sites in two types of branches, and for multiple types of sites x branches.

### 1. Input dataset

We will use the myxovirus resistance gene (`Mx`) alignment and tree from ten mammal species plus two birds as an outgroup.

Here we have:
```
Mx_aln.phy       # the codon alignment, PHYLIP format
Mx_unroot.tree   # unrooted gene tree, Newick format
Mx_branch_duckchicken.tree     # rooted and labeled gene tree, Newick format
```
The alignment file `Mx_aln.phy` is in PHYLIP format. View it in a text editor. The first line is a header:
```
12   1989
```
This tells us there are **12 sequences**, each **1989 nucleotides long**. Each subsequent line is a sequence name followed by its aligned sequence:

```
Rhesus_macaque_Mx      ATTGTAAAAGCTGATCCAGCT...
Orangutan_Mx           ATCGCAAAAGCTGATCCAGCT...
...
```

We will then open it in AliVIew to double check all sequences are in the correct codon positions.

The other input is the phylogeny. For most CODEML analyses, Newick format with topology is sufficient. For most analyses we deliberately use the **unrooted** tree. This is because we cannot estimate the lengths of the two branches leading away from the root and only their sum is identifiable. So rooting the tree adds a parameter that the data cannot actually inform. Using an unrooted tree removes that redundant parameter. See `Mx_unroot.tree`:

```
12  1
((((((Chimpanzee_Mx,Human_Mx),Orangutan_Mx),Rhesus_macaque_Mx),(((Sheep_Mx,Cow_Mx),Pig_Mx),Dog_Mx)),(Mouse_Mx,Rat_Mx)),Duck_Mx,Chicken_Mx);
```
The header `12  1` means 12 taxa, 1 tree in the file. The tree itself is standard Newick notation, and taxon names must match the sequence names in the alignment **exactly**.

### Labelling branches for hypothesis testing

Branch and branch-site models require you to tell `CODEML` which branches you hypothesize experienced a different selective regime: the **foreground** branch(es) versus the rest of the tree, the **background**. This is done by adding a `#1` tag directly after the taxon or clade in the tree file. For example, to test the entire bird clade, you tag the ancestral node plus two terminal nodes. In this case, we also need to root the phylogeny as well:

```
(...,(Duck_Mx #1,Chicken_Mx #1) #1);
```

Each `#1` you add corresponds to one additional $\omega$ class that `CODEML` will estimate for that group of branches, on top of the background $\omega$ for everything else.

## 2. What the four model classes assume

`CODEML` incorporates a variety of models where $\omega$ can vary very differently. Two control-file variables do the real work: `model` (variation across **branches**) and `NSsites` (variation across **sites**).

| Model family | Varies across | `model` | `NSsites` | Question it answers |
|---|---|---|---|---|
| Homogeneous (M0) | None| `0` | `0` | Is the gene, on average, under selection? |
| Branch models | branches (lineages) | `2` | `0` | Do specific *lineages* show a different $\omega$ than the rest of the tree? |
| Site models | codon sites | `0` | `0 1 2 7 8` | Do a subset of *sites* show $\omega > 1$? |
| Branch-site models | sites *within* specific branches | `2` | `2` | Do specific *sites*, but only along specific *foreground lineages*, show $\omega > 1$? |

a. Homogeneous model (M0): every site and every branch in the tree shares the same $\omega$. It's rarely biologically realistic, but it serves as our null hypothesis here.

b. Branch models

Branch models fix one $\omega$ per branch group, defined by the `#1` tags you place in the tree file. `model = 2` tells `CODEML` to look for those tags and estimate a separate $\omega$ for each labelled group. This tests whether a *specific lineage* (e.g., a dietary shift, a gene duplication, or a host jump) has an elevated $\omega$ relative to the rest of the tree.

c. Site models: $\omega$ vary among codons by drawing it from a statistical distribution across site classes, but they still assume every branch in the tree shares that same distribution (no lineage-specific effects). Running `NSsites = 0 1 2 7 8` fits five models in a single `CODEML` call:

- **M0** — one $\omega$ for all sites.
- **M1a (NearlyNeutral)** — two site classes: a proportion of sites with $0 < \omega_0 < 1$, and the remainder fixed at $\omega = 1$. No site class is allowed to exceed 1, so this model *cannot* detect positive selection by construction.
- **M2a (PositiveSelection)** — adds a third site class to M1a where $\omega_2$ is estimated freely and can exceed 1. Comparing M1a vs. M2a is the classic test for whether any sites are under positive selection.
- **M7 (beta)** — $\omega$ across sites follows a beta distribution bounded between 0 and 1 (approximated with 10 discrete site classes), so again no site can have $\omega > 1$.
- **M8 (beta&$\omega$)** — M7 plus one additional free site class that can have $\omega > 1$. Comparing M7 vs. M8 is a second, independent test for positive selection at specific sites, useful when the M1a/M2a comparison gives an ambiguous result.


d. Branch-site models

It allows $\omega$ to vary across sites *and* restricts the possibility of $\omega>1$ to specific, user-labelled foreground branches. It has four site classes:

- class 0: $\omega_0 < 1$ on both background and foreground branches (purifying, everywhere);
- class 1: $\omega = 1$ on both background and foreground branches (neutral, everywhere);
- class 2a: $\omega_0$ on background branches, but a freely estimated $\omega_2$ (possibly $>1$) on foreground branches;
- class 2b: $\omega = 1$ on background branches, but that same free $\omega_2$ on foreground branches.

In other words, it asks: *are there codons that were under purifying or neutral selection across most of the tree, but shifted to positive selection specifically along the foreground branch(es)?* It's set with `model = 2` and `NSsites = 2`.

To set up a null model for the branch-site model, we simply fix the the same model with $\omega$ for class 2a at 1 instead of estimated (`fix_omega = 1`, `omega = 1`). This null still allows the background/foreground split to exist, it just forbids the foreground $\omega$ from exceeding 1.

## 3. Building the control file


Set `seqtype = 1` in the control file to tell `CODEML` this is a codon alignment (as opposed to `2` for amino acids or `0` for nucleotides analysed without regard to codon structure).

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

See class demonstration for parameter explanation

### Settings for each model

| Setting | Homogeneous (M0) | Site models | Branch model | Branch-site model A | Branch-site null |
|---|---|---|---|---|---|
| `treefile` | unrooted | unrooted | unrooted (or rooted for a clade-stem hypothesis) | same as branch model | same as branch model |
| `model` | `0` | `0` | `2` | `2` | `2` |
| `NSsites` | `0` | `0 1 2 7 8` | `0` | `2` | `2` |
| `fix_omega` | `0` | `0` | `0` | `0` | `1` |
| `omega` | `0.5` (start) | `0.5` (start) | `0.5` (start) | `0.5` (start) | `1` (fixed) |

Everything else (`CodonFreq = 7`, `estFreq = 0`, `clock = 0`, `ndata = 1`) stays the same across all five.

## 4. Running CODEML

Once the control file is ready and sits in the same directory as (or points via relative path to) your alignment and tree files, run:

```
codeml your_control_file.ctl
```

`CODEML` writes its results to the file named in `outfile`. For multi-model runs (e.g. the five site models at once), the output file contains one block per model, each reporting the log-likelihood (`lnL`), the number of free parameters (`np`), and the maximum-likelihood estimates of $\omega$ and any other model parameters.

## 5. Likelihood ratio tests (LRT)

Every comparison in this lab follows the same logic: a **null model** versus an **alternative model** with more free parameters, where the null hypothesis is a special case (i.e., a nested model). You cannot LRT-compare models that aren't nested in this way.

The LRT test statistic is twice the difference in log-likelihoods:

$$2\Delta\ell = 2(\ell_{alt} - \ell_{null})$$

Under the null hypothesis, this statistic is asymptotically $\chi^2$-distributed with degrees of freedom equal to the difference in the number of free parameters between the two models. You then get a p-value from the $\chi^2$ distribution (e.g. in R: `pchisq(2*deltaL, df = k, lower.tail = FALSE)`), and reject the null in favor of the more complex one if that p-value is below your significance threshold (typically 0.05).

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
