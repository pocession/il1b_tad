wd=/scratch/thsieh
sub=$wd/4C
fastq=$sub/fastq
outputDir=$sub/mapped

# For downstream analysis, reads have to be mapped to this version of genome
bowtie_index=$wd/hg38/GRCh38_noalt/GRCh38_noalt_as

# 43024_d0_VP2_L01_R1.fastq.gz

source ~/.bashrc
conda deactivate
conda activate alignment

VP2_list=($fastq/*_VP2_*_R1.fastq.gz)
for i in ${VP2_list[@]}; 
do
        echo "Reading sample from: $i"
        basename_temp=${i%_R1.fastq.gz}
        basename=${basename_temp##*/}
        echo "Processing sample ${basename}"

        (bowtie2 --trim5 17 \
                -x $bowtie_index \
                -U $i \
                -S $outputDir/${basename}.sam) 2> $sub/log/${basename}.log
        echo "Writing log file into $sub/log/${basename}.log"
done

VP3_list=($fastq/*_VP3_*_R1.fastq.gz)
for i in ${VP3_list[@]}; 
do
        echo "Reading sample from: $i"
        basename_temp=${i%_R1.fastq.gz}
        basename=${basename_temp##*/}
        echo "Processing sample ${basename}"

        (bowtie2 --trim5 19 \
                -x $bowtie_index \
                -U $i \
                -S $outputDir/${basename}.sam) 2> $sub/log/${basename}.log
        echo "Writing log file into $sub/log/${basename}.log"
done

VP6_list=($fastq/*_VP6_*_R1.fastq.gz)
for i in ${VP6_list[@]}; 
do
        echo "Reading sample from: $i"
        basename_temp=${i%_R1.fastq.gz}
        basename=${basename_temp##*/}
        echo "Processing sample ${basename}"

        (bowtie2 --trim5 17 \
                -x $bowtie_index \
                -U $i \
                -S $outputDir/${basename}.sam) 2> $sub/log/${basename}.log
        echo "Writing log file into $sub/log/${basename}.log"
done
