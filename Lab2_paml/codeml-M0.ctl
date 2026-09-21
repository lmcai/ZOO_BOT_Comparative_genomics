      seqfile = Mx_aln.phy            * Path to the alignment file
     treefile = Mx_unroot.tree           * Path to the tree file
      outfile = out_M0.txt            * Path to the output file
   
        noisy = 0              * 0,1,2,3,9: how much rubbish on the screen
      verbose = 0              * 0: concise; 1: detailed, 2: too much

      seqtype = 1              * 1:codons; 2:AAs; 3:codons-->AAs
        ndata = 1           * Number of data sets or loci
        icode = 0              * Genetic codes: 0:universal, 1:mammalian mt., 2:yeast mt., 3:mold mt.
    cleandata = 0              * remove sites with ambiguity data (1:yes, 0:no)?
		
        model = 0         * models for codons:
                       		* 0:one, 1:b, 2:2 or more dN/dS ratios for branches
	  NSsites = 0           * 0:one w;1:neutral;2:positive selection; 3:discrete;4:freqs;
                   			* 5:gamma;6:2gamma;7:beta;8:beta&w;9:beta&gamma;
                   			* 10:beta&gamma+1; 11:beta&normal>1; 12:0&2normal>1;
                   			* 13:3normal>0
    CodonFreq = 7        * 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table, 7 specialized for mutation-selection model
	  estFreq = 0        * Use observed freqs or estimate freqs by ML
        clock = 0          * 0:no clock, 1:clock; 2:local clock; 3:CombinedAnalysis
    fix_omega = 0         * 1: omega or omega_1 fixed, 0: estimate 
        omega = 0.5        * initial or fixed omega, for codons or codon-based AAs

