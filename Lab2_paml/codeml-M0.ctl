      seqfile = Mx_aln.phy            * Path to the alignment file
     treefile = Mx_unroot.tree           * Path to the tree file
      outfile = out_M0.txt            * Path to the output file
   
        noisy = 3              * 0,1,2,3,9: how much rubbish on the screen
      verbose = 1              * 0: concise; 1: detailed, 2: too much

      seqtype = 1              * 1:codons; 2:AAs; 3:codons-->AAs
        ndata = 1           * Number of data sets or loci
        icode = 0              * Genetic codes: 0:universal, 1:mammalian mt., 2:yeast mt., 3:mold mt.
    cleandata = 0              * remove sites with ambiguity data (1:yes, 0:no)?
		
        model = 0         * models for codons:
                       		* 0:one, 1:b, 2:2 or more dN/dS ratios for branches
	  NSsites = 0           0:one w;1:neutral;2:selection; 3:discrete;4:freqs;
                   			* 5:gamma;6:2gamma;7:beta;8:beta&w;9:beta&gamma;
                   			* 10:beta&gamma+1; 11:beta&normal>1; 12:0&2normal>1;
                   			* 13:3normal>0
    CodonFreq = 7        * Codon frequencies
	  estFreq = 0        * Use observed freqs or estimate freqs by ML
        clock = 0          * Clock model
    fix_omega = 0         * Estimate or fix omega
        omega = 0.5        * Initial or fixed omega

