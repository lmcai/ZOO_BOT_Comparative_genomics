# Organellar genome assembly using GetOrganelle

## I. Overview

We will work with GetOrganelle [website](https://github.com/kinggerm/getorganelle) for this lab. The lab focuses on the assembly and annotation of bacterium-like organellar genomes.

It is highly recommended that you work with **HiperGator** for this lab. It is possible to run the analysis locally on your laptop if your laptop has 16 GB RAM (memory).

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

## III. In-class exercise: Assemble a plastid genome from Illumina sequencing 

We will do a toy genome assembly and annotation for this lab. Plastid genome has high copy number (given their abundance in the cell) and a conserved structure, making it ideal for this class exercise. For those of you who are interested in assembling your own complex nuclear genome, the overall process will be similar, just 100x more complicated and resource-intensive. 

The data we used for today comes from two closely related plant species from my recent paper on parasitic plants: https://doi.org/10.1093/gbe/evag025

In a nutshell, parasitic plants rely on host plants for water and nutrients at various levels. Many of them have dropped photosynthesis capacity altogether, which has left a major footprint on their plastid genome size and structure.

### 1. Input dataset

The inputs are Illumina sequencing reads from libraries built from whole-genome DNA extraction. This means there is no biased selection in terms of the proportion of the three cellular genomes. We will work with two species *Castilleja indivisa* (entireleaf Indian paintbrush, collected in Austin Texas) and *Epifagus virginiana* (beechdrop, collected in Harvard Forest, Petersham, MA)

![Castilleja indivisa](./castilleja.jpeg)
![Epifagus virginiana](./beechdrop.jpg)

To access the data, log on to HiperGator and move to our shared scratch directory:
   ```
   cd /blue/bot4935/shared/Lab3
   ```

View the fastq files using the following command. Followed by in-class explanation of `fastq` file format.
```
cd raw_reads/Castilleja_indivisa
#view the fastq file
less V350045326_L03_B5GPLAalgdRAAAA-503_1.fq
```

### 2. Running GetOrganelle
Navigate to your own directory, make a copy of the submission script `getorganelle.sh` that loads the GetOrganelle module and runs assembly:
   ```
   #!/bin/sh
   #SBATCH --account=bot4935
   #SBATCH --qos=bot4935
   #SBATCH --job-name=getorg
   #SBATCH --cpus-per-task=4
   #SBATCH --mem-per-cpu=20gb
   #SBATCH -t 12:00:00
   #SBATCH -o CODEML.%j.out
   #SBATCH --mail-type=END,FAIL
   #SBATCH --mail-user=<email>@ufl.edu

   module load getorganelle/1.7.5.0

   get_organelle_from_reads.py -1 $1 -2 $2 -o $3 -R 15 -k 65,85,105 -F embplant_pt -t 4
   ```
Then submit and monitor the job:
   ```
   sbatch getorganelle.sh [path_to_read1] [path_to_reads2] [output_prefix]
   squeue -u <user>
   ```

This will take about 30 min to finish, depending on how many resources you requested (e.g., number of CPUs). 

```
See class demonstration regarding what the program is doing at each step
```

Let's take a look at the output. Navigate to the output folder `/blue/bot4935/share/Lab3/Cin` then follow in-class instruction

### 3. Resolve inverted or direct repeats in `Bandage` on your laptop

The output assembly graph from GetOrganelle is provided in this repository `` and ``. First, view these file using any text editor you have on your computer (e.g., BBEdit on mac and Notepad on PC). Follow in-class demonstration to edit the `.gfa` file using Bandage. Save the curated plastid genome as fasta files for annotation.

### 4. Plastid genome annotation using GeSeq

GeSeq is a web-based tool for annotation of plant organellar genomes. See the in-class demonstration for its usage.
