# SAMPLE, GEN, GENTIC_MAP, HAPS, LEGEND, STRAND_INFO, SAMPLES_REFERENCE
# imputed.gen, imputed.gen_warnings

chrXflags=''
if [[ ${CHR} == *X* ]]
  then
    chrXflags="-sample_g ${SAMPLE} -chrX"
    if [[ ${CHR} != *NONPAR* ]]
    then
        chrXflags="\$chrXflags -Xpar"
    fi
    grep "^23 " ${GEN} | sed 's/^23/X/' | awk '\$3 >= ${START}'| awk '\$3 <= ${END}' >region.gen
    grep "^X " ${GEN} | awk '\$3 >= ${START}'| awk '\$3 <= ${END}' >>region.gen
else
    # create a gen with only the chromosome (the chromosomic region for efficiency)
    # else, impute2 doesn't detect any snp
    grep "^${CHR} " ${GEN} | awk '\$3 >= (${START} - 250000)'| awk '\$3 <= (${END} + 250000)' >region.gen
fi

chr=`echo ${CHR} | sed 's/_.\\+//'`
grep "^\$chr\\s" ${STRAND_INFO} | cut -d' ' -f2,3 >strand_g_file

# prephase haplotypes
impute2 -prephase_g \
-m ${REFERENCE}/genetic_map_chr${CHR}_combined_b37.txt \
-g region.gen \
-int ${START} ${END} \
-Ne 20000 
-o prephased.gen

# impute only on the screened SNPs
# only genotyped snps are included in the panel
impute2 -use_prephased_g \
-known_haps_g prephased.gen_haps \
-m ${REFERENCE}/genetic_map_chr${CHR}_combined_b37.txt \
-int ${START} ${END} \
-h ${REFERENCE}/1000GP_Phase3_chr${CHR}.hap.gz \
-l ${REFERENCE}/1000GP_Phase3_chr${CHR}.legend.gz \
-Ne 20000 \
-verbose \
\$chrXflags \
-k_hap ${SAMPLES_REFERENCE} \
-os 2 -o imputed.gen \
-strand_g strand_g_file || ( mv region.gen imputed.gen && exit 77 )
