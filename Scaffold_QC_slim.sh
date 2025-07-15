#!/bin/bash

# Default values
output_directory="."
vcf_prefix="MyBatchPrefix"

# Parse arguments
OPTS=$(getopt --options '' --long input_vcf:,output_directory:,vcf_prefix: -- "$@")
eval set -- "$OPTS"

while true; do
    case "$1" in
        --input_vcf) input_vcf="$2"; shift 2 ;;
        --output_directory) output_directory="$2"; shift 2 ;;
        --vcf_prefix) vcf_prefix="$2"; shift 2 ;;
        --) shift; break ;;
    esac
done

if [ -z "$input_vcf" ]; then
    echo "Error: --input_vcf required"
    exit 1
fi

# Create directories
mkdir -p "${output_directory}"

# Relatedness
vcftools --relatedness --gzvcf "$input_vcf" --out "${output_directory}/$(basename "$input_vcf" .vcf.gz).relatedness"
vcftools --relatedness2 --gzvcf "$input_vcf" --out "${output_directory}/$(basename "$input_vcf" .vcf.gz).relatedness2"

# Gender check
output_prefix="${output_directory}/$(basename ${input_vcf} .vcf.gz)"
plink --vcf "${input_vcf}" --double-id --make-bed --out "${output_prefix}" --allow-extra-chr
plink --bfile "${output_prefix}" --check-sex --out "${output_prefix}.sex" --allow-extra-chr
plink --bfile "${output_prefix}" --check-sex 0.35 0.65 --out "${output_prefix}.sex2" --allow-extra-chr

# IBD
plink --bfile "${output_prefix}" --geno 0.1 --hwe 0.00001 --maf 0.05 --make-bed --out "${output_prefix}.C" --allow-extra-chr
plink --bfile "${output_prefix}.C" --indep-pairwise 50 5 0.5 --make-bed --out "${output_prefix}.CP" --allow-extra-chr
plink --bfile "${output_prefix}.CP" --genome --make-bed --out "${output_prefix}.IBD" --allow-extra-chr
plink --bfile "${output_prefix}.CP" --het --make-bed --out "${output_prefix}.HET" --allow-extra-chr
plink --bfile "${output_prefix}.CP" --ibc --make-bed --out "${output_prefix}.IBC" --allow-extra-chr
plink --bfile "${output_prefix}.C" --check-sex 0.35 0.65 --out "${output_prefix}.SEX.2.C.sexcheck" --allow-extra-chr
plink --bfile "${output_prefix}.C" --recode vcf --out "${output_prefix}.C.VCF" --allow-extra-chr

# Relatedness on cleaned VCF
cleaned_vcf="${output_prefix}.C.VCF.vcf"
bgzip "${cleaned_vcf}" && tabix -p vcf "${cleaned_vcf}.gz"
vcftools --relatedness --gzvcf "${cleaned_vcf}.gz" --out "${output_prefix}.C.relatedness"
vcftools --relatedness2 --gzvcf "${cleaned_vcf}.gz" --out "${output_prefix}.C.2.relatedness2"

# Homozygosity
plink --bfile "${output_prefix}" --geno 0.1 --hwe 0.00001 --maf 0.01 --make-bed --out "${output_prefix}.CH" --allow-extra-chr
plink --bfile "${output_prefix}.CH" --homozyg --make-bed --out "${output_prefix}.HOM" --allow-extra-chr