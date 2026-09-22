# Lab 1 homework: testing altered selection in lysozyme

## What to include for the submission?
1. A word/text file to answer the following questions.
2. The IQ-TREE log file.
3. 

Zip the above documents into a single file, submit through the Canvas assignment page.
---------------------

Included is the lysozyme sequence alignment of seven primate species originally from Messier and Stewart (1997). The sequence alignment is provided in `lysozyme.phy` and the input phylogeny is provided in `lysozyme.tre`. Use the codeml control file lysozyme.ctl as the template to perform parameter estimation for a Homogeneous model (M0) and a branch model to test for positive selection.

1. For the M0 model, how would you set up the `model` and `NSsites` in `lysozyme.ctl` (1 pt)?

2. Set the output to be `M0.out.txt` (outfile = ###). Run CODEML analysis for the M0 model. What are the omega and log-likelihood estimated from this model? (1pt)

3. Lysozyme was adapted for digestive defense against bacteria in primates that evolved foregut fermentation. Therefore, we suspect positive selection in the two branches leading to the common ancestor of Hominoids and Colobines as pictured below. How would you label your phylogeny according to the following colored branch pattern (pink branches set as foreground) (1 pt)

![image](./branch_model_figure.png) 

4. Based on the log file, what is the best-fitting substitution model selected by BIC (1 pt)?

5. View the *.treefile in FigTree. What is the ultrafast bootstrap support value for the common ancestor of `Amborella_AmTrH1.10G042500.1` and `Zea_GRMZM2G057935_T01` (1 pt)?

6. Given the following species tree, how would you root the phylogeny of the gene tree? Identify one ancient gene duplication and one recent gene duplication to explain the gene tree you get (1 pt)?

