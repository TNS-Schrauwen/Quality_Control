# Quality Control Pipeline
Containerized VCF Quality Control Pipeline using PLINK and VCFtools

## Overview
This containerized QC pipeline performs comprehensive quality control analysis on VCF files including relatedness analysis, gender checking, IBD analysis, and homozygosity detection.

## Building the Docker Image

```bash
docker build -t quality-control .
```

## Running the Container

#### Mount current directory
```bash
docker run -v $(pwd):/data quality-control QC --input_vcf /data/input.vcf.gz
```

#### Mount separate input and output directories
```bash
docker run \
  -v /home/user/vcf_files:/input:ro \
  -v /home/user/qc_results:/output \
  quality-control QC \
  --input_vcf /input/sample.vcf.gz \
  --output_directory /output \
  --vcf_prefix SampleBatch
```

## Script Options

The QC script (`Scaffold_QC.sh`) accepts the following parameters:

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `--input_vcf` | Yes | - | Path to input VCF file (must be gzipped) |
| `--output_directory` | No | `.` | Output directory for results |
| `--vcf_prefix` | No | `MyBatchPrefix` | Prefix for output files |

### Examples

#### Minimal usage
```bash
QC --input_vcf /data/samples.vcf.gz
```

#### Full parameter specification
```bash
QC --input_vcf /data/samples.vcf.gz --output_directory /results --vcf_prefix PopulationStudy
```

## Output Files

The pipeline generates multiple analysis files:

- **Relatedness**: `.relatedness` and `.relatedness2` files
- **Gender Check**: `.sex` and `.sex2` files
- **IBD Analysis**: `.IBD.genome` file
- **Heterozygosity**: `.HET.het` file
- **Inbreeding Coefficient**: `.IBC.ibc` file
- **Homozygosity**: `.HOM.hom` files
- **Cleaned VCF**: `.C.VCF.vcf.gz` with quality filters applied

## Dependencies

The container includes:
- PLINK (v1.90b6.21)
- VCFtools (v0.1.16)
- HTSlib/SAMtools/BCFtools (v1.22)

## Requirements

- Input VCF file must be bgzip compressed (`.vcf.gz`)
- Sufficient disk space for intermediate and output files
- Docker with appropriate permissions for volume mounts
